import 'package:material_ui/material_ui.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/formatter/formatters.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Whether [value] is a valid value of [type]. An empty value counts as
/// valid, a test value being optional.
bool isExpressionValueValid(ExpressionValueType type, String value) =>
    value.isEmpty ||
    switch (type) {
      ExpressionValueType.number => double.tryParse(value.trim()) != null,
      ExpressionValueType.boolean => value == 'true' || value == 'false',
      ExpressionValueType.string => true,
    };

/// The input of one value of a variable of [type], kept in [controller]: a
/// number takes only digits, a sign and a decimal point, a boolean is picked
/// from true or false, and a string takes any text. Empty is allowed.
class ExpressionValueField extends StatelessWidget {
  const ExpressionValueField({
    required this.controller,
    required this.type,
    required this.decoration,
    super.key,
  });

  final TextEditingController controller;
  final ExpressionValueType type;
  final InputDecoration decoration;

  /// Only a number can be typed in invalid, e.g. a lone "-" or ".".
  String? _validate(AppLocalizations l10n, String? value) =>
      isExpressionValueValid(type, value ?? '')
      ? null
      : l10n.validation_number_invalid;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (type == ExpressionValueType.boolean) {
      final current = controller.text;
      return DropdownButtonFormField<String?>(
        initialValue: current == 'true' || current == 'false' ? current : null,
        decoration: decoration,
        items: [
          DropdownMenuItem<String?>(
            value: null,
            child: Text(l10n.expression_variable_test_value_none),
          ),
          const DropdownMenuItem<String?>(value: 'true', child: Text('true')),
          const DropdownMenuItem<String?>(value: 'false', child: Text('false')),
        ],
        onChanged: (value) => controller.text = value ?? '',
      );
    }
    final number = type == ExpressionValueType.number;
    return TextFormField(
      controller: controller,
      decoration: decoration,
      keyboardType: number
          ? const TextInputType.numberWithOptions(signed: true, decimal: true)
          : null,
      inputFormatters: number ? [decimalFormatter] : null,
      autovalidateMode: AutovalidateMode.always,
      validator: (value) => _validate(l10n, value),
    );
  }
}
