import 'package:stelaris_models/stelaris_models.dart';
import 'package:vulpes_data/enchantment.dart' hide EnchantmentGroup;

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
              .where((e) => !existingEnchantmentKeys.contains(e.key))
              .toList()
        : groupEnchantments.toList();
  }
}
