import 'package:flutter/material.dart';
import 'package:stelaris/util/constants.dart';

/// The class represents the save button widget which is used to save the changes.
/// It is only used in such structures which require a save button.
class SaveButton extends StatelessWidget {
  const SaveButton({
    required this.callback,
    this.text = emptyString,
    this.heroTag = 'save_button',
    super.key,
  });

  final VoidCallback callback;
  final String text;
  final Object heroTag;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child:  Padding(
        padding: const EdgeInsets.only(bottom: 25, right: 10),
        child:
            text == emptyString ? _getButtonWithOutLabel() : _getButton(text),
      ),
    );
  }


  /// Returns the button which should be displayed
  Widget _getButton(String text) {
    return FloatingActionButton.extended(
      heroTag: heroTag,
      onPressed: callback,
      label: Text(text),
      icon: saveIcon,
    );
  }

  /// Returns the button without any label
  Widget _getButtonWithOutLabel() {
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: callback,
      child: saveIcon,
    );
  }
}
