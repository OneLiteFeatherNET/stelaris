import 'package:flutter/material.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';

class AddButton extends StatelessWidget {

  final VoidCallback openFunction;

  const AddButton({super.key, required this.openFunction});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
        onPressed: openFunction,
        label: Text(context.l10n.button_add),
        icon: addModelIcon,
    );
  }
}
