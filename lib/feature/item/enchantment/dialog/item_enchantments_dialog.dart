import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris/api/model/item/item_enchantment_dto.dart';
import 'package:stelaris/api/model/item_model.dart';
import 'package:stelaris/api/state/actions/item/item_enchantment_actions.dart';
import 'package:stelaris/api/state/factory/item/enchantment_view_state.dart';
import 'package:stelaris/feature/item/enchantment_reducer.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/constants.dart';
import 'package:vulpes_data/api/enchantment.dart';

class ItemEnchantmentAddDialog extends StatefulWidget {
  const ItemEnchantmentAddDialog({
    required this.model,
    required this.view,
    super.key,
  });

  final ItemModel model;
  final EnchantmentView view;

  @override
  State<ItemEnchantmentAddDialog> createState() =>
      _ItemEnchantmentAddDialogState();
}

class _ItemEnchantmentAddDialogState extends State<ItemEnchantmentAddDialog>
    with EnchantmentReducer {
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<bool> _unsafe = ValueNotifier(false);
  final _key = GlobalKey<FormState>();

  late final ValueNotifier<Enchantment> _selected;
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

  @override
  void dispose() {
    _controller.dispose();
    _selected.dispose();
    _unsafe.dispose();
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
        ValueListenableBuilder<Enchantment>(
          valueListenable: _selected,
          builder: (context, selectedEnchantment, child) {
            return DropdownButtonFormField<Enchantment>(
              autofocus: true,
              initialValue: selectedEnchantment,
              items: _enchantments,
              onChanged: (value) {
                _selected.value = value!;
                _resetController();
              },
            );
          },
        ),
        verticalSpacing25,
        Text(context.l10n.label_level),
        verticalSpacing25,
        ValueListenableBuilder<bool>(
          valueListenable: _unsafe,
          builder: (context, unsafe, child) {
            return CheckboxListTile(
              title: const Text('Unsafe'),
              value: unsafe,
              onChanged: (value) {
                _unsafe.value = value ?? false;
                _key.currentState?.validate();
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            );
          },
        ),
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
                maxLevel: _selected.value.maxLevel,
                unsafe: _unsafe.value,
              );
            },
          ),
        ),
        verticalSpacing25,
        TextButton(
          onPressed: () {
            if (!_key.currentState!.validate()) return;
            final int level = int.parse(_controller.value.text);
            _handleAddCallback(_selected.value, level, _unsafe.value);
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

  void _updateEnchantments() {
    _enchantments = widget.view.selectableEnchantments
        .map(
          (e) => DropdownMenuItem<Enchantment>(
        value: e,
        child: Text(e.displayName),
      ),
    )
        .toList();
    if (_enchantments.isNotEmpty) {
      _selected = ValueNotifier(_enchantments.first.value!);
    }
  }

  /// Handles the add logic of an selected [Enchantment] with the given data
  /// It calls the [ItemEnchantmentAddAction] to save it in the database etc.
  /// [enchantment] which should be added to the [ItemModel]
  /// [level] the level which should be used
  /// [unsafe] indication if the [Enchantment] is unsafe or not
  void _handleAddCallback(Enchantment enchantment, int level, bool unsafe) {
    final ItemEnchantmentDto dto = ItemEnchantmentDto(
      name: enchantment.minecraftValue,
      level: level,
      unsafe: unsafe,
    );
    context.dispatch(ItemEnchantmentAddAction(dto));
    Navigator.of(context).pop();
  }

  ///
  String? _validateInput({
    required String value,
    required int maxLevel,
    required bool unsafe,
  }) {
    if (value.trim().isEmpty) {
      return 'Please enter a level';
    }
    final level = int.tryParse(value);
    if (level == null) {
      return 'Please enter a valid number';
    }

    if (!unsafe && level > maxLevel) {
      return 'The maximum is $maxLevel';
    }

    return null;
  }
}
