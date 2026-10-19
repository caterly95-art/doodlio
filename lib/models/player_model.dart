import '../core/constants/game_constants.dart';

class PlayerModel {
  final String uid;
  final String displayName;
  final int avatarIndex;
  final int score;
  final int roundScore;
  final bool isHost;
  final bool isReady;
  final bool hasGuessed;
  final int? guessedAt;
  final bool isOnline;
  final int lastActive;

  const PlayerModel({
    required this.uid,
    required this.displayName,
    this.avatarIndex = 0,
    this.score = 0,
    this.roundScore = 0,
    this.isHost = false,
    this.isReady = false,
    this.hasGuessed = false,
    this.guessedAt,
    this.isOnline = true,
    this.lastActive = 0,
  });

  String get avatar {
    if (avatarIndex >= 0 && avatarIndex < GameConstants.avatars.length) {
      return GameConstants.avatars[avatarIndex];
    }
    return GameConstants.avatars[0];
  }

  PlayerModel copyWith({
    String? uid,
    String? displayName,
    int? avatarIndex,
    int? score,
    int? roundScore,
    bool? isHost,
    bool? isReady,
    bool? hasGuessed,
    int? guessedAt,
    bool? isOnline,
    int? lastActive,
  }) {
    return PlayerModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      score: score ?? this.score,
      roundScore: roundScore ?? this.roundScore,
      isHost: isHost ?? this.isHost,
      isReady: isReady ?? this.isReady,
      hasGuessed: hasGuessed ?? this.hasGuessed,
      guessedAt: guessedAt ?? this.guessedAt,
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'avatarIndex': avatarIndex,
      'score': score,
      'roundScore': roundScore,
      'isHost': isHost,
      'isReady': isReady,
      'hasGuessed': hasGuessed,
      'guessedAt': guessedAt,
      'isOnline': isOnline,
      'lastActive': lastActive,
    };
  }

  factory PlayerModel.fromMap(Map<dynamic, dynamic> map, String uid) {
    return PlayerModel(
      uid: uid,
      displayName: (map['displayName'] as String?) ?? 'Player',
      avatarIndex: (map['avatarIndex'] as num?)?.toInt() ?? 0,
      score: (map['score'] as num?)?.toInt() ?? 0,
      roundScore: (map['roundScore'] as num?)?.toInt() ?? 0,
      isHost: (map['isHost'] as bool?) ?? false,
      isReady: (map['isReady'] as bool?) ?? false,
      hasGuessed: (map['hasGuessed'] as bool?) ?? false,
      guessedAt: (map['guessedAt'] as num?)?.toInt(),
      isOnline: (map['isOnline'] as bool?) ?? true,
      lastActive: (map['lastActive'] as num?)?.toInt() ?? 0,
    );
  }
}

