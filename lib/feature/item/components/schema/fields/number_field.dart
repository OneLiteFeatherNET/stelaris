import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The input of an int or float value, validated against its bounds.
class NumberField extends StatelessWidget {
  const NumberField({
    required this.label,
    required this.text,
    required this.min,
    required this.max,
    required this.parse,
    required this.onChanged,
    this.decimal = false,
    this.suffix,
    super.key,
  });

  final String? label;
  final String text;
  final num? min;
  final num? max;
  final bool decimal;
  final num? Function(String) parse;
  final ValueChanged<Object?> onChanged;

  /// An action inside the input, see [SchemaField.suffix].
  final Widget? suffix;

  String? _range(AppLocalizations l10n) => switch ((min, max)) {
    (null, null) => null,
    (final min?, null) => l10n.component_range_min('$min'),
    (null, final max?) => l10n.component_range_max('$max'),
    (final min?, final max?) => l10n.component_range_between('$min', '$max'),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final range = _range(l10n);
    return TextFormField(
      initialValue: text,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        helperText: range,
        suffixIcon: suffix,
      ),
      keyboardType: TextInputType.numberWithOptions(
        decimal: decimal,
        signed: true,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(decimal ? r'[-0-9.]' : r'[-0-9]'),
        ),
      ],
      validator: (input) {
        if (input == null || input.isEmpty) {
          return l10n.component_value_required;
        }
        final number = parse(input);
        if (number == null) return l10n.component_not_a_number;
        if (min != null && number < min!) return range;
        if (max != null && number > max!) return range;
        return null;
      },
      onChanged: (input) => onChanged(parse(input)),
    );
  }
}
