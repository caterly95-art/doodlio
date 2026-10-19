import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/player_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/game_provider.dart';
import '../../widgets/custom_button.dart';
import '../lobby/lobby_screen.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      final clean = data!.text!.trim().toUpperCase().replaceAll(' ', '');
      if (clean.length <= 6) {
        setState(() => _codeController.text = clean);
      }
    }
  }

  Future<void> _handleJoin() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid room code'), backgroundColor: AppColors.danger),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final game = context.read<GameProvider>();

    final player = PlayerModel(
      uid: auth.uid,
      displayName: auth.displayName,
      avatarIndex: auth.avatarIndex,
    );

    final success = await game.joinRoom(roomId: code, player: player);

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LobbyScreen(roomId: code)),
      );
    } else if (mounted && game.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(game.errorMessage!), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Join Room'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Room Code',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ask your friend for their 6-character room code to join their private lobby.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),

              // Room Code Field
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8,
                  color: AppColors.primary,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'A B C 1 2 3',
                  hintStyle: TextStyle(
                    fontSize: 20,
                    letterSpacing: 4,
                    color: AppColors.textMuted.withValues(alpha: 0.5),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste_rounded, color: AppColors.primary),
                    tooltip: 'Paste from clipboard',
                    onPressed: _pasteFromClipboard,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: 'Join Lobby',
                icon: Icons.login_rounded,
                isLoading: game.isLoading,
                onPressed: _handleJoin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

