import 'package:stelaris/api/model/item_model.dart';
import 'package:stelaris/api/util/minecraft/enchantment.dart';
import 'package:stelaris/feature/item/item_group.dart';

const List<Enchantment> values = Enchantment.values;

mixin EnchantmentReducer {

  final List<Enchantment> toolEnchantments = [
    Enchantment.efficiency,
    Enchantment.fortune,
    Enchantment.luckOfTheSea,
    Enchantment.lure,
    Enchantment.silkTouch,
    Enchantment.mending,
    Enchantment.unbreaking,
    Enchantment.vanishCourse
  ];

  final List<Enchantment> meeleEnchantments = [
    Enchantment.baneOfArthropods,
    Enchantment.efficiency,
    Enchantment.fireAspect,
    Enchantment.looting,
    Enchantment.impaling,
    Enchantment.knockback,
    Enchantment.sharpness,
    Enchantment.smite,
    Enchantment.sweeping,
    Enchantment.mending,
    Enchantment.unbreaking,
    Enchantment.vanishCourse
  ];

  final List<Enchantment> rangedEnchantments = [
    Enchantment.channeling,
    Enchantment.flame,
    Enchantment.impaling,
    Enchantment.infinity,
    Enchantment.loyalty,
    Enchantment.riptide,
    Enchantment.multishot,
    Enchantment.piercing,
    Enchantment.power,
    Enchantment.punch,
    Enchantment.quickCharge,
    Enchantment.mending,
    Enchantment.unbreaking,
    Enchantment.vanishCourse
  ];

  final List<Enchantment> armorEnchantments = [
    Enchantment.aquaAffinity,
    Enchantment.blastProtection,
    Enchantment.bindingCurse,
    Enchantment.depthStrider,
    Enchantment.featherFalling,
    Enchantment.fireProtection,
    Enchantment.frostWalker,
    Enchantment.projectTileProtection,
    Enchantment.protection,
    Enchantment.respiration,
    Enchantment.soulSpeed,
    Enchantment.thorns,
    Enchantment.mending,
    Enchantment.unbreaking,
    Enchantment.vanishCourse
  ];

  final List<Enchantment> miscEnchantments = List.from(values);

  List<Enchantment> _getTools(ItemModel itemModel) {
    if (itemModel.enchantments == null && itemModel.group == ItemGroup.tools) {
      return toolEnchantments;
    }

    final newList = List.of(toolEnchantments, growable: true);

    for (var value in toolEnchantments) {
      if (itemModel.enchantments!.containsKey(value.minecraftValue)) {
        newList.remove(value);
      }
    }

    return newList;
  }

  List<Enchantment> _getMeele(ItemModel itemModel) {
    if (itemModel.enchantments == null && itemModel.group == ItemGroup.meeleWeapon) {
      return meeleEnchantments;
    }

    final newList = List.of(meeleEnchantments, growable: true);

    for (var value in meeleEnchantments) {
      if (itemModel.enchantments!.containsKey(value.minecraftValue)) {
        newList.remove(value);
      }
    }

    return newList;
  }

  List<Enchantment> _getRanged(ItemModel itemModel) {
    if (itemModel.enchantments == null && itemModel.group == ItemGroup.rangedWeapon) {
      return rangedEnchantments;
    }

    final newList = List.of(rangedEnchantments, growable: true);

    for (var value in rangedEnchantments) {
      if (itemModel.enchantments!.containsKey(value.minecraftValue)) {
        newList.remove(value);
      }
    }

    return newList;
  }

  List<Enchantment> _getMisc(ItemModel itemModel) {
    if (itemModel.enchantments == null && itemModel.group == ItemGroup.misc) {
      return miscEnchantments;
    }

    final newList = List.of(miscEnchantments, growable: true);

    for (var value in miscEnchantments) {
      if (itemModel.enchantments!.containsKey(value.minecraftValue)) {
        newList.remove(value);
      }
    }

    return newList;
  }

  List<Enchantment> _getArmor(ItemModel itemModel) {
    if (itemModel.enchantments == null && itemModel.group == ItemGroup.armor) {
      return miscEnchantments;
    }

    final newList = List.of(armorEnchantments, growable: true);

    for (var value in armorEnchantments) {
      if (itemModel.enchantments!.containsKey(value.minecraftValue)) {
        newList.remove(value);
      }
    }

    return newList;
  }

  List<Enchantment> getEnchantments(ItemModel model) {
    if (identical(model.group, ItemGroup.armor)) {
      return _getArmor(model);
    }

    if (identical(model.group, ItemGroup.tools)) {
      return _getTools(model);
    }

    if (identical(model.group, ItemGroup.meeleWeapon)) {
      return _getMeele(model);
    }

    if (identical(model.group, ItemGroup.rangedWeapon)) {
      return _getRanged(model);
    }

    return _getMisc(model);
  }

  List<Enchantment> _getEnchantments(ItemGroup group) {
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
    final group = ItemGroup.values.firstWhere((element) => identical(model.group, element));

    switch(group) {
      case ItemGroup.misc:
        return model.enchantments!.length <= miscEnchantments.length;
      case ItemGroup.meeleWeapon:
        return model.enchantments!.length <= meeleEnchantments.length;
      case ItemGroup.rangedWeapon:
        return model.enchantments!.length <= rangedEnchantments.length;
      case ItemGroup.tools:
        return model.enchantments!.length <= toolEnchantments.length;
      case ItemGroup.armor:
        return model.enchantments!.length <= armorEnchantments.length;
    }
  }

  List<String> _getAsString(List<Enchantment> items) {
    final List<String> values = [];

    for (var value in items) {
      values.add(value.minecraftValue);
    }

    return values;
  }

  Enchantment? getByGroup(ItemModel model, String enchantment) {
    final groupEnchantments = _getEnchantments(ItemGroup.values.firstWhere((element) => identical(element, model.group)));

    for (var value in groupEnchantments) {
      if (value.minecraftValue == enchantment) {
        return value;
      }
    }
    return null;
  }
  
  List<String> getRemoveItems(ItemModel itemModel, ItemGroup newGroup) {
    if (itemModel.enchantments == null || itemModel.enchantments!.isEmpty) {
      return List.empty();
    }
    final List<String> removeList = List.empty(growable: true);
    
    final groupEnchantments = _getAsString(_getEnchantments(newGroup));

    for (var value in itemModel.enchantments!.keys) {
      if (!groupEnchantments.contains(value)) {
        removeList.add(value);
      }
    }

    return removeList;
  }
}
