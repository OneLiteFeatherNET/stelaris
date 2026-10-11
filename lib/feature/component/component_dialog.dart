import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/component/minimessage_field.dart';
import 'package:stelaris/util/component_context.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/functions.dart';
import 'package:stelaris/util/typedefs.dart';

/// Edits one MiniMessage component. Hands the text to [onSave], which also
/// closes the dialog.
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(_controller.text);
  }

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
        child: MiniMessageField(
          controller: _controller,
          validator: (value) =>
              checkIfEmptyAndReturnErrorString(value ?? emptyString, context),
          onSubmitted: (_) => _save(),
        ),
      ),
    );
  }
}
