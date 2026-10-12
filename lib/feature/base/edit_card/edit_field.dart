import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// One field of a detail page, shown as an edit card and changed in its
/// dialog. The page builds them from its model and dispatches its own
/// update in [TextEdit.onChanged].
sealed class EditField {
  const EditField({required this.label, required this.icon, this.footer});

  final String label;
  final IconData icon;

  /// A rule or hint, shown under the value and in the dialog.
  final String? footer;
}

/// A field edited as one line of text, also a number written as text.
final class TextEdit extends EditField {
  const TextEdit({
    required super.label,
    required super.icon,
    required this.value,
    required this.onChanged,
    super.footer,
    this.hintText,
    this.formatters,
    this.keyboardType,
    this.validator,
    this.maxLength,
  });

  final String value;

  /// Called with the saved text, only when it differs from [value].
  final ValueChanged<String> onChanged;
  final String? hintText;
  final List<TextInputFormatter>? formatters;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final int? maxLength;
}

/// A heading and the fields under it.
class EditSection {
  const EditSection({required this.title, required this.fields});

  final String title;
  final List<EditField> fields;
}
