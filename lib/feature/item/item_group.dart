import 'package:flutter/material.dart';

enum ItemGroup {
  misc('Misc'),
  armor('Armor'),
  meeleWeapon('Melee Weapon'),
  rangedWeapon('Range Weapon'),
  tools('Tools');

  final String display;

  const ItemGroup(this.display);

  bool hasSameGroup(ItemGroup current) =>
      index == current.index;
}

List<DropdownMenuItem<ItemGroup>> getGroupItems() {
  return ItemGroup.values
      .map((e) => DropdownMenuItem(
            value: e,
            child: Text(e.display),
          ))
      .toList();
}
