import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/expression/expression_value_field.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/validators.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/base/input/length_counter.dart';

/// A variable name as EvalEx reads it: a letter or underscore, then letters,
/// digits and underscores.
final RegExp expressionVariableNamePattern = RegExp(
  r'^[A-Za-z_][A-Za-z0-9_]*$',
);

/// The label of a variable type, e.g. Number.
String expressionVariableTypeLabel(
  AppLocalizations l10n,
  ExpressionValueType type,
) => switch (type) {
  ExpressionValueType.number => l10n.expression_variable_type_number,
  ExpressionValueType.boolean => l10n.expression_variable_type_boolean,
  ExpressionValueType.string => l10n.expression_variable_type_string,
};

/// The icon of a variable [type], on its chips and in the preview.
IconData expressionVariableTypeIcon(ExpressionValueType type) => switch (type) {
  ExpressionValueType.number => Icons.tag,
  ExpressionValueType.boolean => Icons.toggle_on_outlined,
  ExpressionValueType.string => Icons.text_fields,
};

/// Opens the dialog that adds a variable when [variable] is null, and edits
/// it otherwise. [taken] are the names of the other variables of the
/// expression, which the name may not repeat. [parameter] words the dialog for
/// a parameter of a function instead. Resolves to the variable submitted, or
/// null when closed.
Future<ExpressionVariable?> showExpressionVariableDialog(
  BuildContext context, {
  required List<String> taken,
  ExpressionVariable? variable,
  bool parameter = false,
}) {
  return showDialog<ExpressionVariable>(
    context: context,
    builder: (_) => ExpressionVariableDialog(
      taken: taken,
      variable: variable,
      parameter: parameter,
    ),
  );
}

/// Adds or edits one variable: its name, type and optional test value.
class ExpressionVariableDialog extends StatefulWidget {
  const ExpressionVariableDialog({
    required this.taken,
    this.variable,
    this.parameter = false,
    super.key,
  });

  final ExpressionVariable? variable;
  final List<String> taken;

  /// Whether this is a parameter of a function, which only changes the words.
  final bool parameter;

  @override
  State<ExpressionVariableDialog> createState() =>
      _ExpressionVariableDialogState();
}

class _ExpressionVariableDialogState extends State<ExpressionVariableDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(
    text: widget.variable?.name ?? emptyString,
  );
  late final TextEditingController _testValue = TextEditingController(
    text: widget.variable?.testValue ?? emptyString,
  );
  late ExpressionValueType _type =
      widget.variable?.type ?? ExpressionValueType.number;

  @override
  void dispose() {
    _name.dispose();
    _testValue.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final l10n = context.l10n;
    final name = value?.trim() ?? emptyString;
    return Validators.required(l10n.validation_name_required)(name) ??
        Validators.pattern(
          expressionVariableNamePattern,
          l10n.expression_variable_name_invalid,
        )(name) ??
        (widget.taken.contains(name)
            ? l10n.expression_variable_name_duplicate(name)
            : null);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final testValue = _testValue.text;
    Navigator.of(context).pop(
      ExpressionVariable(
        name: _name.text.trim(),
        type: _type,
        testValue: testValue.isEmpty ? null : testValue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FormDialog(
      title: widget.parameter
          ? (widget.variable == null
                ? l10n.expression_function_parameter_add_title
                : l10n.expression_function_parameter_edit_title)
          : (widget.variable == null
                ? l10n.expression_variable_add_title
                : l10n.expression_variable_edit_title),
      actionIcon: widget.variable == null ? Icons.add : Icons.save_outlined,
      actionLabel: widget.variable == null ? l10n.button_add : l10n.button_save,
      maxWidth: 440,
      onSubmit: _save,
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _name,
              autofocus: true,
              maxLength: maxTextLength,
              buildCounter: nearLimitCounter,
              decoration: InputDecoration(
                labelText: '${l10n.expression_variable_name_label} *',
                hintText: l10n.expression_variable_name_hint,
                prefixIcon: const Icon(Icons.title),
              ),
              validator: _validateName,
            ),
            verticalSpacing10,
            DropdownButtonFormField<ExpressionValueType>(
              initialValue: _type,
              decoration: InputDecoration(
                labelText: l10n.expression_variable_type_label,
                prefixIcon: const Icon(Icons.category_outlined),
              ),
              items: [
                for (final type in ExpressionValueType.values)
                  DropdownMenuItem(
                    value: type,
                    child: Text(expressionVariableTypeLabel(l10n, type)),
                  ),
              ],
              onChanged: (type) {
                if (type == null) return;
                setState(() {
                  // A value of the old type may not fit the new one.
                  if (!isExpressionValueValid(type, _testValue.text)) {
                    _testValue.text = emptyString;
                  }
                  _type = type;
                });
              },
            ),
            verticalSpacing10,
            ExpressionValueField(
              controller: _testValue,
              type: _type,
              decoration: InputDecoration(
                labelText: l10n.expression_variable_test_value_label,
                helperText: l10n.expression_variable_test_value_hint,
                prefixIcon: const Icon(Icons.science_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
