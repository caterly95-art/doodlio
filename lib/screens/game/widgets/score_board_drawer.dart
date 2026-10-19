import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/player_model.dart';

class ScoreBoardDrawer extends StatelessWidget {
  final List<PlayerModel> players;
  final String? currentDrawerId;
  final String currentUserId;

  const ScoreBoardDrawer({
    super.key,
    required this.players,
    required this.currentDrawerId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  const Icon(Icons.leaderboard_rounded, color: AppColors.primary),
                  const SizedBox(width: 10),
                  const Text(
                    'LIVE STANDINGS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border),

            // Player Rank List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: players.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final player = players[index];
                  final isCurrent = player.uid == currentUserId;
                  final isDrawing = player.uid == currentDrawerId;
                  final rank = index + 1;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrent ? AppColors.primary : AppColors.border,
                        width: isCurrent ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Rank position badge
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: rank == 1
                                ? const Color(0xFFF59E0B)
                                : (rank == 2
                                    ? const Color(0xFF94A3B8)
                                    : (rank == 3
                                        ? const Color(0xFFB45309)
                                        : AppColors.surfaceHover)),
                          ),
                          child: Center(
                            child: Text(
                              '$rank',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: rank <= 3 ? Colors.black : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Avatar
                        Text(player.avatar, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),

                        // Player Name & status badge
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      player.displayName,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (isCurrent) ...[
                                    const SizedBox(width: 4),
                                    const Text('(You)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                  ],
                                ],
                              ),
                              if (isDrawing)
                                const Row(
                                  children: [
                                    Icon(Icons.brush_rounded, size: 12, color: AppColors.primary),
                                    SizedBox(width: 4),
                                    Text('Drawing now', style: TextStyle(fontSize: 11, color: AppColors.primaryLight)),
                                  ],
                                )
                              else if (player.hasGuessed)
                                const Row(
                                  children: [
                                    Icon(Icons.check_circle_rounded, size: 12, color: AppColors.success),
                                    SizedBox(width: 4),
                                    Text('Guessed!', style: TextStyle(fontSize: 11, color: AppColors.success)),
                                  ],
                                ),
                            ],
                          ),
                        ),

                        // Score
                        Text(
                          '${player.score} pts',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

