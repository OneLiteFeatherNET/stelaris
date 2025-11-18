import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris/api/model/item_model.dart';
import 'package:stelaris/feature/item/enchantment_reducer.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/typedefs.dart';
import 'package:vulpes_data/api/enchantment.dart';

class ItemEnchantmentAddDialog extends StatefulWidget {
  const ItemEnchantmentAddDialog({
    required this.addEnchantmentCallback,
    required this.model,
    super.key,
  });

  final AddEnchantmentCallback addEnchantmentCallback;
  final ItemModel model;

  @override
  State<ItemEnchantmentAddDialog> createState() =>
      _ItemEnchantmentAddDialogState();
}

class _ItemEnchantmentAddDialogState extends State<ItemEnchantmentAddDialog>
    with EnchantmentReducer {
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<Enchantment?> _selected = ValueNotifier(null);
  final _key = GlobalKey<FormState>();
  late List<DropdownMenuItem<Enchantment>> _enchantments;

  @override
  void initState() {
    super.initState();
    _updateEnchantments();
    _resetController();
  }

  @override
  void didUpdateWidget(ItemEnchantmentAddDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      _updateEnchantments();
    }
  }

  void _updateEnchantments() {
    _enchantments = getEnchantments(widget.model, true)
        .map(
          (e) =>
          DropdownMenuItem<Enchantment>(
            value: e,
            child: Text(e.displayName),
          ),
    )
        .toList();
    if (_enchantments.isNotEmpty) {
      _selected.value = _enchantments[0].value;
    } else {
      _selected.value = null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _selected.dispose();
    super.dispose();
  }

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
        horizontalSpacing10,
        ValueListenableBuilder<Enchantment?>(
          valueListenable: _selected,
          builder: (context, selectedEnchantment, child) {
            return DropdownButtonFormField<Enchantment?>(
              autofocus: true,
              initialValue: selectedEnchantment,
              items: _enchantments,
              onChanged: (value) {
                _selected.value = value;
                _resetController();
              },
            );
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
            validator: (value) {
              if (value == null) return null;
              return _validateInput(
                value: value,
                maxLevel: _selected.value?.maxLevel ?? 1,);
            },
          ),
        ),
        verticalSpacing25,
        TextButton(
          onPressed: () {
            if (!_key.currentState!.validate()) return;
            if (_selected.value == null) return;
            widget.addEnchantmentCallback(
              _selected.value!,
              int.parse(_controller.value.text),
            );
            _selected.value = null;
          },
          child: Text(context.l10n.button_add),
        ),
      ],
    );
  }

  void _resetController() {
    if (_controller.text != '1') {
      _controller.text = '1';
    }
  }

  ///
  String? _validateInput({required String value, required int maxLevel}) {
    if (value
        .trim()
        .isEmpty) {
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
