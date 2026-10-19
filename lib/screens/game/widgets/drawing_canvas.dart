import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/draw_stroke_model.dart';
import '../../../../providers/drawing_provider.dart';

class DrawingCanvas extends StatelessWidget {
  final String drawerId;
  final bool isDrawer;

  const DrawingCanvas({
    super.key,
    required this.drawerId,
    required this.isDrawer,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, drawing, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: const Color(0xFF13151A), // Canvas drawing surface
                child: GestureDetector(
                  onPanStart: isDrawer
                      ? (details) => drawing.onPanStart(details.localPosition, canvasSize, drawerId)
                      : null,
                  onPanUpdate: isDrawer
                      ? (details) => drawing.onPanUpdate(details.localPosition, canvasSize)
                      : null,
                  onPanEnd: isDrawer
                      ? (_) => drawing.onPanEnd(drawerId)
                      : null,
                  child: CustomPaint(
                    size: canvasSize,
                    painter: _CanvasPainter(
                      strokes: drawing.strokes,
                      activePoints: drawing.activePoints,
                      activeColor: drawing.selectedColor,
                      activeWidth: drawing.strokeWidth,
                      isEraser: drawing.isEraser,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CanvasPainter extends CustomPainter {
  final List<DrawStroke> strokes;
  final List<DrawPoint> activePoints;
  final Color activeColor;
  final double activeWidth;
  final bool isEraser;

  _CanvasPainter({
    required this.strokes,
    required this.activePoints,
    required this.activeColor,
    required this.activeWidth,
    required this.isEraser,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // 1. Draw all completed synced strokes
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      final paint = Paint()
        ..color = stroke.isEraser ? const Color(0xFF13151A) : Color(stroke.colorValue)
        ..strokeWidth = stroke.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.points.length == 1) {
        final p = Offset(stroke.points.first.x * size.width, stroke.points.first.y * size.height);
        canvas.drawCircle(p, stroke.strokeWidth / 2, paint..style = PaintingStyle.fill);
      } else {
        final path = Path();
        final first = stroke.points.first;
        path.moveTo(first.x * size.width, first.y * size.height);

        for (int i = 1; i < stroke.points.length; i++) {
          final pt = stroke.points[i];
          path.lineTo(pt.x * size.width, pt.y * size.height);
        }
        canvas.drawPath(path, paint);
      }
    }

    // 2. Draw current in-progress active stroke (local drawer)
    if (activePoints.isNotEmpty) {
      final activePaint = Paint()
        ..color = isEraser ? const Color(0xFF13151A) : activeColor
        ..strokeWidth = activeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (activePoints.length == 1) {
        final p = Offset(activePoints.first.x * size.width, activePoints.first.y * size.height);
        canvas.drawCircle(p, activeWidth / 2, activePaint..style = PaintingStyle.fill);
      } else {
        final path = Path();
        final first = activePoints.first;
        path.moveTo(first.x * size.width, first.y * size.height);

        for (int i = 1; i < activePoints.length; i++) {
          final pt = activePoints[i];
          path.lineTo(pt.x * size.width, pt.y * size.height);
        }
        canvas.drawPath(path, activePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CanvasPainter oldDelegate) {
    return oldDelegate.strokes.length != strokes.length ||
        oldDelegate.activePoints.length != activePoints.length ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.activeWidth != activeWidth ||
        oldDelegate.isEraser != isEraser;
  }
}
