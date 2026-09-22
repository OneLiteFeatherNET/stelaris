import 'package:async_redux/async_redux.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/attribute_actions.dart';
import 'package:stelaris/feature/base/chips/info_chip.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// A dialog for editing an [AttributeModel]'s [AttributeModel.defaultValue]
/// and [AttributeModel.maximumValue] — the only two fields an attribute has
/// beyond its name/key, which are set once at creation and not editable
/// here.
class AttributeEditDialog extends StatefulWidget {
  final AttributeModel model;
  final String projectKey;

  const AttributeEditDialog({
    required this.model,
    required this.projectKey,
    super.key,
  });

  @override
  State<AttributeEditDialog> createState() => _AttributeEditDialogState();
}

class _AttributeEditDialogState extends State<AttributeEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _defaultValueController;
  late final TextEditingController _maximumValueController;

  @override
  void initState() {
    super.initState();
    _defaultValueController = TextEditingController(
      text: widget.model.defaultValue?.toString() ?? zeroString,
    );
    _maximumValueController = TextEditingController(
      text: widget.model.maximumValue?.toString() ?? zeroString,
    );
  }

  @override
  void dispose() {
    _defaultValueController.dispose();
    _maximumValueController.dispose();
    super.dispose();
  }

  void _handleCancel() => Navigator.of(context).pop();

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = widget.model.copyWith(
      defaultValue: double.tryParse(_defaultValueController.text) ?? 0,
      maximumValue: double.tryParse(_maximumValueController.text) ?? 0,
    );

    context.dispatch(SelectAttributeAction(updated));
    await context.dispatchAndWait(AttributeDatabaseUpdate());
    if (mounted) Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final numberFormatter = [FilteringTextInputFormatter.allow(numberPattern)];
    final key = widget.model.key;
    final namespacedKey = key != null && key.isNotEmpty
        ? '${widget.projectKey}:$key'
        : null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.dialog_attribute_edit_title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
              Text(
                widget.model.uiName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (namespacedKey != null) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: InfoChip(
                    icon: Icons.vpn_key_outlined,
                    text: namespacedKey,
                  ),
                ),
              ],
              const Divider(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _defaultValueController,
                      keyboardType: TextInputType.number,
                      inputFormatters: numberFormatter,
                      decoration: InputDecoration(
                        labelText: context.l10n.card_attribute_default_value,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    verticalSpacing10,
                    TextFormField(
                      controller: _maximumValueController,
                      keyboardType: TextInputType.number,
                      inputFormatters: numberFormatter,
                      decoration: InputDecoration(
                        labelText: context.l10n.card_attribute_maximum_value,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
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
                    onPressed: _handleSave,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(context.l10n.button_save),
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
