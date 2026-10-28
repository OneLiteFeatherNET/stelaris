import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/validators.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// A variable name as EvalEx reads it: a letter or underscore, then letters,
/// digits and underscores.
final RegExp expressionVariableNamePattern = RegExp(
  r'^[A-Za-z_][A-Za-z0-9_]*$',
);

/// The label of a variable type, e.g. Number.
String expressionVariableTypeLabel(
  AppLocalizations l10n,
  ExpressionVariableType type,
) => switch (type) {
  ExpressionVariableType.NUMBER => l10n.expression_variable_type_number,
  ExpressionVariableType.BOOLEAN => l10n.expression_variable_type_boolean,
  ExpressionVariableType.STRING => l10n.expression_variable_type_string,
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
  late ExpressionVariableType _type =
      widget.variable?.type ?? ExpressionVariableType.NUMBER;

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

  /// A boolean takes a pick of true or false, or none, instead of text.
  Widget _testValueField(AppLocalizations l10n) {
    if (_type != ExpressionVariableType.BOOLEAN) {
      return TextFormField(
        controller: _testValue,
        decoration: InputDecoration(
          labelText: l10n.expression_variable_test_value_label,
          helperText: l10n.expression_variable_test_value_hint,
          prefixIcon: const Icon(Icons.science_outlined),
        ),
      );
    }
    final current = _testValue.text;
    return DropdownButtonFormField<String?>(
      initialValue: current == 'true' || current == 'false' ? current : null,
      decoration: InputDecoration(
        labelText: l10n.expression_variable_test_value_label,
        helperText: l10n.expression_variable_test_value_hint,
        prefixIcon: const Icon(Icons.science_outlined),
      ),
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: Text(l10n.expression_variable_test_value_none),
        ),
        const DropdownMenuItem<String?>(value: 'true', child: Text('true')),
        const DropdownMenuItem<String?>(value: 'false', child: Text('false')),
      ],
      onChanged: (value) => setState(() => _testValue.text = value ?? ''),
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
      actionIcon: Icons.check,
      actionLabel: l10n.button_save,
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
              decoration: InputDecoration(
                labelText: '${l10n.expression_variable_name_label} *',
                hintText: l10n.expression_variable_name_hint,
                prefixIcon: const Icon(Icons.title),
              ),
              validator: _validateName,
            ),
            verticalSpacing10,
            DropdownButtonFormField<ExpressionVariableType>(
              initialValue: _type,
              decoration: InputDecoration(
                labelText: l10n.expression_variable_type_label,
                prefixIcon: const Icon(Icons.category_outlined),
              ),
              items: [
                for (final type in ExpressionVariableType.values)
                  DropdownMenuItem(
                    value: type,
                    child: Text(expressionVariableTypeLabel(l10n, type)),
                  ),
              ],
              onChanged: (type) {
                if (type == null) return;
                setState(() {
                  // A value typed as text may not be one of the booleans.
                  if (type == ExpressionVariableType.BOOLEAN &&
                      _testValue.text != 'true' &&
                      _testValue.text != 'false') {
                    _testValue.text = emptyString;
                  }
                  _type = type;
                });
              },
            ),
            verticalSpacing10,
            _testValueField(l10n),
          ],
        ),
      ),
    );
  }
}
