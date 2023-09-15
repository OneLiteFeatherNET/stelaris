import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class TextInputCard<E> extends StatelessWidget with BaseLayout {
  final Text title;
  final ValueUpdate<dynamic> valueUpdate;
  final String currentValue;
  final TextInputType? inputType;
  final List<TextInputFormatter>? formatter;
  final TextEditingController _editController = TextEditingController();
  final IconData? infoIcon;
  final String infoText;
  final FormFieldValidator? formValidator;

  TextInputCard(
      {Key? key,
      required this.title,
      required this.currentValue,
      required this.valueUpdate,
      this.inputType,
      this.formatter,
      this.infoIcon,
      required this.infoText,
      this.formValidator})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    _editController.text = currentValue;
    return Padding(
      padding: padding,
      child: constructContainer([
        SizedBox(
          width: 300,
          height: 25,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: horizontalPadding,
                child: title,
              ),
              Tooltip(
                message: infoText,
                child: Icon(infoIcon ?? Icons.info),
              ),
            ],
          ),
        ),
        spaceBox,
        SizedBox(
          width: 300,
          height: 100,
          child: Focus(
            child: TextFormField(
                autovalidateMode: formValidator != null
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                autocorrect: false,
                controller: _editController,
                keyboardType: inputType,
                inputFormatters: formatter,
                validator: formValidator
            ),
            onFocusChange: (focus) {
              if (!focus && _editController.value.text.trim().isNotEmpty) {
                valueUpdate(_editController.value.text);
              }
            },
          ),
        )
      ]),
    );
  }
}
