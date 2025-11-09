import 'package:stelaris/api/model/item_model.dart';
import 'package:stelaris/api/util/minecraft/enchantment.dart';
import 'package:stelaris/feature/item/item_group.dart';

mixin EnchantmentReducer {
  static const Set<Enchantment> toolEnchantments = {
    Enchantment.efficiency,
    Enchantment.fortune,
    Enchantment.luckOfTheSea,
    Enchantment.lure,
    Enchantment.silkTouch,
    Enchantment.mending,
    Enchantment.unbreaking,
    Enchantment.vanishCourse,
  };

  static const Set<Enchantment> meeleEnchantments = {
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
    Enchantment.vanishCourse,
  };

  static const Set<Enchantment> rangedEnchantments = {
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
    Enchantment.vanishCourse,
  };

  static const Set<Enchantment> armorEnchantments = {
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
    Enchantment.vanishCourse,
  };

  static final Set<Enchantment> miscEnchantments = Enchantment.values.toSet();

  /// Returns the appropriate set of enchantments for a given [ItemGroup].
  Set<Enchantment> _getEnchantments(ItemGroup group) {
    switch (group) {
      case ItemGroup.misc:
        return miscEnchantments;
      case ItemGroup.meeleWeapon:
        return meeleEnchantments;
      case ItemGroup.rangedWeapon:
        return rangedEnchantments;
      case ItemGroup.tools:
        return toolEnchantments; // Fixed bug: was armorEnchantments
      case ItemGroup.armor:
        return armorEnchantments;
    }
  }

  /// Gets the list of available enchantments for an item, excluding those it already has.
  List<Enchantment> getEnchantments(ItemModel model) {
    final groupEnchantments = _getEnchantments(model.group);

    if (model.enchantments == null || model.enchantments!.isEmpty) {
      return groupEnchantments.toList();
    }

    final existingEnchantmentKeys = model.enchantments!.keys.toSet();

    // Efficiently filter the set and return a list.
    return groupEnchantments
        .where((e) => !existingEnchantmentKeys.contains(e.minecraftValue))
        .toList();
  }

  /// Checks if an item can have more enchantments added based on its group.
  bool canAdd(ItemModel model) {
    if (model.enchantments == null) return true;
    final groupEnchantments = _getEnchantments(model.group);
    return model.enchantments!.length < groupEnchantments.length;
  }

  /// Finds an [Enchantment] enum by its string value within the context of an item's group.
  Enchantment? getByGroup(ItemModel model, String enchantmentValue) {
    final groupEnchantments = _getEnchantments(model.group);
    // Explicitly specify the type parameter for firstWhere as Enchantment?
    // This tells Dart that the method can return a nullable Enchantment.
    for (var ench in groupEnchantments) {
      if (ench.minecraftValue == enchantmentValue) return ench;
    }
    return null;
  }

  /// Calculates which enchantments to remove if an item's group is changed to [newGroup].
  List<String> getRemoveItems(ItemModel itemModel, ItemGroup newGroup) {
    if (itemModel.enchantments == null || itemModel.enchantments!.isEmpty) {
      return [];
    }

    final newGroupEnchantments = _getEnchantments(newGroup);
    // Create a set of the string values for fast lookups.
    final allowedMinecraftValues = newGroupEnchantments
        .map((e) => e.minecraftValue)
        .toSet();

    // Filter the existing keys based on whether they are in the new allowed set.
    return itemModel.enchantments!.keys
        .where((key) => !allowedMinecraftValues.contains(key))
        .toList();
  }
}
