import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/component/component_toolbar.dart';
import 'package:stelaris/feature/component/minimessage_field.dart';
import 'package:stelaris/util/component_context.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/functions.dart';
import 'package:stelaris/util/minimessage_editing.dart';
import 'package:stelaris/util/typedefs.dart';

/// Edits one MiniMessage component with a formatting toolbar. Hands the
/// text to [onSave], which also closes the dialog.
class ComponentDialog extends StatefulWidget {
  const ComponentDialog({
    required this.title,
    required this.actionLabel,
    required this.componentContext,
    required this.onSave,
    this.initialValue = emptyString,
    super.key,
  });

  final String title;
  final String actionLabel;
  final ComponentContext componentContext;
  final ValueUpdate<String> onSave;
  final String initialValue;

  @override
  State<ComponentDialog> createState() => _ComponentDialogState();
}

class _ComponentDialogState extends State<ComponentDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final MiniMessageController _controller = MiniMessageController(
    componentContext: widget.componentContext,
    text: widget.initialValue,
  );
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(_controller.text);
  }

  void _toggle(String tag) {
    _controller.value = MiniMessageEditing.toggle(_controller.value, tag);
  }

  Map<ShortcutActivator, VoidCallback> get _shortcuts => {
    for (final (key, tag) in [
      (LogicalKeyboardKey.keyB, 'b'),
      (LogicalKeyboardKey.keyI, 'i'),
      (LogicalKeyboardKey.keyU, 'u'),
    ]) ...{
      SingleActivator(key, control: true): () => _toggle(tag),
      SingleActivator(key, meta: true): () => _toggle(tag),
    },
  };

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: widget.title,
      maxWidth: 640,
      actionIcon: Icons.check,
      actionLabel: widget.actionLabel,
      onSubmit: _save,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ComponentToolbar(controller: _controller, focusNode: _focusNode),
            const SizedBox(height: 8),
            CallbackShortcuts(
              bindings: _shortcuts,
              child: MiniMessageField(
                controller: _controller,
                focusNode: _focusNode,
                validator: (value) => checkIfEmptyAndReturnErrorString(
                  value ?? emptyString,
                  context,
                ),
                onSubmitted: (_) => _save(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
