import 'package:flutter/services.dart';

/// A [TextInputFormatter] that automatically converts entered text to lowercase
/// and optionally replaces whitespace with underscores.
class LowerCaseTextFormatter extends TextInputFormatter {
  final bool replaceSpaces;

  const LowerCaseTextFormatter({this.replaceSpaces = true});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var formattedText = newValue.text.toLowerCase();
    if (replaceSpaces) {
      formattedText = formattedText.replaceAll(' ', '_');
    }

    return newValue.copyWith(
      text: formattedText,
      selection: newValue.selection,
    );
  }
}
