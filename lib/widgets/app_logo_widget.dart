import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AppLogoWidget extends StatefulWidget {
  final double size;
  final bool animate;
  final bool showText;

  const AppLogoWidget({
    super.key,
    this.size = 100,
    this.animate = true,
    this.showText = true,
  });

  @override
  State<AppLogoWidget> createState() => _AppLogoWidgetState();
}

class _AppLogoWidgetState extends State<AppLogoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _strokeProgress;
  late Animation<double> _pencilAngle;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _strokeProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _pencilAngle = Tween<double>(begin: -0.3, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.9, curve: Curves.elasticOut),
      ),
    );

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _LogoPainter(
                strokeProgress: _strokeProgress.value,
                pencilAngle: _pencilAngle.value,
              ),
            );
          },
        ),
        if (widget.showText) ...[
          const SizedBox(height: 12),
          const Text(
            'DOODLIO',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 3.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Draw • Guess • Win',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
              color: AppColors.primary,
            ),
          ),
        ],
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  final double strokeProgress;
  final double pencilAngle;

  _LogoPainter({
    required this.strokeProgress,
    required this.pencilAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Draw glowing background circle
    final bgPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width * 0.46, bgPaint);

    final borderPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, size.width * 0.46, borderPaint);

    // 2. Draw curved playful stroke (dynamic swirl)
    final strokePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.08;

    final path = Path();
    final startP = Offset(size.width * 0.22, size.height * 0.68);
    final control1 = Offset(size.width * 0.35, size.height * 0.25);
    final control2 = Offset(size.width * 0.68, size.height * 0.35);
    final endP = Offset(size.width * 0.76, size.height * 0.64);

    path.moveTo(startP.dx, startP.dy);
    path.cubicTo(
      control1.dx,
      control1.dy,
      control2.dx,
      control2.dy,
      endP.dx,
      endP.dy,
    );

    // Animate drawing path
    final metric = path.computeMetrics().firstOrNull;
    if (metric != null && strokeProgress > 0) {
      final extractPath = metric.extractPath(0, metric.length * strokeProgress);
      canvas.drawPath(extractPath, strokePaint);
    }

    // 3. Draw stylized pencil at top right
    canvas.save();
    canvas.translate(size.width * 0.62, size.height * 0.42);
    canvas.rotate(pencilAngle - 0.7);

    final pencilBody = Paint()..color = const Color(0xFFF59E0B);
    final pencilTip = Paint()..color = const Color(0xFFE2E8F0);
    final pencilLead = Paint()..color = const Color(0xFF1E293B);

    final pWidth = size.width * 0.12;
    final pHeight = size.height * 0.36;

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-pWidth / 2, -pHeight / 2, pWidth, pHeight * 0.75),
        const Radius.circular(4),
      ),
      pencilBody,
    );

    // Wooden tip triangle
    final tipPath = Path()
      ..moveTo(-pWidth / 2, pHeight * 0.25)
      ..lineTo(pWidth / 2, pHeight * 0.25)
      ..lineTo(0, pHeight * 0.5)
      ..close();
    canvas.drawPath(tipPath, pencilTip);

    // Graphite lead tip
    final leadPath = Path()
      ..moveTo(-pWidth * 0.2, pHeight * 0.4)
      ..lineTo(pWidth * 0.2, pHeight * 0.4)
      ..lineTo(0, pHeight * 0.5)
      ..close();
    canvas.drawPath(leadPath, pencilLead);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) {
    return oldDelegate.strokeProgress != strokeProgress ||
        oldDelegate.pencilAngle != pencilAngle;
  }
}

