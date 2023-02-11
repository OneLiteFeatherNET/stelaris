import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/api/util/minecraft/enchantment.dart';
import 'package:stelaris_ui/feature/item/item_group.dart';

const List<Enchantment> values = Enchantment.values;

final Map<Enchantment, DropdownMenuItem<Enchantment>> enchantments = { for (var e in values) e : DropdownMenuItem(
    value: e,
    child: Text(e.display)) };

mixin EnchantmentReducer {

  final List<DropdownMenuItem<Enchantment>> toolEnchantments = [
    enchantments[Enchantment.efficiency]!,
    enchantments[Enchantment.fortune]!,
    enchantments[Enchantment.luckOfTheSea]!,
    enchantments[Enchantment.lure]!,
    enchantments[Enchantment.silkTouch]!,
    enchantments[Enchantment.mending]!,
    enchantments[Enchantment.unbreaking]!,
    enchantments[Enchantment.vanishCourse]!
  ];

  final List<DropdownMenuItem<Enchantment>> meeleEnchantments = [
    enchantments[Enchantment.baneOfArthropods]!,
    enchantments[Enchantment.efficiency]!,
    enchantments[Enchantment.fireAspect]!,
    enchantments[Enchantment.looting]!,
    enchantments[Enchantment.impaling]!,
    enchantments[Enchantment.knockback]!,
    enchantments[Enchantment.sharpness]!,
    enchantments[Enchantment.smite]!,
    enchantments[Enchantment.sweeping]!,
    enchantments[Enchantment.mending]!,
    enchantments[Enchantment.unbreaking]!,
    enchantments[Enchantment.vanishCourse]!
  ];

  final List<DropdownMenuItem<Enchantment>> rangedEnchantments = [
    enchantments[Enchantment.channeling]!,
    enchantments[Enchantment.flame]!,
    enchantments[Enchantment.impaling]!,
    enchantments[Enchantment.infinity]!,
    enchantments[Enchantment.loyalty]!,
    enchantments[Enchantment.riptide]!,
    enchantments[Enchantment.multishot]!,
    enchantments[Enchantment.piercing]!,
    enchantments[Enchantment.power]!,
    enchantments[Enchantment.punch]!,
    enchantments[Enchantment.quickCharge]!,
    enchantments[Enchantment.mending]!,
    enchantments[Enchantment.unbreaking]!,
    enchantments[Enchantment.vanishCourse]!
  ];

  final List<DropdownMenuItem<Enchantment>> armorEnchantments = [
    enchantments[Enchantment.aquaAffinity]!,
    enchantments[Enchantment.blastProtection]!,
    enchantments[Enchantment.bindingCurse]!,
    enchantments[Enchantment.depthStrider]!,
    enchantments[Enchantment.featherFalling]!,
    enchantments[Enchantment.fireProtection]!,
    enchantments[Enchantment.frostWalker]!,
    enchantments[Enchantment.projectTileProtection]!,
    enchantments[Enchantment.protection]!,
    enchantments[Enchantment.respiration]!,
    enchantments[Enchantment.soulSpeed]!,
    enchantments[Enchantment.thorns]!,
    enchantments[Enchantment.mending]!,
    enchantments[Enchantment.unbreaking]!,
    enchantments[Enchantment.vanishCourse]!
  ];

  final List<DropdownMenuItem<Enchantment>> miscEnchantments = List.from(enchantments.values);

  List<DropdownMenuItem<Enchantment>> _getTools(ItemModel itemModel) {
    if (itemModel.enchantments == null && itemModel.group == ItemGroup.tools.display) {
      return toolEnchantments;
    }

    var newList = List.of(toolEnchantments, growable: true);

    for (var value in toolEnchantments) {
      if (itemModel.enchantments!.containsKey(value.value!.minecraftValue)) {
        newList.remove(value);
      }
    }

    return newList;
  }

  List<DropdownMenuItem<Enchantment>> _getMeele(ItemModel itemModel) {
    if (itemModel.enchantments == null && itemModel.group == ItemGroup.meeleWeapon.display) {
      return meeleEnchantments;
    }

    var newList = List.of(meeleEnchantments, growable: true);

    for (var value in meeleEnchantments) {
      if (itemModel.enchantments!.containsKey(value.value!.minecraftValue)) {
        newList.remove(value);
      }
    }

    return newList;
  }

  List<DropdownMenuItem<Enchantment>> _getRanged(ItemModel itemModel) {
    if (itemModel.enchantments == null && itemModel.group == ItemGroup.rangedWeapon.display) {
      return rangedEnchantments;
    }

    var newList = List.of(rangedEnchantments, growable: true);

    for (var value in rangedEnchantments) {
      if (itemModel.enchantments!.containsKey(value.value!.minecraftValue)) {
        newList.remove(value);
      }
    }

    return newList;
  }

  List<DropdownMenuItem<Enchantment>> _getMisc(ItemModel itemModel) {
    if (itemModel.enchantments == null && itemModel.group == ItemGroup.misc.display) {
      return miscEnchantments;
    }

    var newList = List.of(miscEnchantments, growable: true);

    for (var value in miscEnchantments) {
      if (itemModel.enchantments!.containsKey(value.value!.minecraftValue)) {
        newList.remove(value);
      }
    }

    return newList;
  }

  List<DropdownMenuItem<Enchantment>> getEnchantments(ItemModel model) {
    if (model.group == null || model.group!.trim().isEmpty) {
      return _getMisc(model);
    }

    if (identical(model.group, ItemGroup.tools.display)) {
      return _getTools(model);
    }

    if (identical(model.group, ItemGroup.meeleWeapon.display)) {
      return _getMeele(model);
    }

    if (identical(model.group, ItemGroup.rangedWeapon.display)) {
      return _getRanged(model);
    }

    return _getMisc(model);
  }

  List<DropdownMenuItem<Enchantment>> _getEnchantments(ItemGroup group) {
    switch (group) {
      case ItemGroup.misc:
        return miscEnchantments;
      case ItemGroup.meeleWeapon:
        return meeleEnchantments;
      case ItemGroup.rangedWeapon:
        return rangedEnchantments;
      case ItemGroup.tools:
        return armorEnchantments;
      case ItemGroup.armor:
        return armorEnchantments;
    }
  }

  bool canAdd(ItemModel model) {
    if (model.enchantments == null) return true;

    var group = ItemGroup.values.firstWhere((element) => identical(model.group, element.display));

    switch(group) {
      case ItemGroup.misc:
        return miscEnchantments.length != model.enchantments!.length;
      case ItemGroup.meeleWeapon:
        return meeleEnchantments.length != model.enchantments!.length;
      case ItemGroup.rangedWeapon:
        return rangedEnchantments.length != model.enchantments!.length;
      case ItemGroup.tools:
        return toolEnchantments.length != model.enchantments!.length;
      case ItemGroup.armor:
        return armorEnchantments.length != model.enchantments!.length;
    }

  }

  Enchantment? getByGroup(ItemModel model, String enchantment) {
    var groupEnchantments = _getEnchantments(ItemGroup.values.firstWhere((element) => identical(element.display, model.group)));

    for (var value in groupEnchantments) {
      if (value.value!.minecraftValue == enchantment) {
        return value.value!;
      }
    }
    return null;
  }
  
  List<Enchantment> getRemoveItems(ItemModel itemModel, ItemGroup newGroup) {
    if (itemModel.enchantments == null || itemModel.enchantments!.isEmpty) {
      return List.empty();
    }
    List<Enchantment> removeList = List.empty(growable: true);
    
    var groupEnchantments = _getEnchantments(newGroup);
    
    for (var value in groupEnchantments) {
      if (itemModel.enchantments!.containsKey(value.value!.minecraftValue)) {
        removeList.add(value.value!);
      }
    }

    return removeList;
  }
}
