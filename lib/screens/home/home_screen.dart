import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/player_model.dart';
import '../../models/room_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/leaderboard_provider.dart';
import '../../services/realtime_database_service.dart';
import '../../widgets/custom_button.dart';
import '../room/create_room_screen.dart';
import '../room/join_room_screen.dart';
import '../room/public_rooms_screen.dart';
import '../lobby/lobby_screen.dart';
import '../profile/profile_screen.dart';
import '../friends/friends_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaderboardProvider>().loadLeaderboard();
    });
  }

  Future<void> _handleQuickPlay() async {
    final auth = context.read<AuthProvider>();
    final game = context.read<GameProvider>();
    final rtdb = context.read<RealtimeDatabaseService>();

    final player = PlayerModel(
      uid: auth.uid,
      displayName: auth.displayName,
      avatarIndex: auth.avatarIndex,
    );

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text(
                  'Finding public match...',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // 1. Look for an open public room
      final publicRooms = await rtdb.streamPublicRooms().first;
      final candidate = publicRooms.where((r) => r.players.length < r.config.maxPlayers).firstOrNull;

      if (candidate != null) {
        final joined = await game.joinRoom(roomId: candidate.id, player: player);
        if (mounted) Navigator.pop(context); // Dismiss loading
        if (joined && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LobbyScreen(roomId: candidate.id)),
          );
          return;
        }
      }

      // 2. If no available room found, automatically create a Quick Play room
      final newRoom = await game.createRoom(
        host: player,
        config: const RoomConfig(
          isPublic: true,
          rounds: 3,
          drawDuration: 60,
          maxPlayers: 6,
        ),
        roomName: "${auth.displayName}'s Quick Match",
      );

      if (mounted) Navigator.pop(context); // Dismiss loading
      if (newRoom != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LobbyScreen(roomId: newRoom.id)),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quick Play error: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final pages = [
      _buildHomeContent(auth),
      const PublicRoomsScreen(),
      _buildLeaderboardContent(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: pages[_currentNavIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: (idx) => setState(() => _currentNavIndex = idx),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.videogame_asset_outlined),
            selectedIcon: Icon(Icons.videogame_asset_rounded, color: AppColors.primary),
            label: 'Play',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded, color: AppColors.primary),
            label: 'Rooms',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events_rounded, color: AppColors.primary),
            label: 'Ranks',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(AuthProvider auth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _currentNavIndex = 3),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Center(
                    child: Text(auth.avatar, style: const TextStyle(fontSize: 26)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            auth.displayName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (auth.isGuest) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Text(
                              'GUEST',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${auth.profile?.totalScore ?? 0} total score • ${auth.profile?.wins ?? 0} wins',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.people_outline_rounded, color: AppColors.textPrimary),
                tooltip: 'Friends & Invite',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FriendsScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
                tooltip: 'Settings',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // QUICK PLAY HERO CARD
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt_rounded, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'INSTANT MATCH',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.brush_rounded, color: Colors.white, size: 28),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Quick Play',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Jump straight into an active game with real online players.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 18),
                CustomButton(
                  text: 'Play Now',
                  variant: ButtonVariant.secondary,
                  onPressed: _handleQuickPlay,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ACTION CARDS: CREATE ROOM & JOIN ROOM
          const Text(
            'Multiplayer Modes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              // Create Room
              Expanded(
                child: _buildActionTile(
                  icon: Icons.add_circle_outline_rounded,
                  title: 'Create Room',
                  subtitle: 'Custom rounds & rules',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateRoomScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 14),

              // Join Room
              Expanded(
                child: _buildActionTile(
                  icon: Icons.meeting_room_outlined,
                  title: 'Join Room',
                  subtitle: 'Use 6-character code',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const JoinRoomScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Browse Public Rooms Banner
          _buildActionTile(
            icon: Icons.explore_rounded,
            title: 'Browse Public Rooms',
            subtitle: 'Find open lobbies and join ongoing matches',
            onTap: () => setState(() => _currentNavIndex = 1),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardContent() {
    final leaderboard = context.watch<LeaderboardProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Global Leaderboard',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                onPressed: () => context.read<LeaderboardProvider>().loadLeaderboard(),
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.border),
        Expanded(
          child: leaderboard.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : leaderboard.topPlayers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.emoji_events_outlined, size: 56, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          const Text(
                            'No ranked players yet',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Play matches to climb the rankings!',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            width: 160,
                            text: 'Play Now',
                            onPressed: _handleQuickPlay,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      itemCount: leaderboard.topPlayers.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final user = leaderboard.topPlayers[index];
                        final rank = index + 1;

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: rank == 1
                                      ? const Color(0xFFF59E0B)
                                      : (rank == 2
                                          ? const Color(0xFF94A3B8)
                                          : (rank == 3
                                              ? const Color(0xFFB45309)
                                              : AppColors.surfaceElevated)),
                                ),
                                child: Center(
                                  child: Text(
                                    '$rank',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: rank <= 3 ? Colors.black : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(user.avatar, style: const TextStyle(fontSize: 24)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.displayName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${user.wins} wins • ${user.winRate.toStringAsFixed(0)}% win rate',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${user.totalScore} pts',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
