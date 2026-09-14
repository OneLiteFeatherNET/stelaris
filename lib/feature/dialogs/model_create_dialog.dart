import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
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

  const ModelCreateDialog({
    required this.title,
    required this.projectNamespace,
    required this.onSubmit,
    this.nameHint,
    this.keyHint,
    super.key,
  });

  @override
  State<ModelCreateDialog> createState() => _ModelCreateDialogState();
}

class _ModelCreateDialogState extends State<ModelCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _keyController = TextEditingController();
  bool _hasAttemptedSubmit = false;

  @override
  void dispose() {
    _nameController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  void _handleCancel() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(false);
  }

  void _handleSubmit() {
    setState(() {
      _hasAttemptedSubmit = true;
    });
    if (!_formKey.currentState!.validate()) return;
    final name = _nameController.text.trim();
    final key = _keyController.text.trim();
    widget.onSubmit(name, key);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final autovalidateMode = _hasAttemptedSubmit
        ? AutovalidateMode.onUserInteraction
        : AutovalidateMode.disabled;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 650),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _handleCancel,
                    icon: const Icon(Icons.close),
                    splashRadius: 20,
                  ),
                ],
              ),
              const Divider(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    autovalidateMode: autovalidateMode,
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
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.preview_outlined,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  horizontalSpacing10,
                                  Text(
                                    context.l10n.dialog_model_preview_label,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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
                ),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _handleCancel,
                    child: Text(context.l10n.button_cancel),
                  ),
                  horizontalSpacing10,
                  FilledButton.icon(
                    onPressed: _handleSubmit,
                    icon: const Icon(Icons.add),
                    label: Text(context.l10n.dialog_model_create_button),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
