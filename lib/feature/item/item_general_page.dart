import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/api/state/actions/item_actions.dart';
import 'package:stelaris_ui/feature/base/button/save_button.dart';
import 'package:stelaris_ui/feature/base/cards/dropdown_card.dart';
import 'package:stelaris_ui/feature/base/cards/text_input_card.dart';
import 'package:stelaris_ui/feature/item/enchantment_reducer.dart';
import 'package:stelaris_ui/feature/item/item_group.dart';
import 'package:stelaris_ui/feature/item/item_group_change_dialog.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';

const List<ItemGroup> values = ItemGroup.values;

List<DropdownMenuItem<ItemGroup>> getItems() {
  return List.generate(
      values.length,
      (index) => DropdownMenuItem(
            value: values[index],
            child: Text(values[index].display),
          ));
}

class ItemGeneralPage extends StatefulWidget {
  final ItemModel model;
  final ValueNotifier<ItemModel?> selectedItem;

  const ItemGeneralPage({
    required this.model,
    required this.selectedItem,
    super.key,
  });

  @override
  State<ItemGeneralPage> createState() => _ItemGeneralPageState();
}

class _ItemGeneralPageState extends State<ItemGeneralPage>
    with EnchantmentReducer {
  final _key = GlobalKey<FormState>();
  final _groupKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
          autovalidateMode: AutovalidateMode.always,
          key: _key,
          child: Wrap(
            children: [
              TextInputCard<String>(
                infoText: context.l10n.tooltip_name,
                title: Text(context.l10n.card_name),
                currentValue: widget.model.name ?? emptyString,
                formatter: [FilteringTextInputFormatter.allow(stringPattern)],
                valueUpdate: (value) {
                  if (value == widget.model.name) return;
                  final oldModel = widget.model;
                  final newEntry = oldModel.copyWith(name: value);
                  setState(() {
                    StoreProvider.dispatch(
                        context, UpdateItemAction(oldModel, newEntry));
                    widget.selectedItem.value = newEntry;
                  });
                },
                formValidator: (value) {
                  var input = value as String;

                  if (input.trim().isEmpty) {
                    return context.l10n.error_card_empty;
                  }
                  return null;
                },
              ),
              TextInputCard<String>(
                infoText: context.l10n.tooltip_description,
                title: Text(context.l10n.card_description),
                currentValue: widget.model.description ?? emptyString,
                valueUpdate: (value) {
                  if (value == widget.model.description) return;
                  final oldModel = widget.model;
                  final newEntry = oldModel.copyWith(description: value);
                  setState(() {
                    StoreProvider.dispatch(
                        context, UpdateItemAction(oldModel, newEntry));
                    widget.selectedItem.value = newEntry;
                  });
                },
              ),
              DropDownCard<ItemGroup, ItemModel>(
                title: Text(context.l10n.card_group),
                currentValue: widget.model,
                formKey: _groupKey,
                items: getItems(),
                valueUpdate: (ItemGroup? value) {
                  if (identical(value!.display, widget.model.group)) return;

                  var list = getRemoveItems(widget.model, value);

                  if (list.isNotEmpty) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ItemGroupChangeDialog(
                            title: Text(
                              context.l10n.dialog_group_change,
                              textAlign: TextAlign.center,
                            ),
                            header: [
                              TextSpan(
                                  text: context.l10n.dialog_group_change_text,
                                  style: whiteStyle),
                            ],
                            function: (value) {
                              return true;
                            },
                          );
                        }).then((result) {
                      if (result == null) return;

                      if (result == true) {
                        final oldEnchantments =
                            Map.of(widget.model.enchantments!);

                        for (var enchantment in list) {
                          oldEnchantments.remove(enchantment);
                        }
                        final newEntry = widget.model.copyWith(
                            group: value.display,
                            enchantments: oldEnchantments);
                        setState(() {
                          StoreProvider.dispatch(context,
                              UpdateItemAction(widget.model, newEntry));
                          widget.selectedItem.value = newEntry;
                        });
                      } else {
                        _groupKey.currentState!.reset();
                      }
                    });
                  } else {
                    final newEntry =
                        widget.model.copyWith(group: value.display);
                    setState(() {
                      StoreProvider.dispatch(
                          context, UpdateItemAction(widget.model, newEntry),
                      );
                      widget.selectedItem.value = newEntry;
                    });
                  }
                },
                defaultValue: getDefaultValue,
              ),
              TextInputCard<String>(
                infoText: context.l10n.tooltip_material,
                title: Text(context.l10n.card_material),
                currentValue: widget.model.material ?? emptyString,
                valueUpdate: (value) {
                  if (value == widget.model.material) return;
                  final oldModel = widget.model;
                  final newEntry = oldModel.copyWith(material: value);
                  setState(() {
                    StoreProvider.dispatch(
                        context, UpdateItemAction(oldModel, newEntry));
                    widget.selectedItem.value = newEntry;
                  });
                },
                formValidator: (value) {
                  if (value == null) return null;
                  if (!minecraftPattern.hasMatch(value)) {
                    return context.l10n.input_validation_material;
                  }
                  return null;
                },
              ),
              TextInputCard<String>(
                infoText: context.l10n.tooltip_displayname,
                title: Text(context.l10n.card_display_name),
                currentValue: widget.model.displayName ?? emptyString,
                valueUpdate: (value) {
                  if (value == widget.model.displayName) return;
                  final oldModel = widget.model;
                  final newEntry = oldModel.copyWith(displayName: value);
                  setState(() {
                    StoreProvider.dispatch(
                        context, UpdateItemAction(oldModel, newEntry));
                    widget.selectedItem.value = newEntry;
                  });
                },
              ),
              TextInputCard(
                infoText: context.l10n.tooltip_model_data,
                title: Text(context.l10n.card_model_data),
                currentValue: widget.model.customModelId?.toString() ?? zeroString,
                valueUpdate: (value) {
                  if (value == widget.model.customModelId) return;
                  final oldModel = widget.model;
                  final newID = int.parse(value);
                  final newEntry = oldModel.copyWith(customModelId: newID);
                  setState(() {
                    StoreProvider.dispatch(
                        context, UpdateItemAction(oldModel, newEntry));
                    widget.selectedItem.value = newEntry;
                  });
                },
                inputType: numberInput,
                formatter: [FilteringTextInputFormatter.allow(numberPattern)],
              ),
              TextInputCard(
                infoText: context.l10n.tooltip_amount,
                title: Text(context.l10n.card_amount),
                currentValue: widget.model.amount?.toString() ?? zeroString,
                valueUpdate: (value) {
                  if (value == widget.model.amount) return;
                  final oldModel = widget.model;
                  final newAmount = int.parse(value);
                  final newEntry = oldModel.copyWith(amount: newAmount);
                  setState(() {
                    StoreProvider.dispatch(
                        context, UpdateItemAction(oldModel, newEntry));
                    widget.selectedItem.value = newEntry;
                  });
                },
                inputType: numberInput,
                formatter: [FilteringTextInputFormatter.allow(numberPattern)],
                formValidator: (value) {
                  if (value == null) return null;
                  String input = value as String;
                  if (input.trim().isEmpty)
                    return context.l10n.error_card_empty;

                  if (int.parse(input) > maxItemSize) {
                    return context.l10n.card_amount_to_high;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        SaveButton(callback: () {
          if (!_key.currentState!.validate()) return;
          ApiService().itemApi.update(widget.model);
        })
      ],
    );
  }

  ItemGroup getDefaultValue(ItemModel value) {
    if (value.group == null) {
      return ItemGroup.misc;
    }
    return values.firstWhere((element) => element.display == value.group);
  }

  List<DropdownMenuItem<ItemGroup>> getItems() {
    return values
        .map((e) => DropdownMenuItem(
              value: e,
              child: Text(e.display),
            ))
        .toList();
  }
}
