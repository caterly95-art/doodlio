import 'package:flutter/services.dart';

class HapticHelper {
  static bool enabled = true;

  static void light() {
    if (!enabled) return;
    HapticFeedback.lightImpact();
  }

  static void medium() {
    if (!enabled) return;
    HapticFeedback.mediumImpact();
  }

  static void heavy() {
    if (!enabled) return;
    HapticFeedback.heavyImpact();
  }

  static void selection() {
    if (!enabled) return;
    HapticFeedback.selectionClick();
  }

  static void success() {
    if (!enabled) return;
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (enabled) HapticFeedback.heavyImpact();
    });
  }

  static void error() {
    if (!enabled) return;
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 80), () {
      if (enabled) HapticFeedback.heavyImpact();
    });
  }
}

