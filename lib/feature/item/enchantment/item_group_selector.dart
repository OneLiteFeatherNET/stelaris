import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/feature/base/button/cancel_button.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/constants.dart';

/// Picks the item's [EnchantmentGroup], which decides the enchantments it
/// can carry. A header action on the Enchantments tab, which opens a menu
/// of the groups.
///
/// A change resets the enchantments, so it is confirmed in a dialog first.
/// The button always names the item's current group: a cancelled change
/// leaves it as it was.
class ItemGroupSelector extends StatelessWidget {
  const ItemGroupSelector({required this.model, super.key});

  static const double _width = 220;

  final ItemModel model;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return MenuAnchor(
      // Opens below the button, aligned to its end, like the component
      // category filter.
      alignmentOffset: const Offset(-_width, 4),
      style: MenuStyle(
        alignment: AlignmentDirectional.bottomEnd,
        visualDensity: VisualDensity.compact,
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 6),
        ),
      ),
      menuChildren: [
        for (final group in EnchantmentGroup.values)
          MenuItemButton(
            key: Key('item_group_${group.name}'),
            onPressed: group.hasSameGroup(model.groupName)
                ? null
                : () => _confirmChange(context, group),
            style: MenuItemButton.styleFrom(
              minimumSize: const Size(_width, 40),
              maximumSize: const Size(_width, 40),
              padding: const EdgeInsetsDirectional.only(start: 12, end: 20),
              backgroundColor: group == model.groupName
                  ? colorScheme.secondaryContainer
                  : null,
              disabledForegroundColor: colorScheme.onSecondaryContainer,
            ),
            // An empty box keeps the labels in line with the active one.
            leadingIcon: group == model.groupName
                ? const Icon(Icons.check, size: 18)
                : const SizedBox(width: 18),
            child: Text(group.display),
          ),
      ],
      builder: (context, controller, _) => Tooltip(
        message: context.l10n.tooltip_item_group,
        child: PageHeaderAction(
          key: const Key('item_group_selector'),
          icon: const Icon(Icons.category_outlined),
          label: model.groupName.display,
          onPressed: () =>
              controller.isOpen ? controller.close() : controller.open(),
        ),
      ),
    );
  }

  void _confirmChange(BuildContext context, EnchantmentGroup value) {
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
            const CancelButton(),
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
  }
}
