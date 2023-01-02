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
  final TextEditingController _editController = TextEditingController();

  TextInputCard({Key? key, required this.title, required this.currentValue, required this.valueUpdate, this.inputType, this.formatter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _editController.text = currentValue;
    return Padding(
      padding: padding,
      child: constructContainer(
        [
          title,
          spaceBox,
          SizedBox(
            width: 300,
            height: 100,
            child: Focus(
              child: TextFormField(
                autocorrect: false,
                controller: _editController,
                keyboardType: inputType,
                inputFormatters: formatter,
              ),
              onFocusChange: (focus) {
                if (!focus) {
                  valueUpdate(_editController.value.text);
                }
              },
            ),
          )
        ]
      ),
    );
  }
}
