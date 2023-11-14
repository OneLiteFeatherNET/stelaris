import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class EntryEditDialog extends StatelessWidget {
  final String title;
  final String? currentValue;
  final ValueUpdate<String> valueUpdate;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator formFieldValidator;
  final TextEditingController _controller = TextEditingController();

  final _key = GlobalKey<FormState>();

  EntryEditDialog(
      {super.key,
      required this.title,
      required this.currentValue,
      required this.valueUpdate,
      this.inputFormatters,
      required this.formFieldValidator});

  @override
  Widget build(BuildContext context) {
    _controller.text = currentValue ?? emptyString;
    return SimpleDialog(
      title: Text(
        title,
        textAlign: TextAlign.center,
      ),
      contentPadding: dialogPadding,
      children: [
        horizontalSpacing10,
        Form(
          key: _key,
          autovalidateMode: AutovalidateMode.always,
          child: TextFormField(
            autofocus: true,
            controller: _controller,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            inputFormatters: inputFormatters,
            validator: formFieldValidator
          ),
        ),
        verticalSpacing25,
        TextButton(
            onPressed: () {
              if (!_key.currentState!.validate()) return;
              valueUpdate.call(_controller.text);
              context.pop();
            },
            child: Text(context.l10n.button_save)
        )
      ],
    );
  }
}
