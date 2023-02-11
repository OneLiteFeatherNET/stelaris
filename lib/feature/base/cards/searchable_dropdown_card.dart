import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class SearchableDropDownCard<E, T>extends StatefulWidget {

  final Text title;
  final List<E>? items;
  final ValueUpdate<E> valueUpdate;
  final DefaultValue<E,T> defaultValue;
  final T currentValue;

  const SearchableDropDownCard({Key? key, required this.title, this.items, required this.valueUpdate, required this.defaultValue, required this.currentValue}) : super(key: key);

  @override
  State<SearchableDropDownCard<E, T>> createState() => _SearchableDropDownCardState<E, T>();
}

class _SearchableDropDownCardState<E,T> extends State<SearchableDropDownCard<E, T>> with BaseLayout {
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
            child: DropdownSearch<E>(
              items: widget.items!,
              selectedItem: widget.defaultValue(widget.currentValue),
              onChanged: (E? value) {
                if (value == null) return;
                setState(() {
                  widget.valueUpdate(value);
                });
              },
            ),
          )
        ]

      ),
    );
  }
}
