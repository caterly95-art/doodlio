import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class GameTimerBar extends StatelessWidget {
  final int currentRound;
  final int totalRounds;
  final int remainingSeconds;
  final double progress;

  const GameTimerBar({
    super.key,
    required this.currentRound,
    required this.totalRounds,
    required this.remainingSeconds,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    Color barColor = AppColors.success;
    if (progress < 0.25) {
      barColor = AppColors.danger;
    } else if (progress < 0.5) {
      barColor = AppColors.warning;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Round Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Text(
                'ROUND $currentRound / $totalRounds',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            // Timer Text
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_rounded,
                  size: 16,
                  color: barColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '$remainingSeconds s',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: barColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Animated progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 5,
            width: double.infinity,
            color: AppColors.surfaceElevated,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

