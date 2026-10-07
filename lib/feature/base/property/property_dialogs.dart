import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/property/property.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Edits [property] in a dialog. Resolves to the saved value, or null when
/// the dialog was cancelled.
Future<String?> showTextPropertyDialog(
  BuildContext context,
  TextProperty property,
) {
  return showDialog<String>(
    context: context,
    builder: (_) => _TextPropertyDialog(property: property),
  );
}

class _TextPropertyDialog extends StatefulWidget {
  const _TextPropertyDialog({required this.property});

  final TextProperty property;

  @override
  State<_TextPropertyDialog> createState() => _TextPropertyDialogState();
}

class _TextPropertyDialogState extends State<_TextPropertyDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller = TextEditingController(
    text: widget.property.value,
  );
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Closes with the value, unless it is invalid.
  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    return FormDialog(
      title: property.label,
      actionIcon: Icons.check,
      actionLabel: context.l10n.button_save,
      onSubmit: _save,
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: true,
          maxLength: property.maxLength,
          keyboardType: property.keyboardType,
          inputFormatters: property.formatters,
          validator: property.validator,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _save(),
          decoration: InputDecoration(
            hintText: property.hintText,
            helperText: property.tooltip,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}

/// Lets the user pick one of [property]'s options. Resolves to the picked
/// option, or null when the dialog was closed.
Future<T?> showChoicePropertyDialog<T>(
  BuildContext context,
  ChoiceProperty<T> property,
) {
  return showDialog<T>(
    context: context,
    builder: (context) => FormDialog(
      title: property.label,
      actionLabel: context.l10n.button_save,
      onSubmit: null,
      showActions: false,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in property.options)
            ListTile(
              selected: option == property.value,
              leading: option == property.value
                  ? const Icon(Icons.check)
                  : const SizedBox(width: 24),
              title: Text(property.display(option)),
              onTap: () => Navigator.of(context).pop(option),
            ),
        ],
      ),
    ),
  );
}
