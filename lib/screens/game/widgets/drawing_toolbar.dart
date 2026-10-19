import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/drawing_provider.dart';

class DrawingToolbar extends StatelessWidget {
  final String drawerId;

  const DrawingToolbar({super.key, required this.drawerId});

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, drawing, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Action buttons (Undo, Clear, Eraser, Brush sizes)
              Row(
                children: [
                  // Undo button
                  _buildIconButton(
                    icon: Icons.undo_rounded,
                    tooltip: 'Undo',
                    onTap: () => drawing.undo(drawerId),
                  ),
                  const SizedBox(width: 6),

                  // Clear canvas button
                  _buildIconButton(
                    icon: Icons.delete_outline_rounded,
                    tooltip: 'Clear Canvas',
                    onTap: () => _confirmClear(context, drawing),
                  ),
                  const SizedBox(width: 6),

                  // Eraser toggle
                  _buildIconButton(
                    icon: Icons.auto_fix_high_rounded,
                    tooltip: 'Eraser',
                    isSelected: drawing.isEraser,
                    onTap: drawing.toggleEraser,
                  ),

                  const Spacer(),

                  // Brush Sizes selector
                  _buildBrushSizeSelector(drawing),
                ],
              ),
              const SizedBox(height: 8),

              // Row 2: Color Palette
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppColors.drawingPalette.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final color = AppColors.drawingPalette[index];
                    final isSelected = !drawing.isEraser && drawing.selectedColor == color;

                    return GestureDetector(
                      onTap: () => drawing.setColor(color),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : (color == Colors.white ? Colors.grey.shade600 : Colors.transparent),
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.25) : AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrushSizeSelector(DrawingProvider drawing) {
    const sizes = [2.0, 5.0, 10.0, 18.0];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: sizes.map((size) {
        final isSelected = drawing.strokeWidth == size;
        return GestureDetector(
          onTap: () => drawing.setStrokeWidth(size),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 1,
              ),
            ),
            child: Center(
              child: Container(
                width: size + 4,
                height: size + 4,
                decoration: const BoxDecoration(
                  color: AppColors.textPrimary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _confirmClear(BuildContext context, DrawingProvider drawing) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear Canvas?'),
        content: const Text('This will erase all strokes from the canvas for all players.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              drawing.clearCanvas();
              Navigator.pop(ctx);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

