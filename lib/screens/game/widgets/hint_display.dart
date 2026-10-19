import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HintDisplay extends StatelessWidget {
  final bool isDrawer;
  final bool hasGuessed;
  final String? secretWord;
  final String hint;
  final int wordLength;

  const HintDisplay({
    super.key,
    required this.isDrawer,
    required this.hasGuessed,
    this.secretWord,
    required this.hint,
    required this.wordLength,
  });

  @override
  Widget build(BuildContext context) {
    if (isDrawer) {
      // Drawer view: reveal full word with instruction
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.brush_rounded, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            const Text(
              'DRAW: ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryLight,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              (secretWord ?? 'WORD').toUpperCase(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (hasGuessed) {
      // Guesser has already solved it
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success, width: 1.2),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
            SizedBox(width: 6),
            Text(
              'YOU GUESSED IT! 👏',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      );
    }

    // Guesser is still trying to guess
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            hint.isNotEmpty ? hint : ('_ ' * wordLength).trim(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 3.5,
              color: AppColors.textPrimary,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($wordLength)',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

