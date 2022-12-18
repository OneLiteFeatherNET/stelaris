import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/util/minecraft/enchantment.dart';

import '../../util/constants.dart';

const List<Enchantment> enchantments = Enchantment.values;
List<DropdownMenuItem<String>> items =
List.generate(enchantments.length, (index) =>
    DropdownMenuItem(value: enchantments[index].display,child: Text(enchantments[index].display),)
);

class ItemEnchantmentAddDialog extends StatelessWidget {

  final TextEditingController levelController = TextEditingController();

  ItemEnchantmentAddDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Add a enchantment", textAlign: TextAlign.center,),
      contentPadding: const EdgeInsets.all(20.0),
      children: [
        const Text("Enchantment"),
        const SizedBox(height: 5,),
        DropdownButtonFormField(
          value: items[0].value,
          items: items,
          onChanged: (value) { },
        ),
        const SizedBox(height: 25),
        const Text("Level"),
        TextFormField(
          controller: TextEditingController(),
          autocorrect: false,
          keyboardType: numberInput,
        ),
        const SizedBox(height: 25),
        TextButton(onPressed: () {

        }, child: const Text("Add"))
      ],
    );
  }
}
