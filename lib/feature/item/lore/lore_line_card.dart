import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/base/action/entry_actions.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// One lore line as a card in the style of the component cards: a drag
/// handle, the line number, the text and the edit/delete actions.
class LoreLineCard extends StatelessWidget {
  const LoreLineCard({
    required this.dto,
    required this.index,
    required this.onEdit,
    required this.onDelete,
    this.lift = 0,
    super.key,
  });

  final ItemLoreDto dto;

  /// The position in the list, starts the drag and gives the line number.
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// How far the card is lifted above the others while it is dragged, from
  /// 0 resting to 1 picked up.
  final double lift;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final grabbed = lift > 0;

    return Card.filled(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 6 * lift,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.secondary.withValues(alpha: lift)),
      ),
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 8, 6),
          child: Row(
            children: [
              _DragHandle(index: index, grabbed: grabbed),
              _LineNumber(number: index + 1),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  dto.text,
                  style: theme.textTheme.bodyLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              EntryActions(onEdit: onEdit, onDelete: onDelete),
            ],
          ),
        ),
      ),
    );
  }
}

/// Starts the drag of the line at [index], and keeps a click on it from
/// reaching the card, which would edit the line.
class _DragHandle extends StatelessWidget {
  const _DragHandle({required this.index, required this.grabbed});

  final int index;

  /// Whether the line is being dragged.
  final bool grabbed;

  @override
  Widget build(BuildContext context) {
    Widget handle = MouseRegion(
      cursor: grabbed ? SystemMouseCursors.grabbing : SystemMouseCursors.grab,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          Icons.drag_indicator,
          key: const Key('lore_drag_handle'),
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
    // Not while dragging, the pointer stays on the handle the whole time.
    if (!grabbed) {
      handle = Tooltip(message: context.l10n.tooltip_lore_drag, child: handle);
    }

    // The innermost tap wins, so this one takes the click from the card's
    // InkWell and does nothing with it. The drag still starts, the listener
    // reacts to the pointer and not to taps.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Not a button for screen readers, the tap does nothing.
      excludeFromSemantics: true,
      onTap: () {},
      child: ReorderableDragStartListener(index: index, child: handle),
    );
  }
}

class _LineNumber extends StatelessWidget {
  const _LineNumber({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$number',
        style: theme.textTheme.labelMedium?.copyWith(
          color: colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
