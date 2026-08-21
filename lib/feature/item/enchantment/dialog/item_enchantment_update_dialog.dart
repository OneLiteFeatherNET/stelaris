import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/item/item_enchantment_actions.dart';
import 'package:stelaris/feature/base/button/cancel_button.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:vulpes_data/api/enchantment.dart';

class ItemEnchantmentUpdateDialog extends StatefulWidget {
  const ItemEnchantmentUpdateDialog({
    required this.enchantment,
    required this.dto,
    super.key,
  });

  final Enchantment enchantment;
  final ItemEnchantmentDto dto;

  @override
  State<ItemEnchantmentUpdateDialog> createState() =>
      _ItemEnchantmentUpdateDialogState();
}

class _ItemEnchantmentUpdateDialogState
    extends State<ItemEnchantmentUpdateDialog> {
  final TextEditingController _controller = TextEditingController();
  final _key = GlobalKey<FormState>();

  @override
  void initState() {
    _controller.text = widget.dto.level.toString();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(
        context.l10n.dialog_item_enchantment_level_edit,
        textAlign: TextAlign.center,
      ),
      contentPadding: dialogPadding,
      children: [
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
            validator: (value) => _validateInput(
              value: value!,
              maxLevel: widget.enchantment.maxLevel,
            ),
          ),
        ),
        verticalSpacing25,
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CancelButton(callback: () => context.pop(false)),
            TextButton(
              onPressed: () {
                final String content = _controller.text;
                if (content.trim().isEmpty) {
                  return;
                }

                if (content == widget.dto.level.toString()) {
                  context.pop(false);
                  return;
                }

                final ItemEnchantmentDto updatedDto = widget.dto.copyWith(
                  level: int.parse(content),
                );
                context.dispatch(ItemEnchantmentUpdateAction(updatedDto));
                context.pop(true);
              },
              child: Text(context.l10n.button_save),
            ),
          ],
        ),
      ],
    );
  }

  String? _validateInput({required String value, required int maxLevel}) {
    if (value.trim().isEmpty) {
      return 'Please enter a level';
    }
    final level = int.tryParse(value);
    if (level == null) {
      return 'Please enter a valid number';
    }

    if (level > maxLevel) {
      return 'The maximum is $maxLevel';
    }

    return null;
  }
}
