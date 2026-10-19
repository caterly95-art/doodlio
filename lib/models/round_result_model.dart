class GuesserResult {
  final String uid;
  final String name;
  final String avatar;
  final int pointsGained;
  final int guessTimeSeconds;

  const GuesserResult({
    required this.uid,
    required this.name,
    required this.avatar,
    required this.pointsGained,
    required this.guessTimeSeconds,
  });
}

class RoundResultModel {
  final int roundNumber;
  final String drawerId;
  final String drawerName;
  final String drawerAvatar;
  final String correctWord;
  final int drawerPoints;
  final List<GuesserResult> guessers;

  const RoundResultModel({
    required this.roundNumber,
    required this.drawerId,
    required this.drawerName,
    required this.drawerAvatar,
    required this.correctWord,
    required this.drawerPoints,
    required this.guessers,
  });
}

