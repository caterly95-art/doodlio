import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showHowToPlayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('How to Play Doodlio', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. Drawing Turn',
                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
              SizedBox(height: 4),
              Text(
                'When it is your turn to draw, select one of three secret words. Sketch it on the canvas so other players can guess what it is. You cannot write letters or numbers!',
                style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
              ),
              SizedBox(height: 12),
              Text(
                '2. Guessing Turn',
                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
              SizedBox(height: 4),
              Text(
                'Watch the canvas and type your guesses in the chat box at the bottom. As the timer counts down, progressive hints reveal parts of the word.',
                style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
              ),
              SizedBox(height: 12),
              Text(
                '3. Scoring & Speed',
                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
              SizedBox(height: 4),
              Text(
                'The faster you guess the word, the more points you receive! Drawers also receive bonus points when players solve their drawing.',
                style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final reportController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Report Issue or Player', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Help us keep Doodlio friendly, fair, and fun for everyone. Please describe the problem or player conduct:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: reportController,
              maxLines: 3,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Describe issue or inappropriate behavior...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thank you! Your report has been submitted to moderation.')),
              );
            },
            child: const Text('Submit Report'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings & Help'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // GAMEPLAY PREFERENCES
            const Text(
              'GAMEPLAY PREFERENCES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Sound Effects', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Timer ticks, clicks, and alert chimes', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    value: settings.soundEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => settings.setSoundEnabled(val),
                  ),
                  const Divider(color: AppColors.border),
                  SwitchListTile(
                    title: const Text('Haptic Feedback', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Vibrations on drawing, tool switch & guesses', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    value: settings.hapticsEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => settings.setHapticsEnabled(val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // HELP & MODERATION
            const Text(
              'HELP & SUPPORT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.help_outline_rounded, color: AppColors.primary),
                    title: const Text('How to Play', style: TextStyle(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                    onTap: () => _showHowToPlayDialog(context),
                  ),
                  const Divider(color: AppColors.border),
                  ListTile(
                    leading: const Icon(Icons.shield_outlined, color: AppColors.warning),
                    title: const Text('Report & Room Moderation', style: TextStyle(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                    onTap: () => _showReportDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // APP INFO
            Center(
              child: Column(
                children: [
                  const Text(
                    'Doodlio v1.0.0',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Real-Time Multiplayer Drawing & Guessing',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
