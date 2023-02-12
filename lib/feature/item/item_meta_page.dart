import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/item_model.dart';

import 'package:async_redux/async_redux.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/state/actions/item_actions.dart';
import 'package:stelaris_ui/api/util/minecraft/item_flag.dart';
import 'package:stelaris_ui/feature/base/button/delete_entry_button.dart';
import 'package:stelaris_ui/feature/base/button/save_button.dart';
import 'package:stelaris_ui/feature/base/cards/expandable_data_card.dart';
import 'package:stelaris_ui/feature/dialogs/abort_add_dialog.dart';
import 'package:stelaris_ui/feature/dialogs/enum_add_dialog.dart';
import 'package:stelaris_ui/feature/dialogs/item_enchantments_dialog.dart';
import 'package:stelaris_ui/feature/dialogs/item_flag_dialog.dart';
import 'package:stelaris_ui/feature/item/enchantment_entry_buttons.dart';
import 'package:stelaris_ui/feature/item/enchantment_reducer.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/feature/item/item_reducer.dart';

class ItemMetaPage extends StatefulWidget with DropDownItemReducer {
  final ItemModel model;
  final ValueNotifier<ItemModel?> selectedItem;

  const ItemMetaPage(
      {Key? key, required this.model, required this.selectedItem})
      : super(key: key);

  @override
  State<ItemMetaPage> createState() => _ItemMetaPageState();
}

