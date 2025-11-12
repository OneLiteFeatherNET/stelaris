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
    ToolEnchantment.luck_of_the_sea,
    ToolEnchantment.lure,
    ToolEnchantment.silk_touch,
  };

  static const Set<MetaEnchantment> meeleEnchantments = {
    MetaEnchantment.mending,
    MetaEnchantment.unbreaking,
    MetaEnchantment.vanishing_curse
  };

  static const Set<WeaponEnchantment> rangedEnchantments = {
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
    WeaponEnchantment.quick_charge,
  };

  static const Set<ArmorEnchantment> armorEnchantments = {
    ArmorEnchantment.aqua_affinity,
    ArmorEnchantment.blast_protection,
    ArmorEnchantment.binding_curse,
    ArmorEnchantment.depth_strider,
    ArmorEnchantment.feather_falling,
    ArmorEnchantment.fire_protection,
    ArmorEnchantment.frost_walker,
    ArmorEnchantment.projectile_protection,
    ArmorEnchantment.protection,
    ArmorEnchantment.respiration,
    ArmorEnchantment.soul_speed,
    ArmorEnchantment.thorns,
  };

  static final Set<Enchantment> miscEnchantments = Enchantment.values.toSet();

  /// Returns the appropriate set of enchantments for a given [ItemGroup].
  Set<Enchantment> _getEnchantments(ItemGroup group) {
    switch (group) {
      case ItemGroup.misc:
        return meeleEnchantments;
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
