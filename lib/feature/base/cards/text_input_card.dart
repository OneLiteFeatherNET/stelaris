import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris/feature/base/base_card.dart';
import 'package:stelaris/util/constants.dart';

/// A card widget that contains a text input field with validation and formatting options.
class TextInputCard<E> extends StatefulWidget {
  const TextInputCard({
    required this.display,
    required this.valueUpdate,
    required this.currentValue,
    this.tooltipMessage = emptyString, // Default to an empty string
    this.hintText,
    this.inputType,
    this.formatter,
    this.formValidator,
    this.maxLength = 30,
    this.isNumber = false,
    super.key,
  });

  final String display;
  final void Function(String value) valueUpdate;
  final String currentValue;
  final TextInputType? inputType;
  final int maxLength;
  final bool isNumber;
  final String tooltipMessage;
  final String? hintText;
  final List<TextInputFormatter>? formatter;
  final FormFieldValidator? formValidator;

  @override
  State<TextInputCard> createState() => _TextInputCardState();
}

class _TextInputCardState extends State<TextInputCard> {
  final TextEditingController _editController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
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
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(8);

    return Padding(
      padding: padding,
      child: BaseCard(
        display: widget.display,
        widget: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
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
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: borderRadius,
                    borderSide: BorderSide(
                      color: colorScheme.outline,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: borderRadius,
                    borderSide: BorderSide(
                      color: colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: borderRadius,
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: borderRadius,
                    borderSide: BorderSide(
                      color: colorScheme.error,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: borderRadius,
                    borderSide: BorderSide(
                      color: colorScheme.error,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                textAlign: widget.isNumber ? TextAlign.right : TextAlign.left,
              ),
              onFocusChange: (focus) {
                if (focus) return;
                _handleFieldSubmitted(_editController.text);
              },
            ),
          ),
        ),
        message: widget.tooltipMessage,
      ),
    );
  }

  void _handleFieldSubmitted(String value) {
    if (value.trim().isNotEmpty) {
      widget.valueUpdate(value);
    }
  }
}
