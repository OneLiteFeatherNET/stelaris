import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class TextInputCard<E> extends StatelessWidget with BaseLayout {

  final Text title;
  final ValueUpdate<dynamic> valueUpdate;
  final String currentValue;
  final TextInputType? inputType;
  final List<TextInputFormatter>? formatter;
  final Validator<String>? validator;
  final String? errorMessage;
  final TextEditingController _editController = TextEditingController();
  final IconData? infoIcon;
  final String infoText;

  TextInputCard(
      {Key? key,
      required this.title,
      required this.currentValue,
      required this.valueUpdate,
      this.inputType,
      this.formatter,
      this.infoIcon,
      required this.infoText, this.validator, this.errorMessage})
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
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
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
              autovalidateMode: validator != null && errorMessage != null ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
              autocorrect: false,
              controller: _editController,
              keyboardType: inputType,
              inputFormatters: formatter,
              validator: (value) {
                if (validator == null) return null;
                if (validator!(value)) {
                  return errorMessage;
                }
              }
            ),
            onFocusChange: (focus) {
              if (!focus) {
                valueUpdate(_editController.value.text);
              }
            },
          ),
        )
      ]),
    );
  }
}
