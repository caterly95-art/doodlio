import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/game_constants.dart';
import '../core/utils/sound_effects.dart';
import '../core/utils/haptic_feedback_helper.dart';
import '../models/player_model.dart';
import '../models/room_model.dart';
import '../models/chat_message_model.dart';
import '../services/realtime_database_service.dart';
import '../services/game_service.dart';

class GameProvider with ChangeNotifier {
  final RealtimeDatabaseService _rtdb;
  final GameService _gameService;
  static const _uuid = Uuid();

  RoomModel? _currentRoom;
  List<ChatMessageModel> _chatMessages = [];
  String? _currentUserId;

  StreamSubscription<RoomModel?>? _roomSubscription;
  StreamSubscription<List<ChatMessageModel>>? _chatSubscription;

  Timer? _gameLoopTimer;
  int _remainingSeconds = 0;
  double _timerProgress = 1.0;
  bool _isLoading = false;
  String? _errorMessage;

  // Rate limiting
  int _lastMessageTime = 0;

  // Track secret word locally for drawer display
  String? _localSecretWord;

  GameProvider(this._rtdb, this._gameService);

  RoomModel? get currentRoom => _currentRoom;
  List<ChatMessageModel> get chatMessages => List.unmodifiable(_chatMessages);
  int get remainingSeconds => _remainingSeconds;
  double get timerProgress => _timerProgress;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get secretWordForDrawer => _localSecretWord;

  bool get isInRoom => _currentRoom != null;
  bool get isHost => _currentRoom != null && _currentUserId != null && _currentRoom!.isHost(_currentUserId!);
  bool get isDrawer => _currentRoom != null && _currentUserId != null && _currentRoom!.isCurrentDrawer(_currentUserId!);

  PlayerModel? get myPlayer =>
      (_currentRoom != null && _currentUserId != null) ? _currentRoom!.players[_currentUserId] : null;

  bool get hasGuessed => myPlayer?.hasGuessed ?? false;

  /// Set the active user ID
  void setCurrentUserId(String uid) {
    _currentUserId = uid;
  }

  /// Create Room
  Future<RoomModel?> createRoom({
    required PlayerModel host,
    required RoomConfig config,
    required String roomName,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _currentUserId = host.uid;
      final room = await _rtdb.createRoom(
        host: host,
        config: config,
        roomName: roomName,
      );
      _subscribeToRoom(room.id);
      _setLoading(false);
      return room;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }

  /// Join Room
  Future<bool> joinRoom({
    required String roomId,
    required PlayerModel player,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _currentUserId = player.uid;
      final room = await _rtdb.joinRoom(roomId: roomId, player: player);
      _subscribeToRoom(room.id);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Subscribe to Room and Chat streams
  void _subscribeToRoom(String roomId) {
    _roomSubscription?.cancel();
    _chatSubscription?.cancel();

    _roomSubscription = _rtdb.streamRoom(roomId).listen((updatedRoom) async {
      final previousStatus = _currentRoom?.status;
      _currentRoom = updatedRoom;

      if (updatedRoom == null) {
        // Room was deleted or closed
        _stopGameLoop();
        notifyListeners();
        return;
      }

      // Check if we entered drawing state as drawer
      if (updatedRoom.status == GameConstants.statusDrawing &&
          isDrawer &&
          _localSecretWord == null) {
        _localSecretWord = await _rtdb.getSecretWord(roomId);
      } else if (updatedRoom.status != GameConstants.statusDrawing) {
        _localSecretWord = null;
      }

      // If status changed, provide audio cue
      if (previousStatus != updatedRoom.status) {
        if (updatedRoom.status == GameConstants.statusDrawing) {
          SoundEffectsHelper.playAlert();
        } else if (updatedRoom.status == GameConstants.statusGameOver) {
          SoundEffectsHelper.playSuccess();
        }
      }

      notifyListeners();
    });

    _chatSubscription = _rtdb.streamChat(roomId).listen((messages) {
      _chatMessages = messages;
      notifyListeners();
    });

    _startGameLoop();
  }

  /// Start the 1-second interval timer loop
  void _startGameLoop() {
    _gameLoopTimer?.cancel();
    _gameLoopTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_currentRoom == null) return;

      final now = DateTime.now().millisecondsSinceEpoch;
      final endTime = _currentRoom!.roundEndTime ?? now;
      final startTime = _currentRoom!.roundStartTime ?? now;
      final totalDuration = (endTime - startTime).clamp(1000, 300000);

      final diffSec = ((endTime - now) / 1000).ceil();
      _remainingSeconds = diffSec.clamp(0, 300);

      final progress = (_remainingSeconds * 1000) / totalDuration;
      _timerProgress = progress.clamp(0.0, 1.0);

      // Audio countdown when time is running low
      if (_currentRoom!.status == GameConstants.statusDrawing) {
        if (_remainingSeconds == 10 || _remainingSeconds == 5 || _remainingSeconds <= 3 && _remainingSeconds > 0) {
          SoundEffectsHelper.playTick();
          HapticHelper.light();
        }
      }

      // Authoritative Host actions upon timer expiration
      if (isHost && _remainingSeconds <= 0) {
        if (_currentRoom!.status == GameConstants.statusWordSelection) {
          // Drawer ran out of time picking word, auto-select
          await _gameService.autoSelectWord(_currentRoom!);
        } else if (_currentRoom!.status == GameConstants.statusDrawing) {
          // Drawing time expired, end round
          await _gameService.endDrawingTurn(_currentRoom!);
        } else if (_currentRoom!.status == GameConstants.statusRoundResults) {
          // Round results time expired, advance turn
          await _gameService.advanceToNextTurn(_currentRoom!);
        }
      }

      // Host updates progressive hints during drawing turn
      if (isHost && _currentRoom!.status == GameConstants.statusDrawing) {
        if (_remainingSeconds == (_currentRoom!.config.drawDuration * 0.5).round() ||
            _remainingSeconds == (_currentRoom!.config.drawDuration * 0.25).round()) {
          await _gameService.updateProgressiveHint(
            roomId: _currentRoom!.id,
            remainingFraction: _timerProgress,
          );
        }
      }

      notifyListeners();
    });
  }

