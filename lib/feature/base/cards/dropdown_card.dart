import 'package:flutter/material.dart';
import 'package:stelaris/feature/base/base_card.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/typedefs.dart';

class DropdownCard<E, T> extends StatefulWidget {
  const DropdownCard({
    required this.display,
    required this.valueUpdate,
    required this.defaultValue,
    required this.currentValue,
    this.tooltipMessage = emptyString,
    this.items,
    this.formKey,
    this.matchTextInputHeight = false,
    super.key,
  });

  final String display;
  final ValueUpdate<E> valueUpdate;
  final DefaultValue<E, T> defaultValue;
  final T currentValue;
  final String tooltipMessage;
  final List<DropdownMenuItem<E>>? items;
  final Key? formKey;
  final bool matchTextInputHeight;

  @override
  State<DropdownCard<E, T>> createState() => _DropdownCardState<E, T>();
}

class _DropdownCardState<E, T> extends State<DropdownCard<E, T>> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: padding,
      child: BaseCard(
        display: widget.display,
        widget: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Form(
                    key: widget.formKey,
                    child: DropdownButtonFormField<E>(
                      items: widget.items,
                      value: widget.defaultValue(widget.currentValue),
                      onChanged: (E? value) {
                        if (value == null) return;
                        setState(() => widget.valueUpdate(value));
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colorScheme.outline,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      dropdownColor: colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  if (widget.matchTextInputHeight)
                    const SizedBox(height: 23), // Height of character counter
                ],
              ),
            ),
          ),
        ),
        message: widget.tooltipMessage,
      ),
    );
  }
}
