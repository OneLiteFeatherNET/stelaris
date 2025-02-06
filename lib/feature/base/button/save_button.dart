import 'package:flutter/material.dart';
import 'package:stelaris/util/constants.dart';

/// The class represents the save button widget which is used to save the changes.
/// It is only used in such structures which require a save button.
class SaveButton extends StatelessWidget {
  final Function callback;
  final String? text;

  const SaveButton({
    required this.callback,
    this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 25, right: 10),
        child: _getButton(text),
      ),
    );
  }

  /// Returns the button which should be displayed
  Widget _getButton(String? text) {
    if (text == null) return _getButtonWithOutLabel();
    return FloatingActionButton.extended(
      heroTag: UniqueKey(),
      onPressed: () => callback.call(),
      label: Text(text),
      icon: saveIcon,
    );
  }

  /// Returns the button without any label
  Widget _getButtonWithOutLabel() {
    return FloatingActionButton(
      heroTag: UniqueKey(),
      onPressed: () => callback.call(),
      child: saveIcon,
    );
  }
}
