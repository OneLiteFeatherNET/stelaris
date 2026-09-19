import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/typedefs.dart';

class EntryUpdateDialog extends StatefulWidget {
  const EntryUpdateDialog({
    required this.title,
    required this.formKey,
    required this.valueUpdate,
    this.formatters,
    this.formFieldValidator,
    this.hintText,
    this.clearFunction,
    this.data,
    super.key,
  });

  final String title;
  final GlobalKey<FormState> formKey;
  final ValueUpdate<String> valueUpdate;
  final FormFieldValidator? formFieldValidator;
  final List<TextInputFormatter>? formatters;
  final String? hintText;
  final bool Function(String)? clearFunction;
  final String? data;

  @override
  State<EntryUpdateDialog> createState() => _EntryUpdateDialogState();
}

class _EntryUpdateDialogState extends State<EntryUpdateDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    if (widget.data != null) _controller.text = widget.data!;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: widget.title,
      actionIcon: Icons.check,
      actionLabel: context.l10n.button_add,
      onSubmit: _handleCreateClick,
      content: Form(
        key: widget.formKey,
        child: TextFormField(
          autofocus: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: _controller,
          inputFormatters: widget.formatters,
          validator: widget.formFieldValidator,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: const OutlineInputBorder(),
            suffixIcon: _getSuffixWidget(),
          ),
        ),
      ),
    );
  }

  void _handleCreateClick() {
    if (!widget.formKey.currentState!.validate()) return;
    final String input = _controller.value.text;
    if (input.isEmpty) return;
    widget.valueUpdate(input);
  }

  Widget? _getSuffixWidget() {
    if (widget.clearFunction == null) return null;
    return IconButton(
      onPressed: () {
        if (!widget.clearFunction!.call(_controller.value.text)) return;
        _controller.text = emptyString;
      },
      icon: const Icon(Icons.clear_sharp),
    );
  }
}
