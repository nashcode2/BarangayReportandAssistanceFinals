import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Smooth animated loading indicator
class SmoothLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;

  const SmoothLoadingIndicator({
    super.key,
    this.size = 40.0,
    this.color,
  });

  @override
  State<SmoothLoadingIndicator> createState() => _SmoothLoadingIndicatorState();
}

class _SmoothLoadingIndicatorState extends State<SmoothLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.14159,
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: (widget.color ?? AppColors.primary).withOpacity(0.3),
            width: 3,
          ),
        ),
        child: CustomPaint(
          painter: _LoadingPainter(
            color: widget.color ?? AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _LoadingPainter extends CustomPainter {
  final Color color;

  _LoadingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57, // Start at top
      2.0, // Draw 2/3 of circle
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Smooth skeleton loader for list items
class SmoothSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SmoothSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 0.7),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      onEnd: () {},
      builder: (context, value, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
            color: AppColors.surfaceLight.withOpacity(value),
          ),
        );
      },
    );
  }
}

