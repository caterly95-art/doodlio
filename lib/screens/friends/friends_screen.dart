import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../room/create_room_screen.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  void _shareApp() {
    Share.share(
      'Join me on Doodlio — the real-time online multiplayer drawing and guessing party game! Download and play online with friends.',
      subject: 'Play Doodlio with me!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Friends & Invitations'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.group_add_rounded,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Play with Friends',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create a private room, copy the 6-character room code, and share it with your friends on WhatsApp, Discord, or Instagram to play together in real-time!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Create a Friend Room',
                      icon: Icons.add_circle_outline_rounded,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreateRoomScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                      text: 'Share Doodlio Invite',
                      variant: ButtonVariant.secondary,
                      icon: Icons.share_rounded,
                      onPressed: _shareApp,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'How Multiplayer Works',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildStepTile('1', 'Create a Room', 'Set your desired rounds, draw time, and word difficulty.'),
              _buildStepTile('2', 'Share the Room Code', 'Send the 6-letter code to your friends.'),
              _buildStepTile('3', 'Ready Up & Start', 'When everyone is ready in the lobby, host taps Start!'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepTile(String step, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 1.2),
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

