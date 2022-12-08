import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {

  final Icon? icon;
  final VoidCallback openFunction;

  const AddButton({Key? key, required this.openFunction, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 50,
      child: FloatingActionButton(
        autofocus: false,
        onPressed: openFunction,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: icon,
      ),
    );
  }
}
