import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/util/constants.dart';

typedef StringValueUpdate = void Function(String value);

class EntryAddDialog extends StatelessWidget {

  final Text title;
  final TextEditingController controller;
  final StringValueUpdate valueUpdate;

  const EntryAddDialog({Key? key, required this.title, required this.controller, required this.valueUpdate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: title,
      contentPadding: const EdgeInsets.all(20.0),
      children: [
        TextFormField(
          keyboardType: TextInputType.text,
          controller: controller,
          inputFormatters: [FilteringTextInputFormatter.allow(numberPattern)],
        ),
        const SizedBox(height: 25),
        TextButton(
            onPressed: () {
              if (controller.value.text.isEmpty) return;
              valueUpdate(controller.value.text);
              },
            child: addText
        )
      ],
    );
  }
}
