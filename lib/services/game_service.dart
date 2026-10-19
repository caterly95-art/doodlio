import 'dart:async';
import 'package:uuid/uuid.dart';
import '../core/constants/game_constants.dart';
import '../core/utils/word_repository.dart';
import '../models/player_model.dart';
import '../models/room_model.dart';
import '../models/chat_message_model.dart';
import 'realtime_database_service.dart';
import 'firestore_service.dart';

class GameService {
  final RealtimeDatabaseService _rtdb;
  final FirestoreService _firestore;
  static const _uuid = Uuid();

  GameService(this._rtdb, this._firestore);

  /// Start game from Lobby (host only)
  Future<void> startGame(RoomModel room) async {
    final players = room.playerList;
    if (players.length < GameConstants.minPlayers) {
      throw 'At least ${GameConstants.minPlayers} players are needed to start.';
    }

    // Reset scores and set up Round 1
    final playerUpdates = <String, dynamic>{};
    for (final p in players) {
      playerUpdates['players/${p.uid}/score'] = 0;
      playerUpdates['players/${p.uid}/roundScore'] = 0;
      playerUpdates['players/${p.uid}/hasGuessed'] = false;
    }

    final firstDrawer = players.first;
    final wordChoices = WordRepository.getRandomWordChoices(
      category: room.config.category,
      difficulty: room.config.difficulty,
      count: 3,
    );

    final now = DateTime.now().millisecondsSinceEpoch;
    final updates = {
      ...playerUpdates,
      'status': GameConstants.statusWordSelection,
      'currentRound': 1,
      'turnIndex': 0,
      'currentDrawerId': firstDrawer.uid,
      'currentDrawerName': firstDrawer.displayName,
      'wordChoices': wordChoices,
      'roundStartTime': now,
      'roundEndTime': now + (GameConstants.wordSelectionDuration * 1000),
      'lastCorrectWord': null,
      'winnerId': null,
      'winnerName': null,
    };

    await _rtdb.updateRoom(room.id, updates);
    await _rtdb.clearStrokes(room.id);
    await _rtdb.sendSystemMessage(
      roomId: room.id,
      text: 'Match started! Round 1 of ${room.config.rounds}.',
    );
  }

  /// Active drawer chooses a word to draw
  Future<void> selectWord({
    required String roomId,
    required String selectedWord,
    required int drawDuration,
  }) async {
    final cleanWord = selectedWord.toUpperCase().trim();
    final now = DateTime.now().millisecondsSinceEpoch;
    final endTime = now + (drawDuration * 1000);

    // Save secret word securely
    await _rtdb.setSecretWord(roomId, cleanWord);

    // Clear previous drawing strokes
    await _rtdb.clearStrokes(roomId);

    final initialHint = WordRepository.generateProgressiveHint(cleanWord, 1.0);

    // Reset player round guess flags
    final roomSnap = await _rtdb.streamRoom(roomId).first;
    if (roomSnap != null) {
      for (final p in roomSnap.players.values) {
        await _rtdb.updatePlayer(roomId, p.uid, {
          'hasGuessed': false,
          'roundScore': 0,
        });
      }
    }

    // Update room to drawing phase
    await _rtdb.updateRoom(roomId, {
      'status': GameConstants.statusDrawing,
      'wordLength': cleanWord.replaceAll(' ', '').length,
      'wordHint': initialHint,
      'roundStartTime': now,
      'roundEndTime': endTime,
      'wordChoices': [],
    });

    await _rtdb.sendSystemMessage(
      roomId: roomId,
      text: 'Word chosen! Start drawing & guessing!',
    );
  }

  /// Automatically pick word if drawer runs out of selection time
  Future<void> autoSelectWord(RoomModel room) async {
    if (room.wordChoices.isNotEmpty) {
      await selectWord(
        roomId: room.id,
        selectedWord: room.wordChoices.first,
        drawDuration: room.config.drawDuration,
      );
    }
  }

