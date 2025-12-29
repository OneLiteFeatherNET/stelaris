import 'package:flutter/material.dart';

class AnimatedDialog extends StatelessWidget {
  const AnimatedDialog({
    required this.child,
    this.maxHeight = 800,
    this.minHeightFactor = 0.8,
    super.key,
  });

  final Widget child;
  final double maxHeight;
  final double minHeightFactor;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuart,
      tween: Tween<double>(begin: 0, end: 1),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double width =
              constraints.maxWidth < 1000 ? constraints.maxWidth : 1000;
          final double height =
              constraints.maxHeight < maxHeight ? constraints.maxHeight : maxHeight;
          return Dialog(
            clipBehavior: Clip.hardEdge,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: width * 0.8,
                minHeight: height * minHeightFactor,
                maxHeight: height,
                maxWidth: width,
              ),
              child: child,
            ),
          );
        },
      ),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.5 + (value * 0.5),
            child: child,
          ),
        );
      },
    );
  }
}