  void _stopGameLoop() {
    _gameLoopTimer?.cancel();
    _gameLoopTimer = null;
  }

  /// Toggle Ready Status
  Future<void> toggleReady() async {
    if (_currentRoom == null || _currentUserId == null || myPlayer == null) return;
    final newReady = !myPlayer!.isReady;
    HapticHelper.selection();
    await _rtdb.togglePlayerReady(_currentRoom!.id, _currentUserId!, newReady);
  }

  /// Host starts match
  Future<void> startMatch() async {
    if (_currentRoom == null || !isHost) return;
    _setLoading(true);
    try {
      await _gameService.startGame(_currentRoom!);
      HapticHelper.success();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Drawer selects secret word
  Future<void> chooseWord(String word) async {
    if (_currentRoom == null || !isDrawer) return;
    _localSecretWord = word;
    HapticHelper.success();
    await _gameService.selectWord(
      roomId: _currentRoom!.id,
      selectedWord: word,
      drawDuration: _currentRoom!.config.drawDuration,
    );
  }

  /// Send chat or guess with rate limiting
  Future<void> sendGuessOrChat(String text) async {
    if (_currentRoom == null || myPlayer == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastMessageTime < GameConstants.chatRateLimitMs) {
      return; // Rate limited
    }
    _lastMessageTime = now;

    HapticHelper.light();
    await _gameService.handlePlayerMessage(
      room: _currentRoom!,
      player: myPlayer!,
      text: text,
    );
  }

  /// Send quick emoji reaction
  Future<void> sendReaction(String emoji) async {
    if (_currentRoom == null || myPlayer == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final msg = ChatMessageModel(
      id: _uuid.v4(),
      senderId: myPlayer!.uid,
      senderName: myPlayer!.displayName,
      text: emoji,
      reaction: emoji,
      timestamp: now,
    );
    await _rtdb.sendChatMessage(roomId: _currentRoom!.id, message: msg);
    HapticHelper.selection();
  }

  /// Leave current room
  Future<void> leaveCurrentRoom() async {
    if (_currentRoom != null && _currentUserId != null && myPlayer != null) {
      await _rtdb.leaveRoom(
        roomId: _currentRoom!.id,
        uid: _currentUserId!,
        playerName: myPlayer!.displayName,
        isHost: isHost,
      );
    }
    _stopGameLoop();
    _roomSubscription?.cancel();
    _chatSubscription?.cancel();
    _currentRoom = null;
    _chatMessages = [];
    _localSecretWord = null;
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _stopGameLoop();
    _roomSubscription?.cancel();
    _chatSubscription?.cancel();
    super.dispose();
  }
}

