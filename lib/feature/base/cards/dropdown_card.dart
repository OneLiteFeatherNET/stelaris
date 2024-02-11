import 'package:flutter/material.dart';
import 'package:stelaris_ui/feature/base/base_card.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class DropdownCard<E, T> extends StatefulWidget {
  final String display;
  final ValueUpdate<E> valueUpdate;
  final DefaultValue<E, T> defaultValue;
  final T currentValue;
  final String? tooltipMessage;
  final List<DropdownMenuItem<E>>? items;
  final Key? formKey;

  const DropdownCard({
    super.key,
    required this.display,
    required this.valueUpdate,
    required this.defaultValue,
    required this.currentValue,
    this.tooltipMessage,
    this.items,
    this.formKey,
  });

  @override
  State<DropdownCard<E, T>> createState() => _DropdownCardState<E, T>();
}

class _DropdownCardState<E, T> extends State<DropdownCard<E, T>> {
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
            child: Form(
              key: widget.formKey,
              child: DropdownButtonFormField<E>(
                items: widget.items,
                value: widget.defaultValue(widget.currentValue),
                onChanged: (E? value) {
                  if (value == null) return;
                  setState(() {
                    widget.valueUpdate(value);
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
