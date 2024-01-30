import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/feature/base/base_card.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class TextInputCard2<E> extends StatefulWidget {
  final String display;
  final String? tooltipMessage;
  final String? hintText;
  final ValueUpdate<E> valueUpdate;
  final String currentValue;
  final TextInputType? inputType;
  final List<TextInputFormatter>? formatter;
  final FormFieldValidator? formValidator;
  final int maxLength;
  final bool isNumber;

  const TextInputCard2({
    super.key,
    required this.display,
    this.tooltipMessage,
    this.hintText,
    required this.valueUpdate,
    required this.currentValue,
    this.inputType,
    this.formatter,
    this.formValidator,
    this.maxLength = 30,
    this.isNumber = false,
  });

  @override
  State<TextInputCard2> createState() => _TextInputCardState();
}

class _TextInputCardState extends State<TextInputCard2> {
  final TextEditingController _editController = TextEditingController();

  @override
  initState() {
    super.initState();
    _editController.text = widget.currentValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: BaseCard(
        display: widget.display,
        message: widget.tooltipMessage,
        widget: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Focus(
              child: TextFormField(
                maxLength: widget.maxLength,
                autovalidateMode: widget.formValidator != null
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                autocorrect: false,
                controller: _editController,
                keyboardType: widget.inputType,
                inputFormatters: widget.formatter,
                validator: widget.formValidator,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                ),
                textAlign: widget.isNumber ? TextAlign.right : TextAlign.left,
              ),
              onFocusChange: (focus) {
                if (!focus && _editController.value.text.trim().isNotEmpty) {
                  widget.valueUpdate(_editController.value.text);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
