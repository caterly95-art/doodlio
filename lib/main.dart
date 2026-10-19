import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'app.dart';
import 'services/preferences_service.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/realtime_database_service.dart';
import 'services/game_service.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/drawing_provider.dart';
import 'providers/game_provider.dart';
import 'providers/leaderboard_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with borrow-e7211 credentials
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }

  // Initialize SharedPreferences
  final prefsService = await PreferencesService.init();

  // Instantiate services
  final authService = AuthService();
  final firestoreService = FirestoreService();
  final rtdbService = RealtimeDatabaseService();
  final gameService = GameService(rtdbService, firestoreService);

  runApp(
    MultiProvider(
      providers: [
        Provider<PreferencesService>.value(value: prefsService),
        Provider<AuthService>.value(value: authService),
        Provider<FirestoreService>.value(value: firestoreService),
        Provider<RealtimeDatabaseService>.value(value: rtdbService),
        Provider<GameService>.value(value: gameService),

        ChangeNotifierProvider(
          create: (_) => SettingsProvider(prefsService),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService, firestoreService, prefsService),
        ),
        ChangeNotifierProvider(
          create: (_) => DrawingProvider(rtdbService),
        ),
        ChangeNotifierProvider(
          create: (_) => GameProvider(rtdbService, gameService),
        ),
        ChangeNotifierProvider(
          create: (_) => LeaderboardProvider(firestoreService),
        ),
      ],
      child: const DoodlioApp(),
    ),
  );
}
