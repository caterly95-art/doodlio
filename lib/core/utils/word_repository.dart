import 'dart:math';
import '../constants/game_constants.dart';

class WordItem {
  final String word;
  final String category;
  final String difficulty;
  final String hint;

  const WordItem({
    required this.word,
    required this.category,
    required this.difficulty,
    required this.hint,
  });
}

class WordRepository {
  static final Random _random = Random();

  static const List<WordItem> allWords = [
    // Everyday Objects - Easy
    WordItem(word: 'pencil', category: GameConstants.categoryObjects, difficulty: GameConstants.difficultyEasy, hint: 'Writing instrument'),
    WordItem(word: 'clock', category: GameConstants.categoryObjects, difficulty: GameConstants.difficultyEasy, hint: 'Tells time'),
    WordItem(word: 'cup', category: GameConstants.categoryObjects, difficulty: GameConstants.difficultyEasy, hint: 'Used for drinking'),
    WordItem(word: 'door', category: GameConstants.categoryObjects, difficulty: GameConstants.difficultyEasy, hint: 'Entrance to a room'),
    WordItem(word: 'chair', category: GameConstants.categoryObjects, difficulty: GameConstants.difficultyEasy, hint: 'You sit on it'),
    WordItem(word: 'bed', category: GameConstants.categoryObjects, difficulty: GameConstants.difficultyEasy, hint: 'Where you sleep'),
    WordItem(word: 'shoe', category: GameConstants.categoryObjects, difficulty: GameConstants.difficultyEasy, hint: 'Footwear'),
    WordItem(word: 'book', category: GameConstants.categoryObjects, difficulty: GameConstants.difficultyEasy, hint: 'Has pages and stories'),
    WordItem(word: 'umbrella', category: GameConstants.categoryObjects, difficulty: GameConstants.difficultyEasy, hint: 'Protects from rain'),
    WordItem(word: 'mirror', category: GameConstants.categoryObjects, difficulty: GameConstants.difficultyEasy, hint: 'Reflects your face'),
    WordItem(word: 'scissors', category: GameConstants.categoryObjects, difficulty: GameConstants.difficultyEasy, hint: 'Used for cutting paper'),
    WordItem(word: 'key', category: GameConstants.categoryObjects, difficulty: GameConstants.difficultyEasy, hint: 'Unlocks doors'),
    WordItem(word: 'guitar', category: GameConstants.categoryObjects, difficulty: GameConstants.difficultyEasy, hint: 'String musical instrument'),

    // Everyday Objects - Medium & Hard
    WordItem(word: 'hourglass', category: GameConstants.categoryObjects, difficulty: GameConstants.difficultyMedium, hint: 'Measures time with sand'),
    WordItem(word: 'telescope', category: GameConstants.categoryObjects, difficulty: GameConstants.difficultyMedium, hint: 'Looks at distant stars'),
    WordItem(word: 'chandelier', category: GameConstants.categoryObjects, difficulty: GameConstants.difficultyHard, hint: 'Fancy hanging ceiling light'),
    WordItem(word: 'microscope', category: GameConstants.categoryObjects, difficulty: GameConstants.difficultyMedium, hint: 'Looks at tiny cells'),
    WordItem(word: 'stethoscope', category: GameConstants.categoryObjects, difficulty: GameConstants.difficultyHard, hint: 'Doctor checks heartbeat'),
    WordItem(word: 'harmonica', category: GameConstants.categoryObjects, difficulty: GameConstants.difficultyMedium, hint: 'Small wind instrument'),
    WordItem(word: 'compass', category: GameConstants.categoryObjects, difficulty: GameConstants.difficultyMedium, hint: 'Points north'),

    // Animals - Easy
    WordItem(word: 'cat', category: GameConstants.categoryAnimals, difficulty: GameConstants.difficultyEasy, hint: 'Meowing pet'),
    WordItem(word: 'dog', category: GameConstants.categoryAnimals, difficulty: GameConstants.difficultyEasy, hint: 'Barking best friend'),
    WordItem(word: 'fish', category: GameConstants.categoryAnimals, difficulty: GameConstants.difficultyEasy, hint: 'Swims in water'),
    WordItem(word: 'duck', category: GameConstants.categoryAnimals, difficulty: GameConstants.difficultyEasy, hint: 'Quacks and swims'),
    WordItem(word: 'lion', category: GameConstants.categoryAnimals, difficulty: GameConstants.difficultyEasy, hint: 'King of the jungle'),
    WordItem(word: 'elephant', category: GameConstants.categoryAnimals, difficulty: GameConstants.difficultyEasy, hint: 'Huge mammal with a trunk'),
    WordItem(word: 'penguin', category: GameConstants.categoryAnimals, difficulty: GameConstants.difficultyEasy, hint: 'Flightless bird in cold ice'),
    WordItem(word: 'rabbit', category: GameConstants.categoryAnimals, difficulty: GameConstants.difficultyEasy, hint: 'Hops and loves carrots'),
    WordItem(word: 'monkey', category: GameConstants.categoryAnimals, difficulty: GameConstants.difficultyEasy, hint: 'Climbs trees and loves bananas'),
    WordItem(word: 'snake', category: GameConstants.categoryAnimals, difficulty: GameConstants.difficultyEasy, hint: 'Legless reptile'),

    // Animals - Medium & Hard
    WordItem(word: 'chameleon', category: GameConstants.categoryAnimals, difficulty: GameConstants.difficultyMedium, hint: 'Changes color to blend in'),
    WordItem(word: 'kangaroo', category: GameConstants.categoryAnimals, difficulty: GameConstants.difficultyMedium, hint: 'Carries baby in pouch'),
    WordItem(word: 'platypus', category: GameConstants.categoryAnimals, difficulty: GameConstants.difficultyHard, hint: 'Semi-aquatic duck-billed mammal'),
    WordItem(word: 'hedgehog', category: GameConstants.categoryAnimals, difficulty: GameConstants.difficultyMedium, hint: 'Spiky cute small animal'),
    WordItem(word: 'flamingo', category: GameConstants.categoryAnimals, difficulty: GameConstants.difficultyMedium, hint: 'Tall pink bird on one leg'),
    WordItem(word: 'octopus', category: GameConstants.categoryAnimals, difficulty: GameConstants.difficultyMedium, hint: 'Eight tentacled sea creature'),

    // Food - Easy
    WordItem(word: 'pizza', category: GameConstants.categoryFood, difficulty: GameConstants.difficultyEasy, hint: 'Cheesy round slice'),
    WordItem(word: 'burger', category: GameConstants.categoryFood, difficulty: GameConstants.difficultyEasy, hint: 'Patty between buns'),
    WordItem(word: 'apple', category: GameConstants.categoryFood, difficulty: GameConstants.difficultyEasy, hint: 'Red sweet fruit'),
    WordItem(word: 'banana', category: GameConstants.categoryFood, difficulty: GameConstants.difficultyEasy, hint: 'Yellow curved fruit'),
    WordItem(word: 'cookie', category: GameConstants.categoryFood, difficulty: GameConstants.difficultyEasy, hint: 'Baked sweet snack with choc chips'),
    WordItem(word: 'taco', category: GameConstants.categoryFood, difficulty: GameConstants.difficultyEasy, hint: 'Crispy folded Mexican dish'),
    WordItem(word: 'ice cream', category: GameConstants.categoryFood, difficulty: GameConstants.difficultyEasy, hint: 'Cold frozen sweet dessert in cone'),
    WordItem(word: 'donut', category: GameConstants.categoryFood, difficulty: GameConstants.difficultyEasy, hint: 'Sweet ring with hole in middle'),

    // Food - Medium & Hard
    WordItem(word: 'sushi', category: GameConstants.categoryFood, difficulty: GameConstants.difficultyMedium, hint: 'Japanese seaweed rice roll'),
    WordItem(word: 'croissant', category: GameConstants.categoryFood, difficulty: GameConstants.difficultyMedium, hint: 'Flaky crescent French pastry'),
    WordItem(word: 'spaghetti', category: GameConstants.categoryFood, difficulty: GameConstants.difficultyMedium, hint: 'Long noodles with red sauce'),
    WordItem(word: 'avocado', category: GameConstants.categoryFood, difficulty: GameConstants.difficultyMedium, hint: 'Green fruit with big seed'),
    WordItem(word: 'marshmallow', category: GameConstants.categoryFood, difficulty: GameConstants.difficultyHard, hint: 'Fluffy white campfire sweet'),

    // Movies & Entertainment - Easy & Medium
    WordItem(word: 'popcorn', category: GameConstants.categoryMovies, difficulty: GameConstants.difficultyEasy, hint: 'Movie theater snack'),
    WordItem(word: 'cinema', category: GameConstants.categoryMovies, difficulty: GameConstants.difficultyEasy, hint: 'Place where movies play'),
    WordItem(word: 'superhero', category: GameConstants.categoryMovies, difficulty: GameConstants.difficultyEasy, hint: 'Wears a cape and saves the day'),
    WordItem(word: 'pirate', category: GameConstants.categoryMovies, difficulty: GameConstants.difficultyEasy, hint: 'Sails ship with eye patch'),
    WordItem(word: 'director', category: GameConstants.categoryMovies, difficulty: GameConstants.difficultyMedium, hint: 'Shouts action and cut'),
    WordItem(word: 'spaceship', category: GameConstants.categoryMovies, difficulty: GameConstants.difficultyEasy, hint: 'Travels to the galaxy'),
    WordItem(word: 'wizard', category: GameConstants.categoryMovies, difficulty: GameConstants.difficultyEasy, hint: 'Casts spells with a wand'),
    WordItem(word: 'lightsaber', category: GameConstants.categoryMovies, difficulty: GameConstants.difficultyHard, hint: 'Glowing plasma sword'),

    // Technology - Easy & Medium
    WordItem(word: 'phone', category: GameConstants.categoryTech, difficulty: GameConstants.difficultyEasy, hint: 'Pocket touch device'),
    WordItem(word: 'laptop', category: GameConstants.categoryTech, difficulty: GameConstants.difficultyEasy, hint: 'Portable computer'),
    WordItem(word: 'robot', category: GameConstants.categoryTech, difficulty: GameConstants.difficultyEasy, hint: 'Automated mechanical humanoid'),
    WordItem(word: 'battery', category: GameConstants.categoryTech, difficulty: GameConstants.difficultyEasy, hint: 'Stores electrical power'),
    WordItem(word: 'headphone', category: GameConstants.categoryTech, difficulty: GameConstants.difficultyEasy, hint: 'Wear over ears to listen to music'),
    WordItem(word: 'satellite', category: GameConstants.categoryTech, difficulty: GameConstants.difficultyMedium, hint: 'Orbits planet in space'),
    WordItem(word: 'keyboard', category: GameConstants.categoryTech, difficulty: GameConstants.difficultyEasy, hint: 'Type keys for letters'),
    WordItem(word: 'joystick', category: GameConstants.categoryTech, difficulty: GameConstants.difficultyMedium, hint: 'Control stick for video games'),
    WordItem(word: 'microchip', category: GameConstants.categoryTech, difficulty: GameConstants.difficultyHard, hint: 'Tiny silicon circuit processor'),
  ];

