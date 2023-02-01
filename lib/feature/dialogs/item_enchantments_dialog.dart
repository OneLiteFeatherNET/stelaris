import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/api/util/minecraft/enchantment.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class ItemEnchantmentAddDialog extends StatelessWidget {

  final AddEnchantmentCallback addEnchantmentCallback;
  final TextEditingController levelController = TextEditingController();
  final List<DropdownMenuItem<Enchantment>> items;
  Enchantment? _selected;

  ItemEnchantmentAddDialog(
      {Key? key, required this.addEnchantmentCallback, required this.items})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(
        context.l10n.dialog_enchantment_title,
        textAlign: TextAlign.center,
      ),
      contentPadding: dialogPadding,
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
        TextButton(
            onPressed: () {
              if (_selected != null) {
                addEnchantmentCallback(
                    _selected!, int.parse(levelController.value.text));
              }
            },
            child: Text(context.l10n.button_add))
      ],
    );
  }
}
