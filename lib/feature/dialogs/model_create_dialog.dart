import 'package:flutter/services.dart';
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
class ModelCreateDialog extends StatefulWidget {
  final String title;
  final String projectNamespace;
  final void Function(String name, String key) onSubmit;
  final String? nameHint;
  final String? keyHint;
  final double maxWidth;

  const ModelCreateDialog({
    required this.title,
    required this.projectNamespace,
    required this.onSubmit,
    this.nameHint,
    this.keyHint,
    this.maxWidth = 520,
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
    final theme = Theme.of(context);

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
              inputFormatters: [
                FilteringTextInputFormatter.allow(stringWithSpacePattern),
              ],
              decoration: InputDecoration(
                labelText: '${context.l10n.dialog_model_name_label} *',
                hintText: widget.nameHint ?? context.l10n.dialog_model_name_hint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: Validators.required('Name is required'),
              onFieldSubmitted: (_) => _handleSubmit(),
            ),
            verticalSpacing10,
            TextFormField(
              controller: _keyController,
              inputFormatters: const [lowerCaseFormatter],
              decoration: InputDecoration(
                labelText: '${context.l10n.dialog_model_key_label} *',
                hintText: widget.keyHint ?? context.l10n.dialog_model_key_hint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.vpn_key_outlined),
              ),
              validator: Validators.adventureKeyPart(),
              onFieldSubmitted: (_) => _handleSubmit(),
            ),
            verticalSpacing10,
            NoticeBox(
              icon: Icons.preview_outlined,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.dialog_model_preview_label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _keyController,
                    builder: (context, value, _) {
                      final text = value.text.trim();
                      return Text(
                        '${widget.projectNamespace}:${text.isEmpty ? '<key>' : text}',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: text.isEmpty
                              ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                              : theme.colorScheme.primary,
                          fontStyle: text.isEmpty
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
