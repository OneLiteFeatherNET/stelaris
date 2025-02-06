import 'package:flutter/material.dart';
import 'package:stelaris/feature/item/enchantment/enchantment_box.dart';
import 'package:stelaris/feature/item/enchantment/enchantment_text.dart';

class EnchantmentCard extends StatefulWidget {
  const EnchantmentCard({
    required this.enchantment,
    required this.isEnchanted,
    super.key,
  });

  final String enchantment;
  final bool isEnchanted;

  @override
  State<EnchantmentCard> createState() => _EnchantmentCardState();
}

class _EnchantmentCardState extends State<EnchantmentCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 10),
              child: EnchantmentText(enchantment: widget.enchantment),
            ),
            SizedBox(
              width: 200,
              child: TextField(
                decoration: const InputDecoration(
                  label: Text('Level'),
                  hintText: '1',
                ),
                controller: _controller,
                showCursor: true,
                enabled: widget.isEnchanted,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child:
                  EnchantmentBox(isEnchanted: widget.isEnchanted, key: UniqueKey()),
            ),
          ],
        ),
      ),
    );
  }
}
