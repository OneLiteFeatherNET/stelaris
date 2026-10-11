import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Shows the lore the way Minecraft draws an item tooltip: the item name on
/// top, the lore lines below in the default dark purple italic. The texts are
/// shown as they are, formatting in them isn't rendered.
class LorePreview extends StatelessWidget {
  const LorePreview({required this.item, super.key});

  final ItemModel item;

  // The colors of the vanilla tooltip.
  static const Color _background = Color(0xF0100010);
  static const Color _borderTop = Color(0x505000FF);
  static const Color _borderBottom = Color(0x5028007F);
  static const Color _nameColor = Color(0xFFFFFFFF);
  static const Color _loreColor = Color(0xFFAA00AA);
  static const Color _mutedColor = Color(0xFFAAAAAA);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lore = item.lore;
    final remaining = lore.totalItems - lore.items.length;
    final textStyle = theme.textTheme.bodyMedium?.copyWith(height: 1.4);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.lore_preview_title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: SingleChildScrollView(
            // The dark box, inside it the 1px frame fading from top to
            // bottom, inside that the dark box again.
            child: Container(
              key: const Key('lore_preview'),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: _background,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_borderTop, _borderBottom],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  decoration: BoxDecoration(
                    color: _background,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.uiName,
                        style: textStyle?.copyWith(color: _nameColor),
                      ),
                      for (final line in lore.items)
                        Text(
                          line.text,
                          style: textStyle?.copyWith(
                            color: _loreColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      if (remaining > 0)
                        Text(
                          context.l10n.lore_preview_more(remaining),
                          style: textStyle?.copyWith(color: _mutedColor),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
