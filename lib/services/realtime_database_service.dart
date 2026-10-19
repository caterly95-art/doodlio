import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import '../core/constants/game_constants.dart';
import '../models/player_model.dart';
import '../models/room_model.dart';
import '../models/draw_stroke_model.dart';
import '../models/chat_message_model.dart';

class RealtimeDatabaseService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  DatabaseReference get _roomsRef => _db.ref('rooms');
  DatabaseReference get _secretsRef => _db.ref('secret_words');

  /// Generate a clean, 6-character alphanumeric room code
  static String generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // No ambiguous characters (O, 0, I, 1)
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Create a new multiplayer room
  Future<RoomModel> createRoom({
    required PlayerModel host,
    required RoomConfig config,
    required String roomName,
  }) async {
    final roomId = generateRoomCode();
    final now = DateTime.now().millisecondsSinceEpoch;

    final room = RoomModel(
      id: roomId,
      name: roomName,
      hostId: host.uid,
      status: GameConstants.statusLobby,
      config: config,
      currentRound: 1,
      turnIndex: 0,
      createdAt: now,
      players: {host.uid: host.copyWith(isHost: true, isReady: true)},
    );

    await _roomsRef.child(roomId).set(room.toMap());
    await _roomsRef.child(roomId).child('players').child(host.uid).set(
      host.copyWith(isHost: true, isReady: true).toMap(),
    );

    // Setup disconnect behavior for host
    _setupPlayerDisconnect(roomId, host.uid);

    return room;
  }

  /// Join an existing room
  Future<RoomModel> joinRoom({
    required String roomId,
    required PlayerModel player,
  }) async {
    final cleanId = roomId.trim().toUpperCase();
    final roomSnap = await _roomsRef.child(cleanId).get();

    if (!roomSnap.exists || roomSnap.value == null) {
      throw 'Room "$cleanId" not found. Check the code and try again.';
    }

    final rawRoom = roomSnap.value as Map<dynamic, dynamic>;
    final room = RoomModel.fromMap(rawRoom, cleanId);

    if (room.status != GameConstants.statusLobby) {
      throw 'This game is already in progress.';
    }

    if (room.players.length >= room.config.maxPlayers) {
      throw 'This room is currently full (${room.config.maxPlayers}/${room.config.maxPlayers} players).';
    }

    // Add player to room
    final joiningPlayer = player.copyWith(
      isHost: false,
      isReady: false,
      score: 0,
      roundScore: 0,
      hasGuessed: false,
    );

    await _roomsRef
        .child(cleanId)
        .child('players')
        .child(player.uid)
        .set(joiningPlayer.toMap());

    // Send system announcement
    await sendSystemMessage(
      roomId: cleanId,
      text: '${player.displayName} joined the lobby!',
    );

    // Setup disconnect hook
    _setupPlayerDisconnect(cleanId, player.uid);

    return room;
  }

  /// Set up onDisconnect handler to gracefully handle player disconnections
  void _setupPlayerDisconnect(String roomId, String uid) {
    try {
      final playerRef = _roomsRef.child(roomId).child('players').child(uid);
      playerRef.onDisconnect().update({
        'isOnline': false,
        'connected': false,
        'lastActive': ServerValue.timestamp,
      });
    } catch (_) {}
  }

  /// Leave room
  Future<void> leaveRoom({
    required String roomId,
    required String uid,
    required String playerName,
    required bool isHost,
  }) async {
    try {
      final playerRef = _roomsRef.child(roomId).child('players').child(uid);
      await playerRef.remove();

      // Announce leave
      await sendSystemMessage(
        roomId: roomId,
        text: '$playerName left the room.',
      );

      // Check remaining players
      final playersSnap = await _roomsRef.child(roomId).child('players').get();
      if (!playersSnap.exists || playersSnap.children.isEmpty) {
        // Room is abandoned, remove it
        await _roomsRef.child(roomId).remove();
        await _secretsRef.child(roomId).remove();
      } else if (isHost) {
        // Migrate host to the first remaining player
        final remaining = playersSnap.children.toList();
        if (remaining.isNotEmpty) {
          final nextHostId = remaining.first.key;
          if (nextHostId != null) {
            await _roomsRef.child(roomId).update({'hostId': nextHostId});
            await _roomsRef
                .child(roomId)
                .child('players')
                .child(nextHostId)
                .update({'isHost': true});
          }
        }
      }
    } catch (_) {}
  }

  /// Stream full room data
  Stream<RoomModel?> streamRoom(String roomId) {
    return _roomsRef.child(roomId).onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return null;
      }
      final raw = event.snapshot.value as Map<dynamic, dynamic>;
      return RoomModel.fromMap(raw, roomId);
    });
  }

  /// Stream public rooms waiting for players
  Stream<List<RoomModel>> streamPublicRooms() {
    return _roomsRef
        .orderByChild('status')
        .equalTo(GameConstants.statusLobby)
        .onValue
        .map((event) {
      final list = <RoomModel>[];
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return list;
      }
      for (final child in event.snapshot.children) {
        if (child.value is Map) {
          final r = RoomModel.fromMap(child.value as Map<dynamic, dynamic>, child.key!);
          if (r.config.isPublic && r.players.length < r.config.maxPlayers) {
            list.add(r);
          }
        }
      }
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Update room top-level fields
  Future<void> updateRoom(String roomId, Map<String, dynamic> updates) async {
    await _roomsRef.child(roomId).update(updates);
  }

  /// Update player fields
  Future<void> updatePlayer(
    String roomId,
    String uid,
    Map<String, dynamic> updates,
  ) async {
    await _roomsRef.child(roomId).child('players').child(uid).update(updates);
  }

  /// Toggle player ready state
  Future<void> togglePlayerReady(String roomId, String uid, bool isReady) async {
    await updatePlayer(roomId, uid, {'isReady': isReady});
  }

  // --- DRAWING STROKES API ---

  /// Stream strokes for a room ordered by order / timestamp
  Stream<List<DrawStroke>> streamStrokes(String roomId) {
    return _roomsRef.child(roomId).child('strokes').onValue.map((event) {
      final strokes = <DrawStroke>[];
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return strokes;
      }
      for (final child in event.snapshot.children) {
        if (child.value is Map) {
          strokes.add(DrawStroke.fromMap(child.value as Map<dynamic, dynamic>, child.key!));
        }
      }
      strokes.sort((a, b) => a.order.compareTo(b.order));
      return strokes;
    });
  }

  /// Push a new completed stroke to Firebase
  Future<void> addStroke(String roomId, DrawStroke stroke) async {
    await _roomsRef
        .child(roomId)
        .child('strokes')
        .child(stroke.id)
        .set(stroke.toMap());
  }

  /// Clear all strokes (drawer pressed clear)
  Future<void> clearStrokes(String roomId) async {
    await _roomsRef.child(roomId).child('strokes').remove();
  }

  /// Undo the last stroke
  Future<void> removeStroke(String roomId, String strokeId) async {
    await _roomsRef.child(roomId).child('strokes').child(strokeId).remove();
  }

  // --- CHAT & GUESSING API ---

  /// Stream chat and guess messages
  Stream<List<ChatMessageModel>> streamChat(String roomId) {
    return _roomsRef
        .child(roomId)
        .child('chat')
        .orderByChild('timestamp')
        .limitToLast(50)
        .onValue
        .map((event) {
      final messages = <ChatMessageModel>[];
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return messages;
      }
      for (final child in event.snapshot.children) {
        if (child.value is Map) {
          messages.add(
            ChatMessageModel.fromMap(child.value as Map<dynamic, dynamic>, child.key!),
          );
        }
      }
      return messages;
    });
  }

  /// Send user chat / guess
  Future<void> sendChatMessage({
    required String roomId,
    required ChatMessageModel message,
  }) async {
    await _roomsRef
        .child(roomId)
        .child('chat')
        .child(message.id)
        .set(message.toMap());
  }

  /// Send system announcement
  Future<void> sendSystemMessage({
    required String roomId,
    required String text,
  }) async {
    final id = _roomsRef.child(roomId).child('chat').push().key ??
        DateTime.now().millisecondsSinceEpoch.toString();

    final msg = ChatMessageModel(
      id: id,
      senderId: 'system',
      senderName: 'Doodlio',
      text: text,
      isSystem: true,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    await _roomsRef.child(roomId).child('chat').child(id).set(msg.toMap());
  }

  // --- SECRET WORD STORE ---

  /// Set the secret word for the current round
  Future<void> setSecretWord(String roomId, String word) async {
    await _secretsRef.child(roomId).set({
      'word': word.toUpperCase().trim(),
      'timestamp': ServerValue.timestamp,
    });
  }

  /// Read secret word (for drawer or host)
  Future<String?> getSecretWord(String roomId) async {
    final snap = await _secretsRef.child(roomId).child('word').get();
    if (snap.exists && snap.value != null) {
      return snap.value.toString();
    }
    return null;
  }

  /// Remove secret word when round ends
  Future<void> clearSecretWord(String roomId) async {
    await _secretsRef.child(roomId).remove();
  }
}

