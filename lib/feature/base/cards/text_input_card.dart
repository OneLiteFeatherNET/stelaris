import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/feature/base/base_card.dart';
import 'package:stelaris_ui/util/constants.dart';

class TextInputCard<E> extends StatefulWidget {
  final String display;
  final void Function(dynamic value) valueUpdate;
  final String currentValue;
  final TextInputType? inputType;
  final int maxLength;
  final bool isNumber;
  final String? tooltipMessage;
  final String? hintText;
  final List<TextInputFormatter>? formatter;
  final FormFieldValidator? formValidator;

  const TextInputCard({
    required this.display,
    required this.valueUpdate,
    required this.currentValue,
    this.tooltipMessage,
    this.hintText,
    this.inputType,
    this.formatter,
    this.formValidator,
    this.maxLength = 30,
    this.isNumber = false,
    super.key,
  });

  @override
  State<TextInputCard> createState() => _TextInputCardState();
}

class _TextInputCardState extends State<TextInputCard> {
  final TextEditingController _editController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  initState() {
    super.initState();
    _editController.text = widget.currentValue;
  }

  @override
  void dispose() {
    _editController.dispose();
    _focusNode.dispose();
    super.dispose();
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
              focusNode: _focusNode,
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
                if (focus) return;
                String value = _editController.value.text;
                if (value.trim().isEmpty) return;
                widget.valueUpdate(value);
              },
            ),
          ),
        ),
      ),
    );
  }
}
