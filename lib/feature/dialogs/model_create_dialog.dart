import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/dialog/notice_box.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/formatter/formatters.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/validators.dart';

/// A dialog for creating models that require a display name and a Kyori Adventure key.
///
/// Features:
/// - Display name field (`uiName`)
/// - Key field with Adventure key-part validation
/// - Live preview of the resulting `namespace:key`
///
/// Models without a key, such as expressions, pass `askKey: false`. The key
/// field and its preview are then left out, and the key handed to [onSubmit]
/// is empty.
///
/// A model whose name gives it something else, such as a function's
/// identifier, passes [namePreview]. It is shown live below the name field,
/// in place of the key preview.
class ModelCreateDialog extends StatefulWidget {
  final String title;
  final String projectNamespace;
  final void Function(String name, String key) onSubmit;
  final String? nameHint;
  final String? keyHint;
  final double maxWidth;
  final bool askKey;

  /// What the typed name turns into, shown live below the name field.
  final NamePreview? namePreview;

  const ModelCreateDialog({
    required this.title,
    required this.projectNamespace,
    required this.onSubmit,
    this.nameHint,
    this.keyHint,
    this.maxWidth = 520,
    this.askKey = true,
    this.namePreview,
    super.key,
  });

  @override
  State<ModelCreateDialog> createState() => _ModelCreateDialogState();
}

class _ModelCreateDialogState extends State<ModelCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _keyController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameController.text.trim();
    final key = _keyController.text.trim();
    widget.onSubmit(name, key);
  }

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: widget.title,
      actionIcon: Icons.add,
      actionLabel: context.l10n.dialog_model_create_button,
      maxWidth: widget.maxWidth,
      onSubmit: _handleSubmit,
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              maxLength: maxTextLength,
              decoration: InputDecoration(
                labelText: '${context.l10n.dialog_model_name_label} *',
                hintText: widget.nameHint ?? context.l10n.dialog_model_name_hint,
                prefixIcon: const Icon(Icons.title),
              ),
              validator: Validators.required(context.l10n.validation_name_required),
              onFieldSubmitted: (_) => _handleSubmit(),
            ),
            if (widget.askKey) ...[
              verticalSpacing10,
              TextFormField(
                controller: _keyController,
                maxLength: maxTextLength,
                inputFormatters: const [lowerCaseFormatter],
                decoration: InputDecoration(
                  labelText: '${context.l10n.dialog_model_key_label} *',
                  hintText: widget.keyHint ?? context.l10n.dialog_model_key_hint,
                  prefixIcon: const Icon(Icons.vpn_key_outlined),
                ),
                validator: Validators.adventureKeyPart(context.l10n),
                onFieldSubmitted: (_) => _handleSubmit(),
              ),
              verticalSpacing10,
              _PreviewBox(
                label: context.l10n.dialog_model_preview_label,
                listenable: _keyController,
                text: (key) => '${widget.projectNamespace}:$key',
                placeholder: '${widget.projectNamespace}:<key>',
              ),
            ],
            if (widget.namePreview case final preview?) ...[
              verticalSpacing10,
              _PreviewBox(
                label: preview.label,
                listenable: _nameController,
                text: preview.fromName,
                placeholder: preview.fromName(''),
                note: preview.note,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// What a create dialog's typed name turns into: [fromName] makes it from the
/// name, [label] says what it is, and [note] adds a line below it.
class NamePreview {
  const NamePreview({required this.label, required this.fromName, this.note});

  final String label;
  final String Function(String name) fromName;
  final String? note;
}

/// A live preview of what [listenable]'s text turns into, through [text].
/// While the text is empty, [placeholder] is shown greyed out.
class _PreviewBox extends StatelessWidget {
  const _PreviewBox({
    required this.label,
    required this.listenable,
    required this.text,
    required this.placeholder,
    this.note,
  });

  final String label;
  final ValueListenable<TextEditingValue> listenable;
  final String Function(String value) text;
  final String placeholder;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NoticeBox(
      icon: Icons.preview_outlined,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: listenable,
            builder: (context, value, _) {
              final typed = value.text.trim();
              return Text(
                typed.isEmpty ? placeholder : text(typed),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: typed.isEmpty
                      ? theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        )
                      : theme.colorScheme.primary,
                  fontStyle: typed.isEmpty
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              );
            },
          ),
          if (note case final note?) ...[
            const SizedBox(height: 6),
            Text(
              note,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
