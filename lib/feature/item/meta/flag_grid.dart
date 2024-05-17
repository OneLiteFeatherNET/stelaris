import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/state/actions/item_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/api/state/factory/item/selected_item_state.dart';
import 'package:stelaris_ui/api/util/minecraft/item_flag.dart';
import 'package:stelaris_ui/feature/item/meta/single_flag_card.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/l10n_ext.dart';

class FlagGrid extends StatelessWidget {
  const FlagGrid({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedItemView>(
      vm: () => SelectedItemFactory<FlagGrid>(),
      builder: (BuildContext context, SelectedItemView vm) {
        return Column(
          children: [
            heightTen,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.save),
                  label: Text(context.l10n.button_save),
                  onPressed: () => context.dispatch(ItemDatabaseUpdate()),
                ),
                const SizedBox(width: 20),
                ActionChip(
                  avatar: const Icon(Icons.loop),
                  label: const Text('Clear'),
                  onPressed: () {
                    _showConfirmDialog(context, (bool confirm) {
                      if (confirm) {
                        context.dispatchAndWait(ItemFlagResetAction());
                      }
                    });
                  },
                )
              ],
            ),
            heightTen,
            Wrap(
              clipBehavior: Clip.hardEdge,
              runSpacing: 10,
              spacing: 10,
              children: List.generate(
                ItemFlag.values.length,
                (index) => SizedBox(
                  width: 200,
                  child: SingleFlagCard(
                    flag: ItemFlag.values[index],
                    model: vm.selected,
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  _showConfirmDialog(BuildContext context, Function(bool) onConfirm) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: dialogPadding,
          title: const Text('Confirm clear', textAlign: TextAlign.center),
          content: const Text('Are you sure to clear all selected flags?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                onConfirm.call(false);
              },
              child: Text(context.l10n.button_cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                onConfirm.call(true);
              },
              child: Text(context.l10n.button_ok),
            )
          ],
        );
      },
    );
  }
}