class _ItemMetaPageState extends State<ItemMetaPage> with EnchantmentReducer {
  @override
  Widget build(BuildContext context) {
    final List<String> flags =
        widget.model.flags == null ? [] : widget.model.flags!.toList();
    return Stack(
      children: [
        Wrap(
          clipBehavior: Clip.hardEdge,
          children: [
            ExpandableDataCard(
              title: Text(context.l10n.card_flags),
              buttonClick: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    if (flags.length == ItemFlag.values.length) {
                      return AbortAddDialog(
                          title: context.l10n.dialog_abort_flags_title,
                          content: context.l10n.dialog_abort_flags);
                    }
                    return EnumAddDialog<ItemFlag>(
                        title: Text(context.l10n.enum_dialog_flags,
                            textAlign: TextAlign.center),
                        items: widget.reduceFlags(widget.model),
                        valueUpdate: (value) {
                          final oldEntry = widget.model;
                          Set<String> flags = Set.of(oldEntry.flags ?? {});
                          flags.add(value!.minestomValue);
                          final newEntry = oldEntry.copyWith(flags: flags);
                          setState(() {
                            StoreProvider.dispatch(
                                context, UpdateItemAction(oldEntry, newEntry));
                            Navigator.pop(context);
                            widget.selectedItem.value = newEntry;
                          });
                        });
                  },
                );
              },
              widgets: List<Widget>.generate(
                flags.length,
                (index) {
                  final key = flags[index];
                  return ListTile(
                      title: Text(key),
                      trailing: DeleteEntryButton<String>(
                        title: context.l10n.dialog_delete_confirm,
                        header: [
                          TextSpan(
                              text: context.l10n.delete_dialog_first_line,
                              style: whiteStyle),
                          TextSpan(text: key, style: redStyle),
                          TextSpan(
                              text: context.l10n.delete_dialog_entry,
                              style: whiteStyle),
                        ],
                        value: key,
                        mapToDeleteSuccessfully: (value) {
                          final oldEntry = widget.model;
                          Set<String> oldFlags = Set.of(oldEntry.flags ?? {});
                          oldFlags.remove(key);
                          final newEntry = oldEntry.copyWith(flags: oldFlags);
                          setState(
                            () {
                              StoreProvider.dispatch(context,
                                  UpdateItemAction(oldEntry, newEntry));
                              widget.selectedItem.value = newEntry;
                            },
                          );
                          return true;
                        },
                      ));
                },
              ),
            ),
            ExpandableDataCard(
              title: Text(context.l10n.card_enchantments),
              buttonClick: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    if (widget.model.enchantments != null &&
                        !canAdd(widget.model)) {
                      return AbortAddDialog(
                          title: context.l10n.dialog_abort_enchantment_title,
                          content: context.l10n.dialog_abort_enchantments);
                    }
                    final oldEntry = widget.model;
                    return ItemEnchantmentAddDialog(
                      model: widget.model,
                      addEnchantmentCallback: (selected, level) {
                        final oldEnchantments =
                            Map<String, int>.of(oldEntry.enchantments ?? {});
                        oldEnchantments[selected.minecraftValue] = level;
                        final newEntry =
                            oldEntry.copyWith(enchantments: oldEnchantments);
                        setState(
                          () {
                            Navigator.pop(context);
                            StoreProvider.dispatch(
                                context, UpdateItemAction(oldEntry, newEntry));
                            widget.selectedItem.value = newEntry;
                          },
                        );
                      },
                    );
                  },
                );
              },
              widgets: List<Widget>.generate(
                widget.model.enchantments?.length ?? 0,
                (index) {
                  final key = widget.model.enchantments?.keys.elementAt(index);
                  final value =
                      widget.model.enchantments?.values.elementAt(index);
                  return ListTile(
                    title: Text("$key, Level: $value"),
                    trailing: EnchantmentButtons(
                      model: widget.model,
                      name: key,
                      level: value,
                      delete: (ItemModel? value) {
                        final oldEntry = widget.model;
                        final oldEnchantments =
                            Map<String, int>.of(oldEntry.enchantments ?? {});
                        oldEnchantments.remove(key);
                        final newEntry =
                            oldEntry.copyWith(enchantments: oldEnchantments);
                        setState(
                          () {
                            StoreProvider.dispatch(
                                context, UpdateItemAction(oldEntry, newEntry));
                            widget.selectedItem.value = newEntry;
                          },
                        );
                      },
                      update: (value, key) {
                        final oldEntry = widget.model;
                        final oldEnchantments =
                            Map<String, int>.from(oldEntry.enchantments ?? {});
                        oldEnchantments[value!] = int.parse(key!);
                        final newEntry =
                            oldEntry.copyWith(enchantments: oldEnchantments);
                        setState(() {
                          StoreProvider.dispatch(
                              context, UpdateItemAction(oldEntry, newEntry));
                          widget.selectedItem.value = newEntry;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            ExpandableDataCard(
              title: Text(context.l10n.card_lore),
              buttonClick: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return EntryAddDialog(
                        controller: TextEditingController(),
                        valueUpdate: ((value) {
                          final oldEntry = widget.model;
                          List<String> oldLores = List.of(oldEntry.lore ?? []);
                          oldLores.add(value);
                          final newEntry = oldEntry.copyWith(lore: oldLores);
                          setState(() {
                            StoreProvider.dispatch(
                                context, UpdateItemAction(oldEntry, newEntry));
                            Navigator.pop(context);
                            widget.selectedItem.value = newEntry;
                          });
                        }),
                        title: Text(context.l10n.button_add_new_line));
                  },
                );
              },
              widgets: List<Widget>.generate(
                widget.model.lore?.length ?? 0,
                (index) {
                  final key = widget.model.lore?[index];
                  return ListTile(
                      title: Text(key!),
                      trailing: DeleteEntryButton<String>(
                        title: context.l10n.dialog_delete_confirm,
                        value: key,
                        header: [
                          TextSpan(
                              text: context.l10n.delete_dialog_first_line,
                              style: whiteStyle),
                          TextSpan(text: key, style: redStyle),
                          TextSpan(
                              text: context.l10n.delete_dialog_entry,
                              style: whiteStyle),
                        ],
                        mapToDeleteSuccessfully: (value) {
                          final oldEntry = widget.model;
                          List<String> oldLores = List.of(oldEntry.lore ?? []);
                          oldLores.remove(key);
                          final newEntry = oldEntry.copyWith(lore: oldLores);
                          setState(() {
                            StoreProvider.dispatch(
                                context, UpdateItemAction(oldEntry, newEntry));
                            widget.selectedItem.value = newEntry;
                          });
                          return true;
                        },
                      ));
                },
              ),
            ),
          ],
        ),
        SaveButton(callback: () {
          ApiService().itemApi.update(widget.model);
        })
      ],
    );
  }
}
