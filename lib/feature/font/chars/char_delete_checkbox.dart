import 'package:flutter/material.dart';
import 'package:stelaris/api/model/font/font_string_dto.dart';
import 'package:stelaris/api/state/factory/font/selected_font_char_state.dart';

class CharDeleteCheckbox extends StatefulWidget {
  const CharDeleteCheckbox({
    required this.selectedFontView,
    required this.charIndex,
    super.key,
  });

  final SelectedFontCharView selectedFontView;
  final FontStringDTO charIndex;

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
