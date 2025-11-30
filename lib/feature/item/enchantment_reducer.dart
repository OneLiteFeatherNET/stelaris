import 'package:stelaris/api/model/item_model.dart';
import 'package:stelaris/feature/item/item_group.dart';
import 'package:vulpes_data/api/enchantment.dart';
import 'package:vulpes_data/enchantment/armor_enchantment.dart';
import 'package:vulpes_data/enchantment/meta_enchantment.dart';
import 'package:vulpes_data/enchantment/tool_enchantment.dart';
import 'package:vulpes_data/enchantment/weapon_enchantment.dart';

mixin EnchantmentReducer {
  static const Set<ToolEnchantment> toolEnchantments = {
    ToolEnchantment.efficiency,
    ToolEnchantment.fortune,
    ToolEnchantment.luckOfTheSea,
    ToolEnchantment.lure,
    ToolEnchantment.silkTouch,
  };

  static const Set<MetaEnchantment> metaEnchantments = {
    MetaEnchantment.mending,
    MetaEnchantment.unbreaking,
    MetaEnchantment.vanishingCurse,
  };

  static const Set<WeaponEnchantment> weaponEnchantments = {
    WeaponEnchantment.channeling,
    WeaponEnchantment.flame,
    WeaponEnchantment.impaling,
    WeaponEnchantment.infinity,
    WeaponEnchantment.loyalty,
    WeaponEnchantment.riptide,
    WeaponEnchantment.multishot,
    WeaponEnchantment.piercing,
    WeaponEnchantment.power,
    WeaponEnchantment.punch,
    WeaponEnchantment.quickCharge,
  };

  static const Set<ArmorEnchantment> armorEnchantments = {
    ArmorEnchantment.aquaAffinity,
    ArmorEnchantment.blastProtection,
    ArmorEnchantment.bindingCurse,
    ArmorEnchantment.depthStrider,
    ArmorEnchantment.featherFalling,
    ArmorEnchantment.fireProtection,
    ArmorEnchantment.frostWalker,
    ArmorEnchantment.projectileProtection,
    ArmorEnchantment.protection,
    ArmorEnchantment.respiration,
    ArmorEnchantment.soulSpeed,
    ArmorEnchantment.thorns,
  };

  /// Returns the appropriate set of enchantments for a given [EnchantmentGroup].
  Set<Enchantment> _getEnchantments(EnchantmentGroup group) {
    return switch (group) {
      EnchantmentGroup.meta => metaEnchantments,
      EnchantmentGroup.tools => toolEnchantments,
      EnchantmentGroup.armor => armorEnchantments,
      EnchantmentGroup.weapon => weaponEnchantments,
    };
  }

  /// Gets the list of available enchantments for an item, excluding those it already has.
  List<Enchantment> getEnchantments(ItemModel model, [bool exclude = false]) {
    final groupEnchantments = _getEnchantments(model.groupName);

    if (!model.enchantments.hasItems) {
      return groupEnchantments.toList();
    }

    final existingEnchantmentKeys = model.enchantments.items.map(
      (element) => element.name,
    );

    // Efficiently filter the set and return a list.
    return exclude
        ? groupEnchantments
              .where((e) => !existingEnchantmentKeys.contains(e.minecraftValue))
              .toList()
        : groupEnchantments.toList();
  }

  /// Checks if an item can have more enchantments added based on its group.
  bool canAdd(ItemModel model) {
    final groupEnchantments = _getEnchantments(model.groupName);
    return model.enchantments.totalItems < groupEnchantments.length;
  }

  /// Finds an [Enchantment] enum by its string value within the context of an item's group.
  Enchantment? getByGroup(ItemModel model, String enchantmentValue) {
    final groupEnchantments = _getEnchantments(model.groupName);
    // Explicitly specify the type parameter for firstWhere as Enchantment?
    // This tells Dart that the method can return a nullable Enchantment.
    for (var ench in groupEnchantments) {
      if (ench.minecraftValue == enchantmentValue) return ench;
    }
    return null;
  }

  /// Calculates which enchantments to remove if an item's group is changed to [newGroup].
  List<String> getRemoveItems(ItemModel itemModel, EnchantmentGroup newGroup) {
    if (!itemModel.enchantments.hasItems) {
      return [];
    }

    final newGroupEnchantments = _getEnchantments(newGroup);
    // Create a set of the string values for fast lookups.
    final allowedMinecraftValues = newGroupEnchantments
        .map((e) => e.minecraftValue)
        .toSet();

    // Filter the existing keys based on whether they are in the new allowed set.
    return itemModel.enchantments.items
        .where((key) => !allowedMinecraftValues.contains(key.name))
        .map((element) => element.name)
        .toList();
  }
}
