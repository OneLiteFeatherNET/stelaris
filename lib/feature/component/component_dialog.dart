import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/component/minimessage_editor.dart';
import 'package:stelaris/util/component_context.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/functions.dart';
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
    this.required = true,
    super.key,
  });

  final String title;
  final String actionLabel;
  final ComponentContext componentContext;
  final ValueUpdate<String> onSave;
  final String initialValue;

  /// Whether an empty text is refused. Off, saving an empty text clears
  /// the component, e.g. an advancement's title.
  final bool required;

  @override
  State<ComponentDialog> createState() => _ComponentDialogState();
}

class _ComponentDialogState extends State<ComponentDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _text = widget.initialValue;

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(_text);
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
        child: MiniMessageEditor(
          value: _text,
          onChanged: (text) => _text = text,
          componentContext: widget.componentContext,
          autofocus: true,
          validator: widget.required
              ? (value) => checkIfEmptyAndReturnErrorString(
                  value ?? emptyString,
                  context,
                )
              : null,
          onSubmitted: (_) => _save(),
        ),
      ),
    );
  }
}
