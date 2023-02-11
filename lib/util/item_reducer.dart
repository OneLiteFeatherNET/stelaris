import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/api/util/minecraft/enchantment.dart';
import 'package:stelaris_ui/api/util/minecraft/item_flag.dart';

const List<ItemFlag> _flags = ItemFlag.values;
List<DropdownMenuItem<ItemFlag>> items = List.generate(
    _flags.length,
        (index) => DropdownMenuItem(
      value: _flags[index],
      child: Text(_flags[index].display),
    ));

const List<Enchantment> enchantments = Enchantment.values;
List<DropdownMenuItem<Enchantment>> enchantItems = List.generate(
    enchantments.length,
        (index) => DropdownMenuItem(
      value: enchantments[index],
      child: Text(enchantments[index].display),
    ));

mixin DropDownItemReducer {

  List<DropdownMenuItem<ItemFlag>> reduceFlags(ItemModel itemModel) {
    if (itemModel.flags == null) {
      return items;
    }
    var newList = List.of(items, growable: true);

    for (var value in items) {
      if (itemModel.flags!.contains(value.value!.minestomValue)) {
        newList.remove(value);
      }
    }

    return newList;
  }

  List<DropdownMenuItem<Enchantment>> reduceEnchantments(ItemModel itemModel) {
    if (itemModel.enchantments == null) {
      return enchantItems;
    }

    var newList = List.of(enchantItems, growable: true);

    for (var value in enchantItems) {
      if (itemModel.enchantments!.containsKey(value.value!.minecraftValue)) {
        newList.remove(value);
      }
    }

    return newList;
  }
}