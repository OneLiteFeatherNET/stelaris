import 'package:flutter/material.dart';

class EnchantmentBox extends StatefulWidget {
  const EnchantmentBox({required this.isEnchanted, super.key});

  final bool isEnchanted;

  @override
  State<EnchantmentBox> createState() => _EnchantmentBoxState();
}

class _EnchantmentBoxState extends State<EnchantmentBox> {

  late bool isEnchanted;

  @override
  void initState() {
    isEnchanted = widget.isEnchanted;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      onChanged: (value) {
        setState(() {
          isEnchanted = !isEnchanted;
        });
      },
      value: isEnchanted
    );
  }
}