  /// Get random distinct word choices for a drawer turn
  static List<String> getRandomWordChoices({
    String category = GameConstants.categoryAll,
    String difficulty = GameConstants.difficultyAll,
    int count = 3,
  }) {
    List<WordItem> pool = allWords;

    if (category != GameConstants.categoryAll) {
      pool = pool.where((w) => w.category == category).toList();
    }
    if (difficulty != GameConstants.difficultyAll) {
      pool = pool.where((w) => w.difficulty == difficulty).toList();
    }

    if (pool.length < count) {
      pool = allWords;
    }

    final shuffled = List<WordItem>.from(pool)..shuffle(_random);
    final selected = shuffled.take(count).map((w) => w.word.toUpperCase()).toList();
    return selected;
  }

  /// Normalize string by trimming, removing extra spaces and punctuation
  static String normalize(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Check whether guess matches secret word
  static bool isExactMatch(String guess, String secretWord) {
    return normalize(guess) == normalize(secretWord);
  }

  /// Check if the guess is very close (1 typo distance)
  static bool isCloseGuess(String guess, String secretWord) {
    final g = normalize(guess);
    final s = normalize(secretWord);
    if (g == s || s.length <= 3) return false;
    return _levenshteinDistance(g, s) == 1;
  }

  /// Generate progressive hint with underscores and revealed letters
  /// e.g. at 50% reveals some letters, at 25% reveals more
  static String generateProgressiveHint(String secretWord, double remainingFraction) {
    final word = secretWord.toUpperCase();
    final letters = word.split('');
    final totalLetters = letters.where((c) => c != ' ').length;

    int revealCount = 0;
    if (remainingFraction < 0.3) {
      revealCount = (totalLetters * 0.6).round();
    } else if (remainingFraction < 0.6) {
      revealCount = (totalLetters * 0.3).round();
    }

    if (revealCount == 0) {
      // Just blanks: "_ _ _ _ _"
      return letters.map((c) => c == ' ' ? '   ' : '_').join(' ');
    }

    // Deterministically pick indices to reveal based on word hash
    final nonSpaceIndices = <int>[];
    for (int i = 0; i < letters.length; i++) {
      if (letters[i] != ' ') nonSpaceIndices.add(i);
    }

    // Always reveal 1st letter first if revealCount >= 1
    final indicesToReveal = <int>{};
    if (nonSpaceIndices.isNotEmpty) {
      indicesToReveal.add(nonSpaceIndices.first);
    }
    // Then reveal middle or last
    if (revealCount > 1 && nonSpaceIndices.length > 2) {
      indicesToReveal.add(nonSpaceIndices[nonSpaceIndices.length ~/ 2]);
    }
    if (revealCount > 2 && nonSpaceIndices.length > 3) {
      indicesToReveal.add(nonSpaceIndices.last);
    }

    return letters.asMap().entries.map((entry) {
      final idx = entry.key;
      final char = entry.value;
      if (char == ' ') return '   ';
      if (indicesToReveal.contains(idx)) return char;
      return '_';
    }).join(' ');
  }

  /// Calculate Levenshtein Distance for typo tolerance
  static int _levenshteinDistance(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.generate(t.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < t.length; j++) {
        final cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }
      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[t.length];
  }

  /// Mask secret word in a text message to prevent spoiling
  static String maskSpoiler(String text, String secretWord) {
    if (secretWord.trim().isEmpty) return text;
    final regex = RegExp(RegExp.escape(secretWord.trim()), caseSensitive: false);
    return text.replaceAll(regex, '***');
  }
}

