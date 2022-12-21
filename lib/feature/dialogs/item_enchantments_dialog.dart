import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/util/minecraft/enchantment.dart';
import 'package:stelaris_ui/util/typedefs.dart';

import '../../util/constants.dart';

const List<Enchantment> enchantments = Enchantment.values;
List<DropdownMenuItem<Enchantment>> items =
List.generate(enchantments.length, (index) =>
    DropdownMenuItem(value: enchantments[index],child: Text(enchantments[index].display),)
);

class ItemEnchantmentAddDialog extends StatelessWidget {

  final AddEnchantmentCallback addEnchantmentCallback;
  final TextEditingController levelController = TextEditingController();
  Enchantment? _selected;

  ItemEnchantmentAddDialog({Key? key, required this.addEnchantmentCallback}) : super(key: key);

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
          onChanged: (Enchantment? value) {
            _selected = value;
        },
        ),
        const SizedBox(height: 25),
        const Text("Level"),
        TextFormField(
          controller: levelController,
          autocorrect: false,
          keyboardType: numberInput,
        ),
        const SizedBox(height: 25),
        TextButton(onPressed: () {
          if (_selected != null) {
            addEnchantmentCallback(_selected!, int.parse(levelController.value.text));
          }
        }, child: const Text("Add"))
      ],
    );
  }
}
