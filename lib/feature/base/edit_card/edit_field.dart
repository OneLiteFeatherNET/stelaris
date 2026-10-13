import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/edit_card/edit_dialogs.dart';
import 'package:stelaris/util/component_context.dart';

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
    this.suggestsMaterials = false,
  });

  final String value;

  /// Called with the saved text, only when it differs from [value].
  final ValueChanged<String> onChanged;
  final String? hintText;
  final List<TextInputFormatter>? formatters;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final int? maxLength;

  /// Suggests Minecraft materials while typing. Anything typed stays valid.
  final bool suggestsMaterials;
}

/// A field that takes one of [options].
final class ChoiceEdit<T> extends EditField {
  const ChoiceEdit({
    required super.label,
    required super.icon,
    required this.value,
    required this.options,
    required this.display,
    required this.onChanged,
    super.footer,
    this.optionTrailing,
  });

  final T value;
  final List<T> options;

  /// A widget after an option in the list, e.g. a badge.
  final Widget? Function(T option)? optionTrailing;

  /// How an option reads, on the card and in the list.
  final String Function(T option) display;

  /// Called with the picked option, only when it differs from [value].
  final ValueChanged<T> onChanged;

  String get displayValue => display(value);

  /// Opens the list and hands a different pick to [onChanged]. A method on
  /// the field, so the dialog knows the type of the options.
  Future<void> pick(BuildContext context) async {
    final picked = await showChoiceEditDialog<T>(context, this);
    if (picked != null && picked != value) onChanged(picked);
  }
}

/// A text component, edited as MiniMessage and shown with its formatting.
/// It takes a full row of its section.
final class TextComponentEdit extends EditField {
  const TextComponentEdit({
    required super.label,
    required super.icon,
    required this.value,
    required this.componentContext,
    required this.onChanged,
    super.footer,
  });

  /// The vanilla JSON text component in a string, as the backend keeps it,
  /// null when not set. A string that is no JSON is taken as plain text.
  final String? value;

  /// Where the text appears in game, for its default color and background.
  final ComponentContext componentContext;

  /// Called with the new JSON, null once the text is emptied.
  final ValueChanged<String?> onChanged;
}

/// A heading and the fields under it.
class EditSection {
  const EditSection({required this.title, required this.fields});

  final String title;
  final List<EditField> fields;
}
