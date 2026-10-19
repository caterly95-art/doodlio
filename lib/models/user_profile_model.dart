import '../core/constants/game_constants.dart';

class UserProfileModel {
  final String uid;
  final String displayName;
  final String? email;
  final int avatarIndex;
  final bool isAnonymous;
  final int totalGames;
  final int wins;
  final int totalScore;
  final int correctGuesses;
  final int totalDrawings;
  final int createdAt;
  final int lastLoginAt;

  const UserProfileModel({
    required this.uid,
    required this.displayName,
    this.email,
    this.avatarIndex = 0,
    this.isAnonymous = false,
    this.totalGames = 0,
    this.wins = 0,
    this.totalScore = 0,
    this.correctGuesses = 0,
    this.totalDrawings = 0,
    this.createdAt = 0,
    this.lastLoginAt = 0,
  });

  String get avatar {
    if (avatarIndex >= 0 && avatarIndex < GameConstants.avatars.length) {
      return GameConstants.avatars[avatarIndex];
    }
    return GameConstants.avatars[0];
  }

  double get winRate {
    if (totalGames == 0) return 0.0;
    return (wins / totalGames) * 100.0;
  }

  double get accuracy {
    if (totalGames == 0) return 0.0;
    // Estimated average correct guesses per game
    final ratio = (correctGuesses / (totalGames * 3)) * 100.0;
    return ratio.clamp(0.0, 100.0);
  }

  UserProfileModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    int? avatarIndex,
    bool? isAnonymous,
    int? totalGames,
    int? wins,
    int? totalScore,
    int? correctGuesses,
    int? totalDrawings,
    int? createdAt,
    int? lastLoginAt,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      totalGames: totalGames ?? this.totalGames,
      wins: wins ?? this.wins,
      totalScore: totalScore ?? this.totalScore,
      correctGuesses: correctGuesses ?? this.correctGuesses,
      totalDrawings: totalDrawings ?? this.totalDrawings,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'avatarIndex': avatarIndex,
      'isAnonymous': isAnonymous,
      'totalGames': totalGames,
      'wins': wins,
      'totalScore': totalScore,
      'correctGuesses': correctGuesses,
      'totalDrawings': totalDrawings,
      'createdAt': createdAt,
      'lastLoginAt': lastLoginAt,
    };
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfileModel(
      uid: uid,
      displayName: (map['displayName'] as String?) ?? 'Doodler',
      email: map['email'] as String?,
      avatarIndex: (map['avatarIndex'] as num?)?.toInt() ?? 0,
      isAnonymous: (map['isAnonymous'] as bool?) ?? false,
      totalGames: (map['totalGames'] as num?)?.toInt() ?? 0,
      wins: (map['wins'] as num?)?.toInt() ?? 0,
      totalScore: (map['totalScore'] as num?)?.toInt() ?? 0,
      correctGuesses: (map['correctGuesses'] as num?)?.toInt() ?? 0,
      totalDrawings: (map['totalDrawings'] as num?)?.toInt() ?? 0,
      createdAt: (map['createdAt'] as num?)?.toInt() ?? 0,
      lastLoginAt: (map['lastLoginAt'] as num?)?.toInt() ?? 0,
    );
  }
}

