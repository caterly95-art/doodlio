import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../core/utils/sound_effects.dart';
import '../core/utils/haptic_feedback_helper.dart';

class SettingsProvider with ChangeNotifier {
  final PreferencesService _prefs;

  SettingsProvider(this._prefs) {
    SoundEffectsHelper.soundEnabled = _prefs.soundEnabled;
    HapticHelper.enabled = _prefs.hapticsEnabled;
  }

  bool get soundEnabled => _prefs.soundEnabled;
  bool get hapticsEnabled => _prefs.hapticsEnabled;
  bool get onboardingSeen => _prefs.onboardingSeen;
  String? get savedDisplayName => _prefs.savedDisplayName;
  int get savedAvatarIndex => _prefs.savedAvatarIndex;

  void setSoundEnabled(bool value) {
    _prefs.soundEnabled = value;
    SoundEffectsHelper.soundEnabled = value;
    notifyListeners();
  }

  void setHapticsEnabled(bool value) {
    _prefs.hapticsEnabled = value;
    HapticHelper.enabled = value;
    notifyListeners();
  }

  void completeOnboarding() {
    _prefs.onboardingSeen = true;
    notifyListeners();
  }

  void saveUserPreferences(String name, int avatarIndex) {
    _prefs.savedDisplayName = name;
    _prefs.savedAvatarIndex = avatarIndex;
    notifyListeners();
  }
}

