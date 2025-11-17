import 'package:flutter/material.dart';
import 'package:stelaris/api/model/item/item_enchantment_dto.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/feature/item/enchantment/enchantment_item.dart';
import 'package:vulpes_data/api/enchantment.dart';

class EnchantmentList extends StatelessWidget {
  const EnchantmentList({
    required this.activeEnchantments,
    required this.selectedEnchantmentMap,
    required this.onLevelChanged,
    required this.onEnchantmentDeleted,
    super.key,
  });

  final List<Enchantment> activeEnchantments;
  final Map<String, ItemEnchantmentDto> selectedEnchantmentMap;
  final Function(Enchantment, int) onLevelChanged;
  final Function(Enchantment) onEnchantmentDeleted;

  @override
  Widget build(BuildContext context) {
    if (activeEnchantments.isEmpty) {
      return const EmptyDataWidget(header: 'No enchantments added yet');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: activeEnchantments.length,
      itemBuilder: (context, index) {
        final enchantment = activeEnchantments[index];
        final level = selectedEnchantmentMap[enchantment.minecraftValue]?.level ?? 1;

        return EnchantmentItem(
          enchantment: enchantment,
          level: level,
          onLevelChanged: (newLevel) => onLevelChanged(enchantment, newLevel),
          onDelete: () => onEnchantmentDeleted(enchantment),
        );
      },
    );
  }
}
