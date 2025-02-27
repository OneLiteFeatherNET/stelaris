import 'package:flutter/material.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/constants.dart';

class AddButton extends StatelessWidget {
  const AddButton({
    required this.openFunction,
    super.key,
  });

  final VoidCallback openFunction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50, // Set a fixed height for the button
      child: FloatingActionButton.extended(
        onPressed: openFunction,
        label: Text(context.l10n.button_add),
        icon: addModelIcon,
      ),
    );
  }
}
