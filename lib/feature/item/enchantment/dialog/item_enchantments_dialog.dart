import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/item/item_enchantment_actions.dart';
import 'package:stelaris/api/state/factory/item/enchantment_view_state.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/item/enchantment_reducer.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/validators.dart';
import 'package:vulpes_data/api/enchantment.dart';

class ItemEnchantmentAddDialog extends StatefulWidget {
  const ItemEnchantmentAddDialog({required this.view, super.key});

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

  late final List<DropdownMenuItem<Enchantment>> _enchantments = widget
      .view
      .selectableEnchantments
      .map(
        (e) => DropdownMenuItem<Enchantment>(value: e, child: Text(e.displayName)),
      )
      .toList();
  late final ValueNotifier<Enchantment> _selected = ValueNotifier(
    _enchantments.first.value!,
  );

  @override
  void initState() {
    super.initState();
    _resetController();
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
    return FormDialog(
      title: context.l10n.dialog_item_enchantment_title,
      actionIcon: Icons.add,
      actionLabel: context.l10n.button_add,
      onSubmit: _handleAdd,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<Enchantment>(
            valueListenable: _selected,
            builder: (context, selectedEnchantment, child) {
              return DropdownButtonFormField<Enchantment>(
                autofocus: true,
                initialValue: selectedEnchantment,
                items: _enchantments,
                decoration: InputDecoration(
                  labelText: context.l10n.dialog_item_enchantment,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _selected.value = value!;
                  _resetController();
                },
              );
            },
          ),
          verticalSpacing10,
          ValueListenableBuilder<bool>(
            valueListenable: _unsafe,
            builder: (context, unsafe, child) {
              return Transform.translate(
                offset: const Offset(-12, 0),
                child: CheckboxListTile(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  title: const Text('Unsafe'),
                  value: unsafe,
                  onChanged: (value) {
                    _unsafe.value = value ?? false;
                    _key.currentState?.validate();
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              );
            },
          ),
          verticalSpacing10,
          Form(
            key: _key,
            autovalidateMode: AutovalidateMode.always,
            child: TextFormField(
              controller: _controller,
              autocorrect: false,
              keyboardType: numberInput,
              inputFormatters: [FilteringTextInputFormatter.allow(numberPattern)],
              decoration: InputDecoration(
                labelText: context.l10n.label_level,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null) return null;
                return Validators.enchantmentLevel(
                  value: value,
                  maxLevel: _selected.value.maxLevel,
                  unsafe: _unsafe.value,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleAdd() {
    if (!_key.currentState!.validate()) return;
    final int level = int.parse(_controller.value.text);
    _handleAddCallback(_selected.value, level, _unsafe.value);
  }

  void _resetController() {
    if (_controller.text != '1') {
      _controller.text = '1';
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
}
