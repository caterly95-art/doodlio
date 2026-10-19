import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../models/player_model.dart';
import '../../models/room_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/game_provider.dart';
import '../../widgets/custom_button.dart';
import '../lobby/lobby_screen.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _nameController = TextEditingController();
  int _rounds = GameConstants.defaultRounds;
  int _drawDuration = GameConstants.defaultDrawDuration;
  int _maxPlayers = GameConstants.defaultMaxPlayers;
  String _difficulty = GameConstants.difficultyAll;
  String _category = GameConstants.categoryAll;
  bool _isPublic = true;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameController.text = "${auth.displayName}'s Room";
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final auth = context.read<AuthProvider>();
    final game = context.read<GameProvider>();

    final player = PlayerModel(
      uid: auth.uid,
      displayName: auth.displayName,
      avatarIndex: auth.avatarIndex,
    );

    final config = RoomConfig(
      rounds: _rounds,
      drawDuration: _drawDuration,
      maxPlayers: _maxPlayers,
      difficulty: _difficulty,
      category: _category,
      isPublic: _isPublic,
    );

    final roomName = _nameController.text.trim().isEmpty
        ? "${auth.displayName}'s Room"
        : _nameController.text.trim();

    final room = await game.createRoom(
      host: player,
      config: config,
      roomName: roomName,
    );

    if (room != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LobbyScreen(roomId: room.id)),
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
        title: const Text('Create Room'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room Name
              const Text('Room Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Enter room name',
                  prefixIcon: Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 20),

              // Visibility Toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isPublic ? Icons.public_rounded : Icons.lock_outline_rounded,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isPublic ? 'Public Room' : 'Private Room',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            _isPublic
                                ? 'Visible in room browser for all players'
                                : 'Joinable only with the secret room code',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isPublic,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) => setState(() => _isPublic = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Rounds Slider
              _buildSliderTile(
                title: 'Rounds',
                value: '$_rounds rounds',
                sliderValue: _rounds.toDouble(),
                min: GameConstants.minRounds.toDouble(),
                max: GameConstants.maxRounds.toDouble(),
                divisions: GameConstants.maxRounds - GameConstants.minRounds,
                onChanged: (val) => setState(() => _rounds = val.round()),
              ),
              const SizedBox(height: 16),

              // Draw Duration Slider
              _buildSliderTile(
                title: 'Drawing Time',
                value: '$_drawDuration seconds',
                sliderValue: _drawDuration.toDouble(),
                min: GameConstants.minDrawDuration.toDouble(),
                max: GameConstants.maxDrawDuration.toDouble(),
                divisions: (GameConstants.maxDrawDuration - GameConstants.minDrawDuration) ~/ 15,
                onChanged: (val) => setState(() => _drawDuration = val.round()),
              ),
              const SizedBox(height: 16),

              // Max Players Slider
              _buildSliderTile(
                title: 'Max Players',
                value: '$_maxPlayers players',
                sliderValue: _maxPlayers.toDouble(),
                min: GameConstants.minPlayers.toDouble(),
                max: GameConstants.maxPlayers.toDouble(),
                divisions: GameConstants.maxPlayers - GameConstants.minPlayers,
                onChanged: (val) => setState(() => _maxPlayers = val.round()),
              ),
              const SizedBox(height: 20),

              // Category Selector
              const Text('Word Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChoiceChip('All Categories', GameConstants.categoryAll, _category, (val) => setState(() => _category = val)),
                  _buildChoiceChip('Objects', GameConstants.categoryObjects, _category, (val) => setState(() => _category = val)),
                  _buildChoiceChip('Animals', GameConstants.categoryAnimals, _category, (val) => setState(() => _category = val)),
                  _buildChoiceChip('Food', GameConstants.categoryFood, _category, (val) => setState(() => _category = val)),
                  _buildChoiceChip('Movies', GameConstants.categoryMovies, _category, (val) => setState(() => _category = val)),
                  _buildChoiceChip('Tech', GameConstants.categoryTech, _category, (val) => setState(() => _category = val)),
                ],
              ),
              const SizedBox(height: 20),

              // Difficulty Selector
              const Text('Word Difficulty', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChoiceChip('All Difficulties', GameConstants.difficultyAll, _difficulty, (val) => setState(() => _difficulty = val)),
                  _buildChoiceChip('Easy', GameConstants.difficultyEasy, _difficulty, (val) => setState(() => _difficulty = val)),
                  _buildChoiceChip('Medium', GameConstants.difficultyMedium, _difficulty, (val) => setState(() => _difficulty = val)),
                  _buildChoiceChip('Hard', GameConstants.difficultyHard, _difficulty, (val) => setState(() => _difficulty = val)),
                ],
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: 'Create Room & Enter Lobby',
                icon: Icons.check_circle_outline_rounded,
                isLoading: game.isLoading,
                onPressed: _handleCreate,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String value,
    required double sliderValue,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ],
          ),
          Slider(
            value: sliderValue,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.border,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(
    String label,
    String value,
    String currentValue,
    ValueChanged<String> onSelected,
  ) {
    final isSelected = value == currentValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      backgroundColor: AppColors.surfaceElevated,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
