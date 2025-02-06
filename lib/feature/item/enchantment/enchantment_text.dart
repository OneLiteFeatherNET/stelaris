import 'package:flutter/cupertino.dart';
import 'package:stelaris/util/constants.dart';

class EnchantmentText extends StatelessWidget {
  const EnchantmentText({required this.enchantment, super.key});

  final String enchantment;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Enchantment: ',
          style: TextStyle(fontSize: 16),
        ),
        heightTen,
        Text(
          'minecraft:$enchantment',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
