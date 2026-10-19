class GameConstants {
  // Room Constraints
  static const int minPlayers = 2;
  static const int maxPlayers = 8;
  static const int defaultMaxPlayers = 6;
  static const int defaultRounds = 3;
  static const int minRounds = 2;
  static const int maxRounds = 8;
  static const int defaultDrawDuration = 60; // seconds
  static const int minDrawDuration = 30;
  static const int maxDrawDuration = 120;
  static const int wordSelectionDuration = 15; // seconds
  static const int roundResultsDuration = 6; // seconds

  // Scoring Weights
  static const int maxGuessPoints = 500;
  static const int minGuessPoints = 100;
  static const int drawerBonusPerGuesser = 75;
  static const int drawerMaxBonus = 350;

  // Rate Limiting
  static const int chatRateLimitMs = 800; // max 1 message per 800ms

  // Room Statuses
  static const String statusLobby = 'lobby';
  static const String statusWordSelection = 'word_selection';
  static const String statusDrawing = 'drawing';
  static const String statusRoundResults = 'round_results';
  static const String statusGameOver = 'game_over';

  // Difficulties
  static const String difficultyEasy = 'easy';
  static const String difficultyMedium = 'medium';
  static const String difficultyHard = 'hard';
  static const String difficultyAll = 'all';

  // Categories
  static const String categoryAll = 'all';
  static const String categoryObjects = 'objects';
  static const String categoryAnimals = 'animals';
  static const String categoryFood = 'food';
  static const String categoryMovies = 'movies';
  static const String categoryTech = 'tech';

  // Available Avatar Emojis
  static const List<String> avatars = [
    '🦊', '🐱', '🐼', '🦁', '🐸', '🐨', '🦄', '🐯',
    '🐵', '🐙', '🦖', '🦉', '🐺', '🐰', '🐻', '🐲'
  ];
}

