import 'package:flutter/material.dart';

class PositionBottomRight extends StatelessWidget {
  const PositionBottomRight({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 25,
      right: 25,
      child: child,
    );
  }
}
