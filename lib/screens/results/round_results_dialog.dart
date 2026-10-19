import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/player_model.dart';

class RoundResultsDialog extends StatelessWidget {
  final String correctWord;
  final String drawerName;
  final String drawerAvatar;
  final List<PlayerModel> players;
  final int remainingSeconds;

  const RoundResultsDialog({
    super.key,
    required this.correctWord,
    required this.drawerName,
    required this.drawerAvatar,
    required this.players,
    required this.remainingSeconds,
  });

  @override
  Widget build(BuildContext context) {
    // Sort players who gained points this round
    final roundScorers = players.where((p) => p.roundScore > 0).toList()
      ..sort((a, b) => b.roundScore.compareTo(a.roundScore));

    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'ROUND RESULTS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // The Secret Word
              const Text(
                'The secret word was',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                correctWord.toUpperCase(),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 18),

              // Round Scorers List
              if (roundScorers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Nobody guessed the word this round!',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                  ),
                )
              else ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Points Earned',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: roundScorers.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final p = roundScorers[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Text(p.avatar, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                p.displayName,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                            ),
                            Text(
                              '+${p.roundScore} pts',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Countdown to Next Round
              Text(
                'Next round starting in ${remainingSeconds}s...',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
