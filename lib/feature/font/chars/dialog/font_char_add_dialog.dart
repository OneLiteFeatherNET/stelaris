import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/font/font_string_actions.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/util/l10n_ext.dart';

final regex = RegExp(r'^[0-9A-Fa-f]{4}$');

class FontCharAddDialog extends StatefulWidget {
  const FontCharAddDialog({required this.fontModel, super.key});

  final FontModel fontModel;

  @override
  State<FontCharAddDialog> createState() => _FontCharAddDialogState();
}

class _FontCharAddDialogState extends State<FontCharAddDialog> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: context.l10n.dialog_font_char_add,
      actionIcon: Icons.add,
      actionLabel: context.l10n.button_add,
      onSubmit: _handleAdd,
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: TextFormField(
          autofocus: true,
          controller: _controller,
          autocorrect: false,
          validator: (value) => _validateHexGlyph(value),
          decoration: InputDecoration(
            labelText: context.l10n.font_char_label,
            hintText: 'E000',
            border: const OutlineInputBorder(),
          ),
          onFieldSubmitted: (_) => _handleAdd(),
        ),
      ),
    );
  }

  void _handleAdd() {
    if (!_formKey.currentState!.validate()) return;
    final String value = _controller.text;

    if (value.trim().isEmpty) return;
    context.dispatch(FontStringAddAction(FontStringDTO(line: value)));
    Navigator.of(context).pop();
  }

  String? _validateHexGlyph(String? input) {
    if (input == null || input.trim().isEmpty) {
      return context.l10n.validation_codepoint_required;
    }

    final hex = input.trim();

    // Must be 4 hex digits
    if (!regex.hasMatch(hex)) {
      return context.l10n.validation_codepoint_invalid;
    }

    return null;
  }
}
