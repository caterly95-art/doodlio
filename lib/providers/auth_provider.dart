import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/preferences_service.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestoreService;
  final PreferencesService _prefs;

  AuthStatus _status = AuthStatus.uninitialized;
  UserProfileModel? _profile;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<User?>? _authSubscription;

  AuthProvider(this._authService, this._firestoreService, this._prefs) {
    _init();
  }

  AuthStatus get status => _status;
  UserProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _profile != null;
  bool get isGuest => _authService.isAnonymous;
  String get uid => _profile?.uid ?? _authService.currentUser?.uid ?? '';
  String get displayName => _profile?.displayName ?? 'Doodler';
  int get avatarIndex => _profile?.avatarIndex ?? 0;
  String get avatar => _profile?.avatar ?? '🦊';

  void _init() {
    _authSubscription = _authService.authStateChanges.listen((user) async {
      if (user != null) {
        await _loadProfile(user);
        _status = AuthStatus.authenticated;
      } else {
        _profile = null;
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  Future<void> _loadProfile(User user) async {
    final savedName = _prefs.savedDisplayName ?? user.displayName ?? 'Doodler';
    final savedAvatar = _prefs.savedAvatarIndex;

    _profile = await _firestoreService.getOrCreateUserProfile(
      uid: user.uid,
      displayName: savedName,
      email: user.email,
      avatarIndex: savedAvatar,
      isAnonymous: user.isAnonymous,
    );
    notifyListeners();
  }

  /// Guest Play with Anonymous Firebase Identity
  Future<bool> playAsGuest({String? name, int? avatarIndex}) async {
    _setLoading(true);
    _clearError();
    try {
      final finalName = (name != null && name.trim().isNotEmpty)
          ? name.trim()
          : (_prefs.savedDisplayName ?? 'Guest_${DateTime.now().millisecondsSinceEpoch % 10000}');
      final finalAvatar = avatarIndex ?? _prefs.savedAvatarIndex;

      final cred = await _authService.signInAnonymously(displayName: finalName);
      if (cred.user != null) {
        _prefs.savedDisplayName = finalName;
        _prefs.savedAvatarIndex = finalAvatar;

        _profile = await _firestoreService.getOrCreateUserProfile(
          uid: cred.user!.uid,
          displayName: finalName,
          avatarIndex: finalAvatar,
          isAnonymous: true,
        );
        _status = AuthStatus.authenticated;
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
    return false;
  }

  /// Sign In with Email & Password
  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      final cred = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (cred.user != null) {
        await _loadProfile(cred.user!);
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
    return false;
  }

  /// Register new user with Email & Password
  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    required int avatarIndex,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final cred = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      if (cred.user != null) {
        _prefs.savedDisplayName = displayName;
        _prefs.savedAvatarIndex = avatarIndex;

        _profile = await _firestoreService.getOrCreateUserProfile(
          uid: cred.user!.uid,
          displayName: displayName,
          email: email,
          avatarIndex: avatarIndex,
          isAnonymous: false,
        );
        _status = AuthStatus.authenticated;
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
    return false;
  }

  /// Send password reset email
  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Update Profile Details (display name, avatar)
  Future<void> updateProfile({
    required String displayName,
    required int avatarIndex,
  }) async {
    if (_profile == null) return;
    final updated = _profile!.copyWith(
      displayName: displayName,
      avatarIndex: avatarIndex,
    );
    _profile = updated;
    _prefs.savedDisplayName = displayName;
    _prefs.savedAvatarIndex = avatarIndex;
    notifyListeners();

    await _authService.updateDisplayName(displayName);
    await _firestoreService.updateProfileDetails(
      uid: updated.uid,
      displayName: displayName,
      avatarIndex: avatarIndex,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);
    await _authService.signOut();
    _profile = null;
    _status = AuthStatus.unauthenticated;
    _setLoading(false);
  }

  /// Delete account
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.deleteAccount();
      _profile = null;
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

