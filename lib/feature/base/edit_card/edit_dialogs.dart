import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/edit_card/edit_field.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Opens the dialog of [field] and hands a changed value to it.
Future<void> editField(BuildContext context, EditField field) async {
  switch (field) {
    case TextEdit():
      final value = await showDialog<String>(
        context: context,
        builder: (_) => _TextEditDialog(field: field),
      );
      if (value != null && value != field.value) field.onChanged(value);
  }
}

/// Edits a [TextEdit] in one line. Opens with the value selected, so typing
/// replaces it, and Enter saves.
class _TextEditDialog extends StatefulWidget {
  const _TextEditDialog({required this.field});

  final TextEdit field;

  @override
  State<_TextEditDialog> createState() => _TextEditDialogState();
}

class _TextEditDialogState extends State<_TextEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller =
      TextEditingController(text: widget.field.value)
        ..selection = TextSelection(
          baseOffset: 0,
          extentOffset: widget.field.value.length,
        );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final field = widget.field;
    return FormDialog(
      title: field.label,
      actionIcon: Icons.check,
      actionLabel: context.l10n.button_save,
      maxWidth: 440,
      onSubmit: _save,
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          maxLength: field.maxLength,
          keyboardType: field.keyboardType,
          inputFormatters: field.formatters,
          validator: field.validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _save(),
          decoration: InputDecoration(
            hintText: field.hintText,
            helperText: field.footer,
            helperMaxLines: 3,
          ),
        ),
      ),
    );
  }
}
