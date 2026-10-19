import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/player_model.dart';
import '../../models/room_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/custom_button.dart';
import '../home/home_screen.dart';

class GameOverScreen extends StatelessWidget {
  final RoomModel room;

  const GameOverScreen({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final game = context.read<GameProvider>();
    final players = room.playerList;
    final winner = players.isNotEmpty ? players.first : null;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 12),
                // Trophy & Title
                const Icon(
                  Icons.emoji_events_rounded,
                  size: 64,
                  color: Color(0xFFF59E0B),
                ),
                const SizedBox(height: 10),
                const Text(
                  'MATCH COMPLETED!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Winner: ${winner?.displayName ?? "Player"}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),

                // Top 3 Podium
                if (players.length >= 2) ...[
                  _buildPodium(players),
                  const SizedBox(height: 20),
                ],

                // Full Scoreboard Header
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Final Scoreboard',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Scoreboard List
                Expanded(
                  child: ListView.separated(
                    itemCount: players.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final p = players[index];
                      final rank = index + 1;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: rank == 1 ? AppColors.primary : AppColors.border,
                            width: rank == 1 ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '#$rank',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: rank == 1 ? AppColors.primary : AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(p.avatar, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                p.displayName,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ),
                            Text(
                              '${p.score} pts',
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
                const SizedBox(height: 16),

                // Back Home Action
                CustomButton(
                  text: 'Back to Home',
                  icon: Icons.home_rounded,
                  onPressed: () async {
                    await game.leaveCurrentRoom();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodium(List<PlayerModel> players) {
    final first = players.first;
    final second = players.length > 1 ? players[1] : null;
    final third = players.length > 2 ? players[2] : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd Place
        if (second != null)
          _buildPodiumStep(
            player: second,
            rank: 2,
            height: 90,
            color: const Color(0xFF94A3B8),
          ),
        const SizedBox(width: 12),

        // 1st Place
        _buildPodiumStep(
          player: first,
          rank: 1,
          height: 125,
          color: const Color(0xFFF59E0B),
        ),
        const SizedBox(width: 12),

        // 3rd Place
        if (third != null)
          _buildPodiumStep(
            player: third,
            rank: 3,
            height: 70,
            color: const Color(0xFFB45309),
          ),
      ],
    );
  }

  Widget _buildPodiumStep({
    required PlayerModel player,
    required int rank,
    required double height,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(player.avatar, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 4),
        Text(
          player.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        Text(
          '${player.score} pts',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color),
        ),
        const SizedBox(height: 6),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color),
            ),
          ),
        ),
      ],
    );
  }
}

