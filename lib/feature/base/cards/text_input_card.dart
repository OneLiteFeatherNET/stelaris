import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:stelaris/feature/base/base_card.dart';
import 'package:stelaris/feature/base/input/material_autocomplete.dart';
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
    this.suggestsMaterials = false,
    this.focusOrder,
    super.key,
  });

  final String display;
  final void Function(String value) valueUpdate;
  final String currentValue;
  final TextInputType? inputType;
  final int maxLength;
  final bool isNumber;

  /// Suggests Minecraft materials while typing; the text stays free.
  final bool suggestsMaterials;
  final String tooltipMessage;
  final String? hintText;
  final List<TextInputFormatter>? formatter;
  final FormFieldValidator? formValidator;
  final FocusOrder? focusOrder;

  @override
  State<TextInputCard> createState() => _TextInputCardState();
}

class _TextInputCardState extends State<TextInputCard> {
  final TextEditingController _editController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final _borderRadius = BorderRadius.circular(8);

  @override
  void initState() {
    super.initState();
    _editController.text = widget.currentValue;
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _handleFieldSubmitted(_editController.text);
    }
  }

  @override
  void didUpdateWidget(TextInputCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentValue != oldWidget.currentValue) {
      _editController.text = widget.currentValue;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _editController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final outlineBorder = OutlineInputBorder(
      borderRadius: _borderRadius,
      borderSide: BorderSide(color: colorScheme.outline),
    );

    return BaseCard(
      display: widget.display,
      widget: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: _wrapWithFocusOrder(
            widget.suggestsMaterials
                ? MaterialAutocomplete(
                    controller: _editController,
                    focusNode: _focusNode,
                    onSelected: _handleFieldSubmitted,
                    fieldBuilder:
                        (context, controller, focusNode, onSubmitted) =>
                            _buildField(colorScheme, outlineBorder, (value) {
                              // Taking a suggestion rewrites the text and
                              // submits it through onSelected already.
                              onSubmitted();
                              if (controller.text == value) {
                                _handleFieldSubmitted(value);
                              }
                            }),
                  )
                : _buildField(
                    colorScheme,
                    outlineBorder,
                    _handleFieldSubmitted,
                  ),
          ),
        ),
      ),
      message: widget.tooltipMessage,
    );
  }

  Widget _buildField(
    ColorScheme colorScheme,
    OutlineInputBorder outlineBorder,
    ValueChanged<String> onFieldSubmitted,
  ) {
    return TextFormField(
      focusNode: _focusNode,
      onFieldSubmitted: onFieldSubmitted,
      maxLength: widget.maxLength,
      autovalidateMode: widget.formValidator != null
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      autocorrect: false,
      controller: _editController,
      keyboardType: widget.inputType,
      inputFormatters: widget.formatter,
      validator: widget.formValidator,
      style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        border: outlineBorder,
        enabledBorder: outlineBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      textAlign: widget.isNumber ? TextAlign.right : TextAlign.left,
    );
  }

  Widget _wrapWithFocusOrder(Widget child) {
    final focusOrder = widget.focusOrder;
    if (focusOrder == null) return child;
    return FocusTraversalOrder(order: focusOrder, child: child);
  }

  /// Hands a changed value to [TextInputCard.valueUpdate]. A field cleared
  /// down to whitespace reports an empty string, so values can be removed;
  /// an unchanged value isn't reported, so merely tabbing through a field
  /// doesn't mark the model as edited.
  void _handleFieldSubmitted(String value) {
    final String submitted = value.trim().isEmpty ? emptyString : value;
    if (submitted == widget.currentValue) return;
    widget.valueUpdate(submitted);
  }
}
