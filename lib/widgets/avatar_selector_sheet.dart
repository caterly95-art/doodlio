import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/game_constants.dart';
import '../core/utils/haptic_feedback_helper.dart';

class AvatarSelectorSheet extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const AvatarSelectorSheet({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  static Future<int?> show(BuildContext context, int initialIndex) {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        int current = initialIndex;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Choose Your Avatar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Select an avatar to represent you in rooms & matches',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: GameConstants.avatars.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemBuilder: (context, index) {
                      final isSel = current == index;
                      final bgColor = AppColors.avatarColors[index % AppColors.avatarColors.length];

                      return GestureDetector(
                        onTap: () {
                          HapticHelper.selection();
                          setModalState(() => current = index);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSel ? bgColor.withValues(alpha: 0.25) : AppColors.surfaceElevated,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSel ? AppColors.primary : AppColors.border,
                              width: isSel ? 2.5 : 1.0,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              GameConstants.avatars[index],
                              style: TextStyle(fontSize: isSel ? 32 : 26),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      HapticHelper.success();
                      Navigator.pop(context, current);
                    },
                    child: const Text('Save Avatar'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatar = (selectedIndex >= 0 && selectedIndex < GameConstants.avatars.length)
        ? GameConstants.avatars[selectedIndex]
        : GameConstants.avatars.first;

    final bgColor = AppColors.avatarColors[selectedIndex % AppColors.avatarColors.length];

    return GestureDetector(
      onTap: () async {
        final res = await AvatarSelectorSheet.show(context, selectedIndex);
        if (res != null) {
          onSelected(res);
        }
      },
      child: Stack(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor.withValues(alpha: 0.2),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: Center(
              child: Text(
                avatar,
                style: const TextStyle(fontSize: 38),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

