import 'package:flutter_test/flutter_test.dart';
import 'package:doodlio/core/constants/game_constants.dart';
import 'package:doodlio/core/utils/word_repository.dart';
import 'package:doodlio/models/player_model.dart';
import 'package:doodlio/models/room_model.dart';
import 'package:doodlio/models/draw_stroke_model.dart';

void main() {
  group('Word Validation & Hint Tests', () {
    test('Word normalization handles cases, spaces, and punctuation', () {
      expect(WordRepository.normalize('  Pencil! '), 'pencil');
      expect(WordRepository.normalize('Ice-Cream'), 'icecream');
      expect(WordRepository.normalize('SPAGHETTI   '), 'spaghetti');
    });

    test('Exact match accurately recognizes guesses regardless of case', () {
      expect(WordRepository.isExactMatch('guitar', 'GUITAR'), isTrue);
      expect(WordRepository.isExactMatch('   GuItAr   ', 'guitar'), isTrue);
      expect(WordRepository.isExactMatch('piano', 'guitar'), isFalse);
    });

    test('Close guess detects 1 typo for words longer than 3 characters', () {
      expect(WordRepository.isCloseGuess('guitor', 'guitar'), isTrue);
      expect(WordRepository.isCloseGuess('gitar', 'guitar'), isTrue);
      expect(WordRepository.isCloseGuess('guitarr', 'guitar'), isTrue);
      // Not close for completely different words or small words
      expect(WordRepository.isCloseGuess('cat', 'dog'), isFalse);
      expect(WordRepository.isCloseGuess('cot', 'cat'), isFalse); // length <= 3
    });

    test('Progressive hints reveal blanks and progressive letters', () {
      final initialHint = WordRepository.generateProgressiveHint('PENCIL', 1.0);
      expect(initialHint, '_ _ _ _ _ _');

      final midHint = WordRepository.generateProgressiveHint('PENCIL', 0.5);
      expect(midHint.contains('P'), isTrue); // reveals first letter
      expect(midHint.contains('_'), isTrue);

      final lateHint = WordRepository.generateProgressiveHint('PENCIL', 0.2);
      expect(lateHint.replaceAll(' ', '').length, 6);
      expect(lateHint.split(' ').where((c) => c != '_').length, greaterThanOrEqualTo(2));
    });

    test('Spoiler protection masks the secret word inside chat text', () {
      final masked = WordRepository.maskSpoiler('The answer is apple for sure', 'apple');
      expect(masked, 'The answer is *** for sure');

      final caseInsensitiveMasked = WordRepository.maskSpoiler('Is it APPLE?', 'apple');
      expect(caseInsensitiveMasked, 'Is it ***?');
    });

    test('Random word choice generator returns distinct valid words', () {
      final choices = WordRepository.getRandomWordChoices(
        category: GameConstants.categoryAnimals,
        difficulty: GameConstants.difficultyEasy,
        count: 3,
      );
      expect(choices.length, 3);
      expect(choices.toSet().length, 3); // All distinct
    });
  });

  group('Scoring System Tests', () {
    test('Calculates maximum points when guessed immediately', () {
      const remainingMs = 60000;
      const totalDurationMs = 60000;
      const fraction = remainingMs / totalDurationMs;

      final points = GameConstants.minGuessPoints +
          (fraction * (GameConstants.maxGuessPoints - GameConstants.minGuessPoints)).round();

      expect(points, GameConstants.maxGuessPoints); // 500 points
    });

    test('Calculates minimum points when guessed at the last second', () {
      const remainingMs = 0;
      const totalDurationMs = 60000;
      const fraction = remainingMs / totalDurationMs;

      final points = GameConstants.minGuessPoints +
          (fraction * (GameConstants.maxGuessPoints - GameConstants.minGuessPoints)).round();

      expect(points, GameConstants.minGuessPoints); // 100 points
    });

    test('Drawer bonus awards points per successful guesser', () {
      var drawerScore = 0;
      const guesserCount = 3;

      for (int i = 0; i < guesserCount; i++) {
        drawerScore += GameConstants.drawerBonusPerGuesser;
      }

      expect(drawerScore, 3 * 75); // 225 points
    });
  });

  group('Game State & Model Transitions Tests', () {
    test('RoomModel initializes properly and identifies host', () {
      final host = const PlayerModel(
        uid: 'user_1',
        displayName: 'Alice',
        isHost: true,
        isReady: true,
      );

      final room = RoomModel(
        id: 'ABCDEF',
        name: "Alice's Room",
        hostId: host.uid,
        players: {host.uid: host},
      );

      expect(room.isHost('user_1'), isTrue);
      expect(room.isHost('user_2'), isFalse);
      expect(room.canStartGame, isFalse); // Only 1 player, needs min 2
    });

    test('Room can start game only when minimum 2 players are present and ready', () {
      final host = const PlayerModel(
        uid: 'user_1',
        displayName: 'Alice',
        isHost: true,
        isReady: true,
      );
      final player2 = const PlayerModel(
        uid: 'user_2',
        displayName: 'Bob',
        isHost: false,
        isReady: false,
      );

      final roomNotReady = RoomModel(
        id: 'ABCDEF',
        name: "Alice's Room",
        hostId: host.uid,
        players: {host.uid: host, player2.uid: player2},
      );
      expect(roomNotReady.canStartGame, isFalse); // Bob is not ready

      final readyPlayer2 = player2.copyWith(isReady: true);
      final roomReady = RoomModel(
        id: 'ABCDEF',
        name: "Alice's Room",
        hostId: host.uid,
        players: {host.uid: host, readyPlayer2.uid: readyPlayer2},
      );
      expect(roomReady.canStartGame, isTrue); // Both ready!
    });

    test('DrawStroke coordinates serialize and deserialize accurately', () {
      final stroke = DrawStroke(
        id: 'stroke_1',
        points: const [DrawPoint(0.25, 0.5), DrawPoint(0.3, 0.55)],
        colorValue: 0xFFFF7A30,
        strokeWidth: 4.0,
        timestamp: 123456789,
        order: 1,
        drawerId: 'user_1',
      );

      final map = stroke.toMap();
      final reconstructed = DrawStroke.fromMap(map, 'stroke_1');

      expect(reconstructed.id, 'stroke_1');
      expect(reconstructed.points.length, 2);
      expect(reconstructed.points.first.x, 0.25);
      expect(reconstructed.points.first.y, 0.5);
      expect(reconstructed.colorValue, 0xFFFF7A30);
      expect(reconstructed.drawerId, 'user_1');
    });

    test('Player ranking correctly sorts highest scores first', () {
      final p1 = const PlayerModel(uid: '1', displayName: 'P1', score: 200);
      final p2 = const PlayerModel(uid: '2', displayName: 'P2', score: 650);
      final p3 = const PlayerModel(uid: '3', displayName: 'P3', score: 400);

      final room = RoomModel(
        id: 'TEST12',
        name: 'Test Room',
        hostId: '1',
        players: {'1': p1, '2': p2, '3': p3},
      );

      final sorted = room.playerList;
      expect(sorted[0].uid, '2'); // 650 pts
      expect(sorted[1].uid, '3'); // 400 pts
      expect(sorted[2].uid, '1'); // 200 pts
    });
  });
}

