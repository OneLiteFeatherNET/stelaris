import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/api/util/minecraft/enchantment.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/typedefs.dart';

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
      title: Text(context.l10n.dialog_enchantment_title, textAlign: TextAlign.center,),
      contentPadding: const EdgeInsets.all(20.0),
      children: [
        Text(context.l10n.dialog_enchantment_enchantment),
        spaceTenBox,
        DropdownButtonFormField(
          value: items[0].value,
          items: items,
          onChanged: (Enchantment? value) {
            _selected = value;
        },
        ),
        spaceTwentyFiveHeightBox,
        const Text("Level"),
        TextFormField(
          controller: levelController,
          autocorrect: false,
          keyboardType: numberInput,
          inputFormatters: [FilteringTextInputFormatter.allow(numberPattern)],
        ),
        spaceTwentyFiveHeightBox,
        TextButton(onPressed: () {
          if (_selected != null) {
            addEnchantmentCallback(_selected!, int.parse(levelController.value.text));
          }
        }, child: Text(context.l10n.button_add))
      ],
    );
  }
}
