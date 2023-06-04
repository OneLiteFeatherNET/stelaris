import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/api/util/minecraft/enchantment.dart';
import 'package:stelaris_ui/feature/item/enchantment_reducer.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class ItemEnchantmentAddDialog extends StatelessWidget with EnchantmentReducer {
  final AddEnchantmentCallback addEnchantmentCallback;
  final TextEditingController levelController = TextEditingController();
  final ItemModel model;
  final FormFieldValidator formFieldValidator;
  final ValueNotifier<Enchantment?> _selected = ValueNotifier(null);

  final _key = GlobalKey<FormState>();

  ItemEnchantmentAddDialog(
      {Key? key,
      required this.addEnchantmentCallback,
      required this.model,
      required this.formFieldValidator})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<Enchantment>> enchantments = getEnchantments(model);
    _selected.value = enchantments[0].value;
    return SimpleDialog(
      title: Text(
        context.l10n.dialog_enchantment_title,
        textAlign: TextAlign.center,
      ),
      contentPadding: dialogPadding,
      children: [
        Text(context.l10n.dialog_enchantment_enchantment),
        spaceTenBox,
        DropdownButtonFormField<Enchantment?>(
          value: _selected.value,
          items: enchantments,
          onChanged: (value) {
            _selected.value = value;
          },
        ),
        spaceTwentyFiveHeightBox,
        Text(context.l10n.label_level),
        Form(
          key: _key,
          autovalidateMode: AutovalidateMode.always,
          child: TextFormField(
            controller: levelController,
            autocorrect: false,
            keyboardType: numberInput,
            inputFormatters: [FilteringTextInputFormatter.allow(numberPattern)],
            validator: formFieldValidator,
          ),
        ),
        spaceTwentyFiveHeightBox,
        TextButton(
            onPressed: () {
              if (!_key.currentState!.validate()) return;
              if (_selected.value == null) return;
              addEnchantmentCallback(_selected.value!, int.parse(levelController.value.text));
            },
            child: Text(context.l10n.button_add))
      ],
    );
  }
}
