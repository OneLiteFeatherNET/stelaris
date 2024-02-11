import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/api/model/item_model.dart';

import 'package:async_redux/async_redux.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/state/actions/item_actions.dart';
import 'package:stelaris_ui/api/util/minecraft/item_flag.dart';
import 'package:stelaris_ui/feature/base/button/delete_entry_button.dart';
import 'package:stelaris_ui/feature/base/button/save_button.dart';
import 'package:stelaris_ui/feature/base/cards/expandable_data_card.dart';
import 'package:stelaris_ui/feature/dialogs/abort_add_dialog.dart';
import 'package:stelaris_ui/feature/dialogs/entry_add_dialog.dart';
import 'package:stelaris_ui/feature/dialogs/enum_add_dialog.dart';
import 'package:stelaris_ui/feature/dialogs/item_enchantments_dialog.dart';
import 'package:stelaris_ui/feature/base/button/entry_buttons.dart';
import 'package:stelaris_ui/feature/item/enchantment_reducer.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/feature/item/item_reducer.dart';

class ItemMetaPage extends StatelessWidget
    with EnchantmentReducer, DropDownItemReducer {
  final ItemModel model;

  ItemMetaPage({
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> flags = model.flags == null ? [] : model.flags!.toList();
    return Stack(
      children: [
        SingleChildScrollView(
          child: Wrap(
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
                          items: reduceFlags(model),
                          valueUpdate: (value) {
                            final oldEntry = model;
                            Set<String> flags = Set.of(oldEntry.flags ?? {});
                            flags.add(value!.minestomValue);
                            final newEntry = oldEntry.copyWith(flags: flags);
                            StoreProvider.dispatch(
                                context, UpdateItemAction(oldEntry, newEntry));
                            Navigator.pop(context);
                            //widget.selectedItem.value = newEntry;
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
                            final oldEntry = model;
                            Set<String> oldFlags = Set.of(oldEntry.flags ?? {});
                            oldFlags.remove(key);
                            final newEntry = oldEntry.copyWith(flags: oldFlags);
                            StoreProvider.dispatch(
                                context, UpdateItemAction(oldEntry, newEntry));
                            //widget.selectedItem.value = newEntry;
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
                      if (model.enchantments != null && !canAdd(model)) {
                        return AbortAddDialog(
                            title: context.l10n.dialog_abort_enchantment_title,
                            content: context.l10n.dialog_abort_enchantments);
                      }
                      final oldEntry = model;
                      return ItemEnchantmentAddDialog(
                        model: model,
                        formFieldValidator: (value) {
                          var input = value as String;

                          if (input.trim().isEmpty) {
                            return context.l10n.error_card_empty;
                          }
                          return null;
                        },
                        addEnchantmentCallback: (selected, level) {
                          final oldEnchantments =
                              Map<String, int>.of(oldEntry.enchantments ?? {});
                          oldEnchantments[selected.minecraftValue] = level;
                          final newEntry =
                              oldEntry.copyWith(enchantments: oldEnchantments);
                          Navigator.pop(context);
                          StoreProvider.dispatch(
                              context, UpdateItemAction(oldEntry, newEntry));
                          //widget.selectedItem.value = newEntry;
                        },
                      );
                    },
                  );
                },
                widgets: List<Widget>.generate(
                  model.enchantments?.length ?? 0,
                  (index) {
                    final key = model.enchantments?.keys.elementAt(index);
                    final value = model.enchantments?.values.elementAt(index);
                    return ListTile(
                      title: Text("$key, Level: $value"),
                      trailing: EntryButtons(
                        editTitle: context.l10n.dialog_level_title,
                        model: model,
                        name: key,
                        value: value.toString(),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(numberPattern)
                        ],
                        formFieldValidator: (value) {
                          var input = value as String;

                          if (input.trim().isEmpty) {
                            return context.l10n.error_card_empty;
                          }
                          return null;
                        },
                        delete: (ItemModel? value) {
                          final oldEntry = model;
                          final oldEnchantments =
                              Map<String, int>.of(oldEntry.enchantments ?? {});
                          oldEnchantments.remove(key);
                          final newEntry =
                              oldEntry.copyWith(enchantments: oldEnchantments);
                          StoreProvider.dispatch(
                              context, UpdateItemAction(oldEntry, newEntry));
                          //widget.selectedItem.value = newEntry;
                        },
                        update: (value, key) {
                          final oldEntry = model;
                          final oldEnchantments = Map<String, int>.from(
                              oldEntry.enchantments ?? {});
                          oldEnchantments[value!] = int.parse(key!);
                          final newEntry =
                              oldEntry.copyWith(enchantments: oldEnchantments);
                          StoreProvider.dispatch(
                              context, UpdateItemAction(oldEntry, newEntry));
                          //widget.selectedItem.value = newEntry;
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
                            final oldEntry = model;
                            List<String> oldLores =
                                List.of(oldEntry.lore ?? []);
                            oldLores.add(value);
                            final newEntry = oldEntry.copyWith(lore: oldLores);
                            StoreProvider.dispatch(
                                context, UpdateItemAction(oldEntry, newEntry));
                            Navigator.pop(context);
                            //widget.selectedItem.value = newEntry;
                          }),
                          formFieldValidator: (value) {
                            var input = value as String;

                            if (input.trim().isEmpty) {
                              return context.l10n.error_card_empty;
                            }
                            return null;
                          },
                          title: Text(context.l10n.button_add_new_line));
                    },
                  );
                },
                widgets: List<Widget>.generate(
                  model.lore?.length ?? 0,
                  (index) {
                    final key = model.lore?[index];
                    return ListTile(
                      title: Text(key!),
                      trailing: EntryButtons(
                        editTitle: context.l10n.dialog_lore_edit_title,
                        model: model,
                        name: key,
                        value: key,
                        formFieldValidator: (value) {
                          var input = value as String;

                          if (input.trim().isEmpty) {
                            return context.l10n.error_card_empty;
                          }
                          return null;
                        },
                        delete: (ItemModel? value) {
                          final oldEntry = model;
                          List<String> oldLores = List.of(oldEntry.lore ?? []);
                          oldLores.remove(key);
                          final newEntry = oldEntry.copyWith(lore: oldLores);
                          StoreProvider.dispatch(
                              context, UpdateItemAction(oldEntry, newEntry));
                          //widget.selectedItem.value = newEntry;
                        },
                        update: (value, key) {
                          final oldEntry = model;
                          List<String> oldLores = List.of(oldEntry.lore ?? []);
                          int index = oldLores.indexWhere(
                              (element) => identical(element, value));
                          oldLores[index] = key!;
                          final newEntry = oldEntry.copyWith(lore: oldLores);
                          StoreProvider.dispatch(
                              context, UpdateItemAction(oldEntry, newEntry));
                          //widget.selectedItem.value = newEntry;
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        SaveButton(
          callback: () {
            ApiService().itemApi.update(model);
          },
        )
      ],
    );
  }
}
