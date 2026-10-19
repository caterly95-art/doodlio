import 'package:flutter/material.dart';
import '../models/user_profile_model.dart';
import '../services/firestore_service.dart';

class LeaderboardProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  List<UserProfileModel> _topPlayers = [];
  bool _isLoading = false;
  String? _error;

  LeaderboardProvider(this._firestoreService);

  List<UserProfileModel> get topPlayers => _topPlayers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadLeaderboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _topPlayers = await _firestoreService.getGlobalLeaderboard(limit: 50);
    } catch (e) {
      _error = 'Failed to load leaderboard';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

