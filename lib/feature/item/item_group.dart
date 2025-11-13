import 'package:flutter/material.dart';

enum EnchantmentGroup {
  armor('Armor'),
  weapon('Weapon'),
  meta('Meta'),
  tools('Tools');

  final String display;

  const EnchantmentGroup(this.display);

  bool hasSameGroup(EnchantmentGroup current) =>
      index == current.index;
}

List<DropdownMenuItem<EnchantmentGroup>> getGroupItems() {
  return EnchantmentGroup.values
      .map((e) => DropdownMenuItem(
            value: e,
            child: Text(e.display),
          ))
      .toList();
}
