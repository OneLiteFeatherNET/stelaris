import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';

typedef StringValueUpdate = void Function(String value);

class EntryAddDialog extends StatelessWidget {

  final Text title;
  final TextEditingController controller;
  final StringValueUpdate valueUpdate;
  final List<TextInputFormatter>? formatters;

  const EntryAddDialog({Key? key, required this.title, required this.controller, required this.valueUpdate, this.formatters}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: title,
      contentPadding: dialogPadding,
      children: [
        TextFormField(
          keyboardType: TextInputType.text,
          controller: controller,
          inputFormatters: formatters,
        ),
        spaceTwentyFiveHeightBox,
        TextButton(
            onPressed: () {
              if (controller.value.text.isEmpty) return;
              valueUpdate(controller.value.text);
              },
            child: Text(context.l10n.button_add)
        )
      ],
    );
  }
}
