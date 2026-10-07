import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/property/property_dialogs.dart';

/// A plain field of a detail page, shown as a [PropertyCard] and edited in
/// a dialog of its own.
///
/// A page describes its fields as properties and hands them to a
/// [PropertyGrid]. The page stays in charge of its model: [edit] only calls
/// back with a changed value, and the page decides what to dispatch.
abstract class Property {
  const Property();

  String get label;
  String? get tooltip;

  /// What the card shows for the current value.
  String get displayValue;

  /// Whether [displayValue] stands in for an empty value.
  bool get showsPlaceholder;

  /// Opens the dialog and reports a changed value.
  Future<void> edit(BuildContext context);
}

/// A text field, edited in a text dialog.
class TextProperty extends Property {
  const TextProperty({
    required this.label,
    required this.value,
    required this.onChanged,
    this.tooltip,
    this.hintText,
    this.validator,
    this.formatters = const [],
    this.keyboardType,
    this.maxLength = 30,
  });

  @override
  final String label;
  final String value;

  /// Called with the new value when the dialog saved a changed one.
  final ValueChanged<String> onChanged;
  @override
  final String? tooltip;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter> formatters;
  final TextInputType? keyboardType;
  final int maxLength;

  @override
  String get displayValue => value.isEmpty ? (hintText ?? '–') : value;

  @override
  bool get showsPlaceholder => value.isEmpty;

  @override
  Future<void> edit(BuildContext context) async {
    final result = await showTextPropertyDialog(context, this);
    if (result != null && result != value) onChanged(result);
  }
}

/// A choice between [options], edited in a dialog that lists them.
class ChoiceProperty<T> extends Property {
  const ChoiceProperty({
    required this.label,
    required this.value,
    required this.options,
    required this.display,
    required this.onChanged,
    this.tooltip,
  });

  @override
  final String label;
  final T value;
  final List<T> options;

  /// The name an option shows on the card and in the dialog.
  final String Function(T option) display;

  /// Called with the picked option when it differs from [value].
  final ValueChanged<T> onChanged;
  @override
  final String? tooltip;

  @override
  String get displayValue => display(value);

  @override
  bool get showsPlaceholder => false;

  @override
  Future<void> edit(BuildContext context) async {
    final picked = await showChoicePropertyDialog<T>(context, this);
    if (picked != null && picked != value) onChanged(picked);
  }
}
