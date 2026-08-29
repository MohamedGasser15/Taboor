// core/widgets/loader_icon.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The "loader" spinner icon (lucide-loader style): eight spokes rotating
/// around a circle. Painted natively so it looks crisp on any device.
class LoaderIcon extends StatefulWidget {
  const LoaderIcon({
    super.key,
    this.size = 22,
    this.color = Colors.white,
    this.strokeWidth = 2,
  });

  final double size;
  final Color color;
  final double strokeWidth;

  @override
  State<LoaderIcon> createState() => _LoaderIconState();
}

class _LoaderIconState extends State<LoaderIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _LoaderPainter(
          color: widget.color,
          strokeWidth: widget.strokeWidth,
        ),
      ),
    );
  }
}

class _LoaderPainter extends CustomPainter {
  const _LoaderPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final center = Offset(size.width / 2, size.height / 2);
    // Match the lucide-loader geometry exactly: 8 short ticks on the rim.
    // Inside radius ≈ 0.5x half-size, outside ≈ 0.83x half-size.
    final half = size.width / 2;
    final innerR = half * 0.50;
    final outerR = half * 0.83;

    // Spokes at 45° increments (8 rays matching the lucide loader icon).
    for (var i = 0; i < 8; i++) {
      final angle = i * 45 * (math.pi / 180);
      final dir = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(center + dir * innerR, center + dir * outerR, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LoaderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// A loading button with the lucide-loader icon + a label text beside it.
class LoadingButton extends StatelessWidget {
  const LoadingButton({
    super.key,
    this.label = '',
    this.color = Colors.white,
    this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoaderIcon(size: 18, color: color),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}