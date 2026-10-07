import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/property/property.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
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
      description: property.help,
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
      description: property.help,
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

/// Explains what [property] expects: its [Property.help] and, under it,
/// its [Property.examples], each in a block to copy it from.
Future<void> showPropertyInfoDialog(BuildContext context, Property property) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      final help = property.help;
      final examples = property.examples;
      return FormDialog(
        title: property.label,
        actionLabel: context.l10n.button_close,
        onSubmit: null,
        showActions: false,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (help != null) Text(help, style: theme.textTheme.bodyMedium),
            if (examples.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                context.l10n
                    .property_info_examples(examples.length)
                    .toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
              for (final example in examples) ...[
                const SizedBox(height: 6),
                _ExampleBlock(example: example),
              ],
            ],
          ],
        ),
      );
    },
  );
}

/// One example in monospace on a tinted block, with a button that copies
/// it, like the copyable rows of the model info dialog.
class _ExampleBlock extends StatelessWidget {
  const _ExampleBlock({required this.example});

  final String example;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                example,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy_outlined, size: 16),
              visualDensity: VisualDensity.compact,
              tooltip: context.l10n.tooltip_copy_to_clipboard,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: example));
                if (!context.mounted) return;
                context.showSuccessSnackBar(
                  context.l10n.snackbar_copied_to_clipboard,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
