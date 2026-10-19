import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keySound = 'doodlio_sound_enabled';
  static const String _keyHaptics = 'doodlio_haptics_enabled';
  static const String _keyOnboardingSeen = 'doodlio_onboarding_seen';
  static const String _keyDisplayName = 'doodlio_saved_display_name';
  static const String _keyAvatarIndex = 'doodlio_saved_avatar_index';

  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static Future<PreferencesService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  bool get soundEnabled => _prefs.getBool(_keySound) ?? true;
  set soundEnabled(bool value) => _prefs.setBool(_keySound, value);

  bool get hapticsEnabled => _prefs.getBool(_keyHaptics) ?? true;
  set hapticsEnabled(bool value) => _prefs.setBool(_keyHaptics, value);

  bool get onboardingSeen => _prefs.getBool(_keyOnboardingSeen) ?? false;
  set onboardingSeen(bool value) => _prefs.setBool(_keyOnboardingSeen, value);

  String? get savedDisplayName => _prefs.getString(_keyDisplayName);
  set savedDisplayName(String? value) {
    if (value == null) {
      _prefs.remove(_keyDisplayName);
    } else {
      _prefs.setString(_keyDisplayName, value);
    }
  }

  int get savedAvatarIndex => _prefs.getInt(_keyAvatarIndex) ?? 0;
  set savedAvatarIndex(int value) => _prefs.setInt(_keyAvatarIndex, value);
}

