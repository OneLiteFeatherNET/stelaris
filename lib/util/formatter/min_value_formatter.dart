import 'package:flutter/services.dart';

class MinValueFormatter extends TextInputFormatter {
  final int min;

  MinValueFormatter(this.min);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    var text = newValue.text;
    var selectionIndex = newValue.selection.end; // keep track of cursor

    if (text.isEmpty) {
      text = min.toString();
      selectionIndex = text.length;
    } else {
      // Strip leading zeros (but not a single "0")
      if (text.length > 1 && text.startsWith('0')) {
        final withoutLeadingZeros = int.parse(text).toString();
        // Adjust cursor position by how many zeros we cut
        selectionIndex -= (text.length - withoutLeadingZeros.length);
        text = withoutLeadingZeros;
      }

      // Enforce min
      final parsed = int.tryParse(text);
      if (parsed == null || parsed < min) {
        text = min.toString();
        selectionIndex = text.length;
      }
    }

    // Clamp selection to valid range
    selectionIndex = selectionIndex.clamp(0, text.length);

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: selectionIndex),
      composing: TextRange.empty,
    );
  }
}
