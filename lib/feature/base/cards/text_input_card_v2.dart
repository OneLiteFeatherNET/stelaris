import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/feature/base/base_card.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class TextInputCard<E> extends StatefulWidget {
  final String display;
  final String message;
  final ValueUpdate<E> valueUpdate;
  final String currentValue;
  final TextInputType? inputType;
  final List<TextInputFormatter>? formatter;
  final FormFieldValidator? formValidator;
  final int maxLength;

  const TextInputCard({
    super.key,
    required this.display,
    required this.message,
    required this.valueUpdate,
    required this.currentValue,
    this.inputType,
    this.formatter,
    this.formValidator,
    required this.maxLength,
  });

  @override
  State<TextInputCard> createState() => _TextInputCardState();
}

class _TextInputCardState extends State<TextInputCard> {
  final TextEditingController _editController = TextEditingController();

  @override
  initState() {
    super.initState();
    _editController.text = widget.currentValue;
  }

  @override
  Widget build(BuildContext context) {
    return BaseCard(
        display: widget.display,
        message: widget.message,
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
              ),
              onFocusChange: (focus) {
                if (!focus && _editController.value.text.trim().isNotEmpty) {
                  widget.valueUpdate(_editController.value.text);
                }
              },
            ),
          ),
        ));
  }
}
