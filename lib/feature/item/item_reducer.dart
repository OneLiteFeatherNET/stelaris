import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/api/util/minecraft/item_flag.dart';

const List<ItemFlag> _flags = ItemFlag.values;
List<DropdownMenuItem<ItemFlag>> items = List.generate(
    _flags.length,
        (index) => DropdownMenuItem(
      value: _flags[index],
      child: Text(_flags[index].display),
    ));

/// This class contains the ability to exclude all flags from the list which an model currently contains.
mixin DropDownItemReducer {

  List<DropdownMenuItem<ItemFlag>> reduceFlags(ItemModel itemModel) {
    if (itemModel.flags == null) {
      return items;
    }
    final newList = List.of(items, growable: true);

    for (var value in items) {
      if (itemModel.flags!.contains(value.value!.minestomValue)) {
        newList.remove(value);
      }
    }

    return newList;
  }
}