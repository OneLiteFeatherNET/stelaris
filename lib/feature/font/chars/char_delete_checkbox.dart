import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/state/factory/font/select_font_vm.dart';

class CharDeleteCheckbox extends StatefulWidget {
  const CharDeleteCheckbox({
    required this.selectedFontView,
    required this.charIndex,
    super.key,
  });

  final SelectedFontView selectedFontView;
  final String charIndex;

  @override
  State<CharDeleteCheckbox> createState() => _CharDeleteCheckboxState();
}

class _CharDeleteCheckboxState extends State<CharDeleteCheckbox> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: isSelected,
      onChanged: (value) {
        setState(() {
          if (value == null) return;
          isSelected = !isSelected;

          if (isSelected) {
            widget.selectedFontView.addCharToDeleted(widget.charIndex);
          } else {
            widget.selectedFontView.removeCharFromDeleted(widget.charIndex);
          }
        });
      },
    );
  }
}
