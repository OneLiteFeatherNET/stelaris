import 'package:flutter/material.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';

class SaveButton extends StatelessWidget {
  final Function callback;
  final Object? parameter;

  const SaveButton({
    required this.callback,
    this.parameter,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 25, right: 10),
        child: FloatingActionButton.extended(
          heroTag: UniqueKey(),
          onPressed: () {
            if (parameter != null) {
              callback.call(parameter);
            } else {
              callback.call();
            }
          },
          label: Text(context.l10n.button_save),
          icon: saveIcon,
        ),
      ),
    );
  }
}
