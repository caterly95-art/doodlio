import '../core/constants/game_constants.dart';
import 'player_model.dart';

class RoomConfig {
  final int maxPlayers;
  final int rounds;
  final int drawDuration;
  final String difficulty;
  final String category;
  final bool isPublic;

  const RoomConfig({
    this.maxPlayers = GameConstants.defaultMaxPlayers,
    this.rounds = GameConstants.defaultRounds,
    this.drawDuration = GameConstants.defaultDrawDuration,
    this.difficulty = GameConstants.difficultyAll,
    this.category = GameConstants.categoryAll,
    this.isPublic = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'maxPlayers': maxPlayers,
      'rounds': rounds,
      'drawDuration': drawDuration,
      'difficulty': difficulty,
      'category': category,
      'isPublic': isPublic,
    };
  }

  factory RoomConfig.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return const RoomConfig();
    return RoomConfig(
      maxPlayers: (map['maxPlayers'] as num?)?.toInt() ?? GameConstants.defaultMaxPlayers,
      rounds: (map['rounds'] as num?)?.toInt() ?? GameConstants.defaultRounds,
      drawDuration: (map['drawDuration'] as num?)?.toInt() ?? GameConstants.defaultDrawDuration,
      difficulty: (map['difficulty'] as String?) ?? GameConstants.difficultyAll,
      category: (map['category'] as String?) ?? GameConstants.categoryAll,
      isPublic: (map['isPublic'] as bool?) ?? true,
    );
  }
}

class RoomModel {
  final String id;
  final String name;
  final String hostId;
  final String status;
  final RoomConfig config;
  final int currentRound;
  final int turnIndex;
  final String? currentDrawerId;
  final String? currentDrawerName;
  final int wordLength;
  final String wordHint;
  final int? roundStartTime;
  final int? roundEndTime;
  final String? winnerId;
  final String? winnerName;
  final String? lastCorrectWord;
  final List<String> wordChoices;
  final Map<String, PlayerModel> players;
  final int createdAt;

  const RoomModel({
    required this.id,
    required this.name,
    required this.hostId,
    this.status = GameConstants.statusLobby,
    this.config = const RoomConfig(),
    this.currentRound = 1,
    this.turnIndex = 0,
    this.currentDrawerId,
    this.currentDrawerName,
    this.wordLength = 0,
    this.wordHint = '',
    this.roundStartTime,
    this.roundEndTime,
    this.winnerId,
    this.winnerName,
    this.lastCorrectWord,
    this.wordChoices = const [],
    this.players = const {},
    this.createdAt = 0,
  });

  int get playerCount => players.length;

  bool isHost(String uid) => hostId == uid;

  bool isCurrentDrawer(String uid) => currentDrawerId == uid;

  PlayerModel? get host => players[hostId];

  PlayerModel? get currentDrawer => currentDrawerId != null ? players[currentDrawerId] : null;

  List<PlayerModel> get playerList {
    final list = players.values.toList();
    list.sort((a, b) => b.score.compareTo(a.score));
    return list;
  }

  bool get canStartGame {
    return players.length >= GameConstants.minPlayers &&
        players.values.where((p) => !p.isHost).every((p) => p.isReady);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'hostId': hostId,
      'status': status,
      'config': config.toMap(),
      'currentRound': currentRound,
      'turnIndex': turnIndex,
      'currentDrawerId': currentDrawerId,
      'currentDrawerName': currentDrawerName,
      'wordLength': wordLength,
      'wordHint': wordHint,
      'roundStartTime': roundStartTime,
      'roundEndTime': roundEndTime,
      'winnerId': winnerId,
      'winnerName': winnerName,
      'lastCorrectWord': lastCorrectWord,
      'wordChoices': wordChoices,
      'createdAt': createdAt,
    };
  }

  factory RoomModel.fromMap(Map<dynamic, dynamic> map, String id) {
    final rawPlayers = map['players'];
    final playersMap = <String, PlayerModel>{};

    if (rawPlayers is Map) {
      rawPlayers.forEach((key, val) {
        if (val is Map) {
          playersMap[key.toString()] = PlayerModel.fromMap(val, key.toString());
        }
      });
    }

    final rawChoices = map['wordChoices'];
    final choices = <String>[];
    if (rawChoices is List) {
      for (var c in rawChoices) {
        if (c != null) choices.add(c.toString());
      }
    }

    return RoomModel(
      id: id,
      name: (map['name'] as String?) ?? 'Doodlio Room',
      hostId: (map['hostId'] as String?) ?? '',
      status: (map['status'] as String?) ?? GameConstants.statusLobby,
      config: RoomConfig.fromMap(map['config'] as Map<dynamic, dynamic>?),
      currentRound: (map['currentRound'] as num?)?.toInt() ?? 1,
      turnIndex: (map['turnIndex'] as num?)?.toInt() ?? 0,
      currentDrawerId: map['currentDrawerId'] as String?,
      currentDrawerName: map['currentDrawerName'] as String?,
      wordLength: (map['wordLength'] as num?)?.toInt() ?? 0,
      wordHint: (map['wordHint'] as String?) ?? '',
      roundStartTime: (map['roundStartTime'] as num?)?.toInt(),
      roundEndTime: (map['roundEndTime'] as num?)?.toInt(),
      winnerId: map['winnerId'] as String?,
      winnerName: map['winnerName'] as String?,
      lastCorrectWord: map['lastCorrectWord'] as String?,
      wordChoices: choices,
      players: playersMap,
      createdAt: (map['createdAt'] as num?)?.toInt() ?? 0,
    );
  }
}

