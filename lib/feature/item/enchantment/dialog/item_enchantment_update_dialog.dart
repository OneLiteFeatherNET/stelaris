import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/item/item_enchantment_actions.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/validators.dart';
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
    return FormDialog(
      title: context.l10n.dialog_item_enchantment_level_edit,
      actionIcon: Icons.save_outlined,
      actionLabel: context.l10n.button_save,
      onSubmit: _handleSave,
      content: Form(
        key: _key,
        autovalidateMode: AutovalidateMode.always,
        child: TextFormField(
          autofocus: true,
          controller: _controller,
          autocorrect: false,
          keyboardType: numberInput,
          inputFormatters: [FilteringTextInputFormatter.allow(numberPattern)],
          decoration: InputDecoration(
            labelText: context.l10n.label_level,
            border: const OutlineInputBorder(),
          ),
          validator: (value) => Validators.enchantmentLevel(
            value: value,
            maxLevel: widget.enchantment.maxLevel,
          ),
        ),
      ),
    );
  }

  void _handleSave() {
    final String content = _controller.text;
    if (content.trim().isEmpty) {
      return;
    }

    if (content == widget.dto.level.toString()) {
      Navigator.pop(context, false);
      return;
    }

    final ItemEnchantmentDto updatedDto = widget.dto.copyWith(
      level: int.parse(content),
    );
    context.dispatch(ItemEnchantmentUpdateAction(updatedDto));
    Navigator.pop(context, true);
  }
}