  /// Process incoming player chat or guess
  Future<void> handlePlayerMessage({
    required RoomModel room,
    required PlayerModel player,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final msgId = _uuid.v4();

    // If game is not in drawing state, or player is drawer, or already guessed
    if (room.status != GameConstants.statusDrawing ||
        room.isCurrentDrawer(player.uid) ||
        player.hasGuessed) {
      // Normal chat message
      final msg = ChatMessageModel(
        id: msgId,
        senderId: player.uid,
        senderName: player.displayName,
        text: trimmed,
        timestamp: now,
      );
      await _rtdb.sendChatMessage(roomId: room.id, message: msg);
      return;
    }

    // In drawing phase: retrieve secret word to evaluate
    final secretWord = await _rtdb.getSecretWord(room.id);
    if (secretWord == null || secretWord.isEmpty) {
      final msg = ChatMessageModel(
        id: msgId,
        senderId: player.uid,
        senderName: player.displayName,
        text: trimmed,
        timestamp: now,
      );
      await _rtdb.sendChatMessage(roomId: room.id, message: msg);
      return;
    }

    // 1. Check for EXACT MATCH
    if (WordRepository.isExactMatch(trimmed, secretWord)) {
      // Calculate score based on remaining time
      final roundEndTime = room.roundEndTime ?? (now + 1000);
      final remainingMs = (roundEndTime - now).clamp(0, room.config.drawDuration * 1000);
      final fraction = remainingMs / (room.config.drawDuration * 1000);

      final points = GameConstants.minGuessPoints +
          (fraction * (GameConstants.maxGuessPoints - GameConstants.minGuessPoints)).round();

      // Mark player as guessed and add score
      final newTotalScore = player.score + points;
      await _rtdb.updatePlayer(room.id, player.uid, {
        'hasGuessed': true,
        'score': newTotalScore,
        'roundScore': points,
        'guessedAt': now,
      });

      // Award bonus points to the drawer
      if (room.currentDrawerId != null) {
        final drawer = room.players[room.currentDrawerId!];
        if (drawer != null) {
          final drawerBonus = GameConstants.drawerBonusPerGuesser;
          await _rtdb.updatePlayer(room.id, drawer.uid, {
            'score': drawer.score + drawerBonus,
            'roundScore': drawer.roundScore + drawerBonus,
          });
        }
      }

      // Send correct guess announcement
      final correctMsg = ChatMessageModel(
        id: msgId,
        senderId: player.uid,
        senderName: player.displayName,
        text: '${player.displayName} guessed the word! (+$points pts)',
        isSystem: true,
        isCorrectGuess: true,
        timestamp: now,
      );
      await _rtdb.sendChatMessage(roomId: room.id, message: correctMsg);

      // Check if all eligible guessers have now guessed
      final updatedRoomSnap = await _rtdb.streamRoom(room.id).first;
      if (updatedRoomSnap != null) {
        final eligibleGuessers = updatedRoomSnap.players.values
            .where((p) => p.uid != updatedRoomSnap.currentDrawerId && p.isOnline)
            .toList();

        final allGuessed = eligibleGuessers.isNotEmpty &&
            eligibleGuessers.every((p) => p.hasGuessed);

        if (allGuessed) {
          // Immediately conclude drawing turn
          await endDrawingTurn(updatedRoomSnap);
        }
      }
      return;
    }

    // 2. Check for CLOSE GUESS (1 typo)
    if (WordRepository.isCloseGuess(trimmed, secretWord)) {
      // Notify sender that they're close
      final closeMsg = ChatMessageModel(
        id: msgId,
        senderId: player.uid,
        senderName: player.displayName,
        text: '$trimmed (Very close!)',
        isCloseGuess: true,
        timestamp: now,
      );
      await _rtdb.sendChatMessage(roomId: room.id, message: closeMsg);
      return;
    }

    // 3. Regular incorrect guess - mask if it contains the secret word
    final maskedText = WordRepository.maskSpoiler(trimmed, secretWord);
    final chatMsg = ChatMessageModel(
      id: msgId,
      senderId: player.uid,
      senderName: player.displayName,
      text: maskedText,
      timestamp: now,
    );
    await _rtdb.sendChatMessage(roomId: room.id, message: chatMsg);
  }

  /// Update hint progressively based on remaining time
  Future<void> updateProgressiveHint({
    required String roomId,
    required double remainingFraction,
  }) async {
    final secretWord = await _rtdb.getSecretWord(roomId);
    if (secretWord != null && secretWord.isNotEmpty) {
      final hint = WordRepository.generateProgressiveHint(secretWord, remainingFraction);
      await _rtdb.updateRoom(roomId, {'wordHint': hint});
    }
  }

  /// Conclude current drawing turn and present Round Results
  Future<void> endDrawingTurn(RoomModel room) async {
    final secretWord = await _rtdb.getSecretWord(room.id);
    final now = DateTime.now().millisecondsSinceEpoch;

    await _rtdb.updateRoom(room.id, {
      'status': GameConstants.statusRoundResults,
      'lastCorrectWord': secretWord ?? 'Word',
      'roundStartTime': now,
      'roundEndTime': now + (GameConstants.roundResultsDuration * 1000),
    });

    await _rtdb.sendSystemMessage(
      roomId: room.id,
      text: 'Time is up! The secret word was: "${secretWord ?? 'Word'}"',
    );
  }

  /// Advance to next turn or end match
  Future<void> advanceToNextTurn(RoomModel room) async {
    final players = room.playerList;
    if (players.isEmpty) return;

    final nextTurnIndex = room.turnIndex + 1;

    // If everyone in this round has had their turn to draw
    if (nextTurnIndex >= players.length) {
      final nextRound = room.currentRound + 1;

      // Check if match reached max configured rounds
      if (nextRound > room.config.rounds) {
        // MATCH OVER!
        await _concludeGame(room);
        return;
      }

      // Next Round starts with first player
      final nextDrawer = players[0];
      final wordChoices = WordRepository.getRandomWordChoices(
        category: room.config.category,
        difficulty: room.config.difficulty,
        count: 3,
      );

      final now = DateTime.now().millisecondsSinceEpoch;
      await _rtdb.updateRoom(room.id, {
        'status': GameConstants.statusWordSelection,
        'currentRound': nextRound,
        'turnIndex': 0,
        'currentDrawerId': nextDrawer.uid,
        'currentDrawerName': nextDrawer.displayName,
        'wordChoices': wordChoices,
        'roundStartTime': now,
        'roundEndTime': now + (GameConstants.wordSelectionDuration * 1000),
      });

      await _rtdb.clearStrokes(room.id);
      await _rtdb.sendSystemMessage(
        roomId: room.id,
        text: 'Round $nextRound started! ${nextDrawer.displayName} is choosing a word.',
      );
    } else {
      // Next player's turn in current round
      final nextDrawer = players[nextTurnIndex];
      final wordChoices = WordRepository.getRandomWordChoices(
        category: room.config.category,
        difficulty: room.config.difficulty,
        count: 3,
      );

      final now = DateTime.now().millisecondsSinceEpoch;
      await _rtdb.updateRoom(room.id, {
        'status': GameConstants.statusWordSelection,
        'turnIndex': nextTurnIndex,
        'currentDrawerId': nextDrawer.uid,
        'currentDrawerName': nextDrawer.displayName,
        'wordChoices': wordChoices,
        'roundStartTime': now,
        'roundEndTime': now + (GameConstants.wordSelectionDuration * 1000),
      });

      await _rtdb.clearStrokes(room.id);
      await _rtdb.sendSystemMessage(
        roomId: room.id,
        text: '${nextDrawer.displayName} is choosing a word.',
      );
    }
  }

  /// Conclude match, record winner and update Firestore stats
  Future<void> _concludeGame(RoomModel room) async {
    final players = room.playerList;
    players.sort((a, b) => b.score.compareTo(a.score));

    final winner = players.isNotEmpty ? players.first : null;
    final winnerId = winner?.uid ?? '';
    final winnerName = winner?.displayName ?? 'Player';

    await _rtdb.updateRoom(room.id, {
      'status': GameConstants.statusGameOver,
      'winnerId': winnerId,
      'winnerName': winnerName,
    });

    await _rtdb.sendSystemMessage(
      roomId: room.id,
      text: '🏆 Game Over! $winnerName wins with ${winner?.score ?? 0} points!',
    );

    // Save match to Firestore
    final playerScores = <String, int>{};
    for (final p in players) {
      playerScores[p.uid] = p.score;
      // Update individual player stats in Firestore
      await _firestore.updateMatchStats(
        uid: p.uid,
        won: p.uid == winnerId,
        pointsGained: p.score,
        correctGuessesGained: (p.score / 200).round(),
        drawingsGained: room.config.rounds,
      );
    }

    await _firestore.saveMatchHistory(
      roomId: room.id,
      winnerId: winnerId,
      winnerName: winnerName,
      roundsPlayed: room.config.rounds,
      playerScores: playerScores,
    );
  }
}

