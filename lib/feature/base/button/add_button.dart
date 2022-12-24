import 'package:flutter/material.dart';
import 'package:stelaris_ui/util/constants.dart';

class AddButton extends StatelessWidget {

  final VoidCallback openFunction;

  const AddButton({Key? key, required this.openFunction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
        onPressed: openFunction,
        label: addText,
        icon: addModelIcon,
    );
  }
}
