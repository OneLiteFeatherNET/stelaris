import 'package:flutter/material.dart';

class LoreDeleteCheckbox extends StatefulWidget {

  final int index;
  final Function(bool add, int index) function;

  const LoreDeleteCheckbox({required this.index, required this.function, super.key});

  @override
  State<LoreDeleteCheckbox> createState() => _LoreDeleteCheckboxState();
}

class _LoreDeleteCheckboxState extends State<LoreDeleteCheckbox> {

  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: selected,
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          if (value) {
            widget.function.call(true, widget.index);
            selected = true;
          } else {
            widget.function.call(false, widget.index);
            selected = false;
          }
        });
      },
    );
  }
}
