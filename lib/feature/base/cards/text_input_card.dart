import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class TextInputCard<E> extends StatefulWidget {

  final Text title;
  final ValueUpdate<dynamic> valueUpdate;
  final String currentValue;
  final TextInputType? inputType;
  final List<TextInputFormatter>? formatter;

  const TextInputCard({Key? key, required this.title, required this.currentValue, required this.valueUpdate, this.inputType, this.formatter}) : super(key: key);

  @override
  State<TextInputCard> createState() => _TextInputCardState();
}

class _TextInputCardState extends State<TextInputCard> with BaseLayout {

  final TextEditingController _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _editController.text = widget.currentValue;
    return Padding(
      padding: padding,
      child: constructContainer(
        [
          widget.title,
          spaceBox,
          SizedBox(
            width: 300,
            height: 100,
            child: Focus(
              child: TextFormField(
                autocorrect: false,
                controller: _editController,
                keyboardType: widget.inputType,
                inputFormatters: widget.formatter,
              ),
              onFocusChange: (focus) {
                if (!focus) {
                  widget.valueUpdate(_editController.value.text);
                }
              },
            ),
          )
        ]
      ),
    );
  }
}
