import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/button/save_button.dart';
import 'package:stelaris/util/constants.dart';

class PositionedSaveButton extends StatelessWidget {
  const PositionedSaveButton({
    required this.callback,
    required this.right,
    required this.bottom,
    this.text = emptyString,
    this.successMessage,
    this.formKey,
    this.heroTag = 'save_button',
    super.key,
  });

  const PositionedSaveButton.standard({
    required this.callback,
    this.bottom = 0,
    this.right = 15,
    this.text = emptyString,
    this.successMessage,
    this.formKey,
    this.heroTag = 'save_button',
    super.key,
  });

  final FutureOr<dynamic> Function()? callback;
  final double right;
  final double bottom;
  final String text;
  final String? successMessage;
  final GlobalKey<FormState>? formKey;
  final Object heroTag;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: right,
      bottom: bottom,
      child: SaveButton(
        callback: callback,
        text: text,
        successMessage: successMessage,
        formKey: formKey,
        heroTag: heroTag,
      ),
    );
  }
}
