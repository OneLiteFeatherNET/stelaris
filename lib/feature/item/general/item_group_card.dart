import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/feature/base/button/cancel_button.dart';
import 'package:stelaris/feature/base/cards/dropdown_card.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris_models/stelaris_models.dart' as ItemGroup;

class ItemGroupCard extends StatelessWidget {
  const ItemGroupCard({
    required this.model,
    required this.groupKey,
    this.focusOrder,
    super.key,
  });

  final ItemModel model;
  final GlobalKey<FormState> groupKey;
  final FocusOrder? focusOrder;

  @override
  Widget build(BuildContext context) {
    return DropdownCard<EnchantmentGroup, ItemModel>(
      display: context.l10n.card_group,
      currentValue: model,
      formKey: groupKey,
      items: getGroupItems(),
      tooltipMessage: context.l10n.tooltip_item_group,
      matchTextInputHeight: true,
      focusOrder: focusOrder,
      valueUpdate: (EnchantmentGroup? value) {
        if (value == null) return;
        final EnchantmentGroup selected = value;
        if (selected.hasSameGroup(model.groupName)) return;
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                context.l10n.dialog_item_group_change_title,
                textAlign: TextAlign.center,
              ),
              contentPadding: dialogPadding,
              content: SizedBox(
                height: 75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.dialog_item_group_change_header),
                    heightTen,
                    Text(context.l10n.dialog_item_group_change_confirm),
                  ],
                ),
              ),
              actions: [
                CancelButton(
                  callback: () {
                    if (groupKey.currentState == null) return;
                    groupKey.currentState!.reset();
                  },
                ),
                FilledButton(
                  child: Text(context.l10n.button_yes),
                  onPressed: () {
                    final newEntry = model.copyWith(
                      groupName: value,
                      enchantments: ItemModel.defaultEnchantments,
                    );
                    context.dispatch(UpdateItemAction(newEntry));
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );
      },
      defaultValue: (value) => value.groupName,
    );
  }
}
