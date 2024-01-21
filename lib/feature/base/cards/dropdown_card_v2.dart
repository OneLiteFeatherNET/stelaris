import 'package:flutter/material.dart';
import 'package:stelaris_ui/feature/base/base_card.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class DropdownCardV2<E, T> extends StatefulWidget {
  final String title;
  final String message;
  final List<DropdownMenuItem<E>>? items;
  final ValueUpdate<E> valueUpdate;
  final DefaultValue<E, T> defaultValue;
  final T currentValue;
  final Key? formKey;

  const DropdownCardV2({
    super.key,
    required this.title,
    required this.message,
    this.items,
    required this.valueUpdate,
    required this.defaultValue,
    required this.currentValue,
    this.formKey,
  });

  @override
  State<DropdownCardV2<E, T>> createState() => _DropdownCardV2State<E, T>();
}

class _DropdownCardV2State<E, T> extends State<DropdownCardV2<E, T>> {
  @override
  Widget build(BuildContext context) {
    return BaseCard(
      display: widget.title,
      message: widget.message,
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
    );
  }
}
