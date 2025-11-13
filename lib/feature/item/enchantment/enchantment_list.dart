import 'package:flutter/material.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/feature/item/enchantment/enchantment_item.dart';
import 'package:vulpes_data/api/enchantment.dart';

class EnchantmentList extends StatelessWidget {
  const EnchantmentList({
    required this.enchantments,
    required this.selectedEnchantments,
    required this.isDeleteMode,
    required this.onLevelChanged,
    required this.onEnchantmentDeleted,
    super.key,
  });

  final List<Enchantment> enchantments;
  final Map<String, int> selectedEnchantments;
  final bool isDeleteMode;
  final Function(Enchantment, int) onLevelChanged;
  final Function(Enchantment) onEnchantmentDeleted;

  @override
  Widget build(BuildContext context) {
    // Extract enchantments that are in the item
    final activeEnchantments = [];
    for (var ench in enchantments) {
      if (selectedEnchantments.containsKey(ench.minecraftValue)) {
        activeEnchantments.add(ench);
      }
    }

    if (activeEnchantments.isEmpty) {
      return const EmptyDataWidget(header: 'No enchantments added yet');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: activeEnchantments.length,
      itemBuilder: (context, index) {
        final enchantment = activeEnchantments[index];
        final level = selectedEnchantments[enchantment.minecraftValue] ?? 1;

        return EnchantmentItem(
          enchantment: enchantment,
          level: level,
          isDeleteMode: isDeleteMode,
          onLevelChanged: (newLevel) => onLevelChanged(enchantment, newLevel),
          onDelete: () => onEnchantmentDeleted(enchantment),
        );
      },
    );
  }
}
