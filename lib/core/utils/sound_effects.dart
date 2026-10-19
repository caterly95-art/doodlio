import 'package:flutter/services.dart';

class SoundEffectsHelper {
  static bool soundEnabled = true;

  static Future<void> playClick() async {
    if (!soundEnabled) return;
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  static Future<void> playAlert() async {
    if (!soundEnabled) return;
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
  }

  static Future<void> playSuccess() async {
    if (!soundEnabled) return;
    try {
      await SystemSound.play(SystemSoundType.click);
      await Future.delayed(const Duration(milliseconds: 60));
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  static Future<void> playTick() async {
    if (!soundEnabled) return;
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }
}

