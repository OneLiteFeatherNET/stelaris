import 'package:flutter/material.dart';
import 'package:stelaris/feature/base/button/save_button.dart';

class PositionedSaveButton extends StatelessWidget {
  const PositionedSaveButton({
    required this.callback,
    required this.right,
    required this.bottom,
    super.key,
  });

  const PositionedSaveButton.standard({
    required this.callback,
    this.bottom = 0,
    this.right = 15,
    super.key,
  });

  final VoidCallback callback;
  final double right;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: right,
      bottom: bottom,
      child: SaveButton(callback: callback),
    );
  }
}
