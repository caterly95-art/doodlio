import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/drawing_provider.dart';
import 'widgets/drawing_canvas.dart';
import 'widgets/drawing_toolbar.dart';
import 'widgets/game_timer_bar.dart';
import 'widgets/hint_display.dart';
import 'widgets/game_chat_sheet.dart';
import 'widgets/word_selection_dialog.dart';
import 'widgets/score_board_drawer.dart';
import '../results/round_results_dialog.dart';
import '../results/game_over_screen.dart';

class GameScreen extends StatefulWidget {
  final String roomId;

  const GameScreen({super.key, required this.roomId});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final game = context.read<GameProvider>();
      final drawing = context.read<DrawingProvider>();
      final auth = context.read<AuthProvider>();

      game.setCurrentUserId(auth.uid);
      drawing.initRoom(roomId: widget.roomId, isDrawer: game.isDrawer);
    });
  }

  Future<void> _handleLeaveGame() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Leave Match?'),
        content: const Text('Are you sure you want to leave this game? Your score for this match will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Playing'),
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
      final game = context.read<GameProvider>();
      final drawing = context.read<DrawingProvider>();
      await game.leaveCurrentRoom();
      drawing.reset();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final room = game.currentRoom;
    final auth = context.watch<AuthProvider>();
    final drawing = context.watch<DrawingProvider>();

    if (room == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    // Check for game over
    if (room.status == GameConstants.statusGameOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => GameOverScreen(room: room)),
          );
        }
      });
    }

    final isDrawer = game.isDrawer;
    // Update drawing provider mode dynamically when turn changes
    if (drawing.isDrawer != isDrawer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        drawing.initRoom(roomId: room.id, isDrawer: isDrawer);
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleLeaveGame();
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        endDrawer: ScoreBoardDrawer(
          players: room.playerList,
          currentDrawerId: room.currentDrawerId,
          currentUserId: auth.uid,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // TOP STATUS & TIMER BAR
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Leave button
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                              tooltip: 'Leave Match',
                              onPressed: _handleLeaveGame,
                            ),
                            const SizedBox(width: 4),

                            // Drawer Info Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(room.currentDrawer?.avatar ?? '🎨', style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Text(
                                    isDrawer ? 'You are drawing' : '${room.currentDrawerName ?? "Drawer"} is drawing',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),

                            // Standings Drawer Button
                            IconButton(
                              icon: const Icon(Icons.leaderboard_rounded, color: AppColors.primary),
                              tooltip: 'Standings',
                              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Timer & Round Bar
                        GameTimerBar(
                          currentRound: room.currentRound,
                          totalRounds: room.config.rounds,
                          remainingSeconds: game.remainingSeconds,
                          progress: game.timerProgress,
                        ),
                      ],
                    ),
                  ),

                  // WORD HINT BAR
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Center(
                      child: HintDisplay(
                        isDrawer: isDrawer,
                        hasGuessed: game.hasGuessed,
                        secretWord: game.secretWordForDrawer,
                        hint: room.wordHint,
                        wordLength: room.wordLength,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // CENTRAL DRAWING CANVAS
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: DrawingCanvas(
                              drawerId: auth.uid,
                              isDrawer: isDrawer && room.status == GameConstants.statusDrawing,
                            ),
                          ),
                          // Watermark / room indicator in corner
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Text(
                              'Doodlio • ${room.id}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // DRAWER TOOLBAR (only visible for active drawer during drawing)
                  if (isDrawer && room.status == GameConstants.statusDrawing) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: DrawingToolbar(drawerId: auth.uid),
                    ),
                    const SizedBox(height: 6),
                  ],

                  // CHAT & GUESS INPUT SHEET
                  Expanded(
                    flex: 4,
                    child: GameChatSheet(
                      messages: game.chatMessages,
                      onSend: (text) => game.sendGuessOrChat(text),
                      onReaction: (emoji) => game.sendReaction(emoji),
                      isDrawer: isDrawer,
                      hasGuessed: game.hasGuessed,
                    ),
                  ),
                ],
              ),

              // OVERLAY 1: WORD SELECTION
              if (room.status == GameConstants.statusWordSelection) ...[
                if (isDrawer)
                  WordSelectionDialog(
                    words: room.wordChoices,
                    remainingSeconds: game.remainingSeconds,
                    onWordSelected: (word) => game.chooseWord(word),
                  )
                else
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${room.currentDrawerName ?? "Drawer"} is choosing a word...',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Get your fingers ready to guess in ${game.remainingSeconds}s',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],

              // OVERLAY 2: ROUND RESULTS
              if (room.status == GameConstants.statusRoundResults)
                RoundResultsDialog(
                  correctWord: room.lastCorrectWord ?? '',
                  drawerName: room.currentDrawerName ?? 'Drawer',
                  drawerAvatar: room.currentDrawer?.avatar ?? '🎨',
                  players: room.playerList,
                  remainingSeconds: game.remainingSeconds,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
