import 'package:flutter/material.dart';

class AppColors {
  // Brand Background & Surface Colors
  static const Color background = Color(0xFF0B0C10);
  static const Color surface = Color(0xFF17191F);
  static const Color surfaceElevated = Color(0xFF1E2129);
  static const Color surfaceHover = Color(0xFF262A34);

  // Accents
  static const Color primary = Color(0xFFFF7A30); // Vivid Orange
  static const Color primaryDark = Color(0xFFE05F18);
  static const Color primaryLight = Color(0xFFFF9554);
  static const Color secondary = Color(0xFFF5F5F7); // Soft White

  // Functional & Semantic Colors
  static const Color success = Color(0xFF10B981); // Emerald Green (Correct guess)
  static const Color warning = Color(0xFFF59E0B); // Amber Yellow (Hints / Low time)
  static const Color danger = Color(0xFFEF4444);  // Crimson Red (Error / Critical time)
  static const Color info = Color(0xFF3B82F6);    // Azure Blue (System messages)

  // Typography Colors
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFF8E929D);
  static const Color textMuted = Color(0xFF5B606D);
  static const Color textInverse = Color(0xFF0B0C10);

  // Borders & Dividers
  static const Color border = Color(0xFF252932);
  static const Color borderSubtle = Color(0xFF1D2028);
  static const Color borderFocus = Color(0xFFFF7A30);

  // Canvas Palette (Curated vibrant colors for drawing)
  static const List<Color> drawingPalette = [
    Color(0xFFFFFFFF), // White
    Color(0xFF1E1E1E), // Black / Charcoal
    Color(0xFFFF7A30), // Vivid Orange
    Color(0xFFEF4444), // Crimson Red
    Color(0xFFEC4899), // Hot Pink
    Color(0xFF8B5CF6), // Royal Purple
    Color(0xFF3B82F6), // Sky Blue
    Color(0xFF10B981), // Emerald Green
    Color(0xFF84CC16), // Lime Green
    Color(0xFFFBBF24), // Sunflower Yellow
    Color(0xFF92400E), // Wood Brown
    Color(0xFF06B6D4), // Cyan
  ];

  // Avatars background colors
  static const List<Color> avatarColors = [
    Color(0xFFFF7A30),
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFFF59E0B),
    Color(0xFF06B6D4),
    Color(0xFF14B8A6),
  ];
}

