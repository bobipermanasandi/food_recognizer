import 'package:food_recognizer/utils/circle_painter.dart';
import 'package:flutter/material.dart';

class ConfidenceIndicator extends StatelessWidget {
  final double value; // 0..1
  final Color color;
  final String text;

  const ConfidenceIndicator({
    super.key,
    required this.value,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, animatedValue, child) {
        final Color dynamicColor =
            Color.lerp(
              Colors.red,
              Colors.green,
              animatedValue.clamp(0.0, 1.0),
            ) ??
            color;
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: CustomPaint(
                painter: CirclePainter(
                  progress: animatedValue,
                  color: dynamicColor,
                ),
              ),
            ),
            Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        );
      },
    );
  }
}
