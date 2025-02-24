import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris/api/model/item_model.dart';
import 'package:stelaris/api/util/minecraft/enchantment.dart';
import 'package:stelaris/feature/item/enchantment_reducer.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/typedefs.dart';

class ItemEnchantmentAddDialog extends StatefulWidget {

  const ItemEnchantmentAddDialog({
    required this.addEnchantmentCallback,
    required this.model,
    required this.formFieldValidator,
    super.key,
  });

  final AddEnchantmentCallback addEnchantmentCallback;
  final ItemModel model;
  final FormFieldValidator formFieldValidator;

  @override
  State<ItemEnchantmentAddDialog> createState() =>
      _ItemEnchantmentAddDialogState();
}

class _ItemEnchantmentAddDialogState extends State<ItemEnchantmentAddDialog>
    with EnchantmentReducer {
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<Enchantment?> _selected = ValueNotifier(null);
  final _key = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    _selected.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<Enchantment>> enchantments =
        getEnchantments(widget.model)
            .map(
              (e) => DropdownMenuItem<Enchantment>(
                value: e,
                child: Text(e.name),
              ),
            )
            .toList();
    _selected.value = enchantments[0].value;
    return SimpleDialog(
      title: Text(
        context.l10n.dialog_enchantment_title,
        textAlign: TextAlign.center,
      ),
      contentPadding: dialogPadding,
      children: [
        Text(context.l10n.dialog_enchantment_enchantment),
        horizontalSpacing10,
        DropdownButtonFormField<Enchantment?>(
          autofocus: true,
          value: _selected.value,
          items: enchantments,
          onChanged: (value) {
            _selected.value = value;
          },
        ),
        verticalSpacing25,
        Text(context.l10n.label_level),
        Form(
          key: _key,
          autovalidateMode: AutovalidateMode.always,
          child: TextFormField(
            controller: _controller,
            autocorrect: false,
            keyboardType: numberInput,
            inputFormatters: [FilteringTextInputFormatter.allow(numberPattern)],
            validator: widget.formFieldValidator,
          ),
        ),
        verticalSpacing25,
        TextButton(
          onPressed: () {
            if (!_key.currentState!.validate()) return;
            if (_selected.value == null) return;
            widget.addEnchantmentCallback(
              _selected.value!,
              int.parse(
                _controller.value.text,
              ),
            );
            _selected.value = null;
          },
          child: Text(context.l10n.button_add),
        )
      ],
    );
  }
}
