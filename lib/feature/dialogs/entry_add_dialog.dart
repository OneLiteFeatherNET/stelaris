import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';

typedef StringValueUpdate = void Function(String value);

class EntryAddDialog extends StatelessWidget {
  final Text title;
  final TextEditingController controller;
  final StringValueUpdate valueUpdate;
  final List<TextInputFormatter>? formatters;
  final bool? forceClose;
  final FormFieldValidator? formFieldValidator;

  final _key = GlobalKey<FormState>();

  EntryAddDialog(
      {Key? key,
      required this.title,
      required this.controller,
      required this.valueUpdate,
      this.formatters,
      this.forceClose,
      this.formFieldValidator})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: title,
      contentPadding: dialogPadding,
      children: [
        Form(
          key: _key,
          autovalidateMode: AutovalidateMode.always,
          child: TextFormField(
            autofocus: true,
            controller: controller,
            inputFormatters: formatters,
            validator: formFieldValidator,
          ),
        ),
        verticalSpacing25,
        TextButton(
            onPressed: () {
              if (!_key.currentState!.validate()) return;
              if (controller.value.text.isEmpty) return;

              if (forceClose != null && forceClose!) {
                context.pop(true);
              }
              valueUpdate(controller.value.text);
            },
            child: Text(context.l10n.button_add))
      ],
    );
  }
}
