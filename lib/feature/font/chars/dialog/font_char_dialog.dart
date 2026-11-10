import 'package:flutter/services.dart';
import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/font/font_string_actions.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/font/chars/dialog/font_char_info_dialog.dart';
import 'package:stelaris/util/font_part.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/validators.dart';

/// Keeps everything but hex digits and whitespace out of the field.
final TextInputFormatter _codePointInput = FilteringTextInputFormatter.allow(
  codePointInputCharacter,
);

/// Adds a font line, or edits [fontString] when it is given.
///
/// The line is typed as hex code points like `E000 E001` and sent as the
/// characters they stand for.
class FontCharDialog extends StatefulWidget {
  const FontCharDialog({this.fontString, super.key});

  /// The line to edit, `null` to add a new one.
  final FontStringDTO? fontString;

  @override
  State<FontCharDialog> createState() => _FontCharDialogState();
}

class _FontCharDialogState extends State<FontCharDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.fontString == null
        ? null
        : formatCodePoints(widget.fontString!.line),
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool get _isEdit => widget.fontString != null;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: _isEdit
          ? context.l10n.dialog_font_char_edit
          : context.l10n.dialog_font_char_add,
      actionIcon: _isEdit ? Icons.save_outlined : Icons.add,
      actionLabel: _isEdit ? context.l10n.button_save : context.l10n.button_add,
      onSubmit: _handleSubmit,
      titleActions: [
        IconButton(
          tooltip: context.l10n.button_help,
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => const FontCharInfoDialog(),
          ),
          icon: const Icon(Icons.help_outline),
        ),
      ],
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: TextFormField(
          autofocus: true,
          controller: _controller,
          autocorrect: false,
          // Keeps a slip like `ß` next to the `0` out of the field.
          inputFormatters: [_codePointInput],
          validator: Validators.fontLine(context.l10n),
          decoration: InputDecoration(
            labelText: context.l10n.font_char_label,
            helperText: context.l10n.font_char_helper,
          ),
          onFieldSubmitted: (_) => _handleSubmit(),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    final line = String.fromCharCodes(parseCodePoints(_controller.text)!);
    final fontString = widget.fontString;

    if (fontString == null) {
      context.dispatch(FontStringAddAction(FontStringDTO(line: line)));
    } else if (line != fontString.line) {
      context.dispatch(FontStringEditAction(fontString.copyWith(line: line)));
    }
    Navigator.of(context).pop();
  }
}
