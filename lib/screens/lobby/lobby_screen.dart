import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../models/player_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/game_provider.dart';
import '../../widgets/custom_button.dart';
import '../game/game_screen.dart';

class LobbyScreen extends StatefulWidget {
  final String roomId;

  const LobbyScreen({super.key, required this.roomId});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    context.read<GameProvider>().setCurrentUserId(auth.uid);
  }

  void _copyRoomCode() {
    Clipboard.setData(ClipboardData(text: widget.roomId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Room code copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareRoom() {
    Share.share(
      'Join my Doodlio drawing game! Room Code: ${widget.roomId}\nDraw and guess with me in real-time!',
      subject: 'Join my Doodlio Room',
    );
  }

  Future<void> _leaveLobby() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Leave Lobby?'),
        content: const Text('Are you sure you want to leave this room?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Stay'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<GameProvider>().leaveCurrentRoom();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final room = game.currentRoom;

    // Check if the match has started
    if (room != null && room.status != GameConstants.statusLobby) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => GameScreen(roomId: room.id)),
          );
        }
      });
    }

    if (room == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final isHost = game.isHost;
    final players = room.playerList;
    final minMet = players.length >= GameConstants.minPlayers;
    final othersReady = players.where((p) => !p.isHost).every((p) => p.isReady);
    final canStart = isHost && minMet && othersReady;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leaveLobby();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(room.name),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: _leaveLobby,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_rounded, color: AppColors.primary),
              tooltip: 'Share Room',
              onPressed: _shareRoom,
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ROOM CODE CARD
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ROOM CODE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              room.id,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 5.0,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surfaceElevated,
                          foregroundColor: AppColors.textPrimary,
                        ),
                        icon: const Icon(Icons.copy_rounded, size: 20),
                        tooltip: 'Copy Code',
                        onPressed: _copyRoomCode,
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.share_rounded, size: 20),
                        tooltip: 'Share Invite',
                        onPressed: _shareRoom,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // ROOM CONFIG SUMMARY
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildConfigItem(Icons.repeat_rounded, '${room.config.rounds} Rounds'),
                      Container(width: 1, height: 20, color: AppColors.border),
                      _buildConfigItem(Icons.timer_outlined, '${room.config.drawDuration}s Draw'),
                      Container(width: 1, height: 20, color: AppColors.border),
                      _buildConfigItem(Icons.group_outlined, '${players.length}/${room.config.maxPlayers} Max'),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // PLAYERS SECTION HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Players in Lobby (${players.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (!minMet)
                      Text(
                        'Need ${GameConstants.minPlayers - players.length} more',
                        style: const TextStyle(fontSize: 12, color: AppColors.warning),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // PLAYERS GRID
                Expanded(
                  child: GridView.builder(
                    itemCount: players.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.2,
                    ),
                    itemBuilder: (context, index) {
                      final p = players[index];
                      return _buildPlayerCard(p);
                    },
                  ),
                ),

                // BOTTOM ACTION BAR
                if (isHost) ...[
                  if (!minMet)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Center(
                        child: Text(
                          'Waiting for at least 2 players to join...',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ),
                    )
                  else if (!othersReady)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Center(
                        child: Text(
                          'Waiting for all players to be Ready...',
                          style: TextStyle(fontSize: 12, color: AppColors.warning),
                        ),
                      ),
                    ),
                  CustomButton(
                    text: 'Start Game',
                    icon: Icons.play_arrow_rounded,
                    isLoading: game.isLoading,
                    onPressed: canStart ? () => game.startMatch() : null,
                  ),
                ] else ...[
                  CustomButton(
                    text: game.myPlayer?.isReady == true ? 'Ready! (Tap to Cancel)' : "I'm Ready!",
                    variant: game.myPlayer?.isReady == true ? ButtonVariant.secondary : ButtonVariant.primary,
                    icon: game.myPlayer?.isReady == true ? Icons.check_circle_rounded : Icons.thumb_up_rounded,
                    onPressed: () => game.toggleReady(),
                  ),
                ],
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfigItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildPlayerCard(PlayerModel player) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: player.isReady || player.isHost ? AppColors.success.withValues(alpha: 0.5) : AppColors.border,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Text(player.avatar, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  player.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (player.isHost)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'HOST',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: player.isReady
                              ? AppColors.success.withValues(alpha: 0.2)
                              : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          player.isReady ? 'READY' : 'NOT READY',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: player.isReady ? AppColors.success : AppColors.textMuted,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

