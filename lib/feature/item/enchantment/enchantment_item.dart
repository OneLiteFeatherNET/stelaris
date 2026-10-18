import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/item/item_enchantment_actions.dart';
import 'package:stelaris/feature/dialogs/delete_dialog.dart';
import 'package:stelaris/feature/item/enchantment/dialog/item_enchantment_update_dialog.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:vulpes_data/enchantment.dart';

class EnchantmentItem extends StatelessWidget {
  const EnchantmentItem({
    required this.dto,
    required this.enchantment,
    super.key,
  });

  final ItemEnchantmentDto dto;
  final Enchantment enchantment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card.filled(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppShapes.medium),
      ),
      child: InkWell(
        onTap: () => _showUpdateDialog(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            enchantment.displayName,
                            style: theme.textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (dto.unsafe) ...[
                          const SizedBox(width: 8),
                          const _UnsafeLabel(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    _getEnchantmentSubTitle(context, theme),
                  ],
                ),
              ),
              // A tap on the card edits, so only deleting needs a button.
              IconButton(
                tooltip: context.l10n.tooltip_delete,
                onPressed: () => _showDeleteDialog(context),
                icon: const Icon(Icons.delete_forever),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Applies the right sub title [Widget] based on the [ItemEnchantmentDto.unsafe] flag.
  /// An unsafe level may exceed the maximum, so the maximum is left out.
  /// [theme] the current [ThemeData] to get some values from it
  /// Returns the concrete [Widget] that displays the data
  Widget _getEnchantmentSubTitle(BuildContext context, ThemeData theme) {
    return Text(
      dto.unsafe
          ? context.l10n.item_level(dto.level)
          : context.l10n.item_level_max(dto.level, enchantment.maxLevel),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ItemEnchantmentUpdateDialog(enchantment: enchantment, dto: dto);
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteDialog<ItemEnchantmentDto>(
          title: context.l10n.dialog_item_enchantment_delete_title,
          header: [
            TextSpan(
              text: context.l10n.dialog_item_enchantment_delete_header,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          value: dto,
          successfully: (value) {
            context.dispatch(ItemEnchantmentDeleteAction(value));
            return true;
          },
        );
      },
    );
  }
}

/// Marks an enchantment whose level may exceed the normal maximum.
class _UnsafeLabel extends StatelessWidget {
  const _UnsafeLabel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Tooltip(
      message: context.l10n.dialog_item_enchantment_unsafe_hint,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(AppShapes.extraSmall),
        ),
        child: Text(
          context.l10n.dialog_item_enchantment_unsafe,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onTertiaryContainer,
          ),
        ),
      ),
    );
  }
}
