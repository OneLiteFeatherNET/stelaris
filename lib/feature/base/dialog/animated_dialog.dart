import 'package:flutter/material.dart';

class AnimatedDialog extends StatelessWidget {
  const AnimatedDialog({
    required this.child,
    super.key,
  });

  final Widget child;

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
              constraints.maxHeight < 600 ? constraints.maxHeight : 600;
          return Dialog(
            clipBehavior: Clip.hardEdge,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: width * 0.8,
                minHeight: height * 0.8,
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
