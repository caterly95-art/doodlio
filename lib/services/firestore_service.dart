import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _matchesCol =>
      _firestore.collection('matches');

  /// Fetch or initialize user profile
  Future<UserProfileModel> getOrCreateUserProfile({
    required String uid,
    required String displayName,
    String? email,
    int avatarIndex = 0,
    bool isAnonymous = false,
  }) async {
    try {
      final doc = await _usersCol.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserProfileModel.fromMap(doc.data()!, uid);
      } else {
        final now = DateTime.now().millisecondsSinceEpoch;
        final newProfile = UserProfileModel(
          uid: uid,
          displayName: displayName,
          email: email,
          avatarIndex: avatarIndex,
          isAnonymous: isAnonymous,
          totalGames: 0,
          wins: 0,
          totalScore: 0,
          correctGuesses: 0,
          totalDrawings: 0,
          createdAt: now,
          lastLoginAt: now,
        );
        await _usersCol.doc(uid).set(newProfile.toMap());
        return newProfile;
      }
    } catch (_) {
      // Return local fallback model if offline or initial setup
      return UserProfileModel(
        uid: uid,
        displayName: displayName,
        email: email,
        avatarIndex: avatarIndex,
        isAnonymous: isAnonymous,
      );
    }
  }

  /// Update user profile details (name, avatar)
  Future<void> updateProfileDetails({
    required String uid,
    required String displayName,
    required int avatarIndex,
  }) async {
    try {
      await _usersCol.doc(uid).update({
        'displayName': displayName,
        'avatarIndex': avatarIndex,
        'lastLoginAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (_) {}
  }

  /// Update player stats upon match completion
  Future<void> updateMatchStats({
    required String uid,
    required bool won,
    required int pointsGained,
    required int correctGuessesGained,
    required int drawingsGained,
  }) async {
    try {
      await _usersCol.doc(uid).set({
        'totalGames': FieldValue.increment(1),
        'wins': FieldValue.increment(won ? 1 : 0),
        'totalScore': FieldValue.increment(pointsGained),
        'correctGuesses': FieldValue.increment(correctGuessesGained),
        'totalDrawings': FieldValue.increment(drawingsGained),
        'lastLoginAt': DateTime.now().millisecondsSinceEpoch,
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  /// Stream user profile
  Stream<UserProfileModel?> streamUserProfile(String uid) {
    return _usersCol.doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserProfileModel.fromMap(doc.data()!, uid);
      }
      return null;
    });
  }

  /// Get global leaderboard (Top scorers)
  Future<List<UserProfileModel>> getGlobalLeaderboard({int limit = 50}) async {
    try {
      final snapshot = await _usersCol
          .orderBy('totalScore', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => UserProfileModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Save completed match history
  Future<void> saveMatchHistory({
    required String roomId,
    required String winnerId,
    required String winnerName,
    required int roundsPlayed,
    required Map<String, int> playerScores,
  }) async {
    try {
      await _matchesCol.add({
        'roomId': roomId,
        'winnerId': winnerId,
        'winnerName': winnerName,
        'roundsPlayed': roundsPlayed,
        'playerScores': playerScores,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }
}

