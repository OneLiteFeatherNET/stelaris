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
