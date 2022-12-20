import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/data_model.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';

typedef ValueUpdate<E> = void Function(E? value);
typedef DefaultValue<E,T> = E Function(T value);

class DropDownCard<E, T> extends StatefulWidget {

  final Text title;
  final List<DropdownMenuItem<E>>? items;
  final ValueUpdate<E> valueUpdate;
  final DefaultValue<E,T> defaultValue;
  final T currentValue;

  const DropDownCard({Key? key, required this.title, required this.items, required this.valueUpdate, required this.defaultValue, required this.currentValue}) : super(key: key);

  @override
  State<DropDownCard<E, T>> createState() => _DropDownCardState<E,T>();
}

class _DropDownCardState<E, T> extends State<DropDownCard<E,T>> with BaseLayout {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: constructContainer(
          [
            widget.title,
            spaceBox,
            SizedBox(
              width: 300,
              child: DropdownButtonFormField<E>(
                items: widget.items,
                value: widget.defaultValue(widget.currentValue),
                onChanged: (E? value) {
                  if (value == null) return;
                  setState(() {
                    widget.valueUpdate(value);
                  });
                },
              )
            )
          ]
      ),
    );
  }
}
