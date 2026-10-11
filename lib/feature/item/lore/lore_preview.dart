import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/component/component_preview.dart';
import 'package:stelaris/util/component_context.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/minimessage_parser.dart';

/// Shows the lore lines with their formatting, the way they appear in game,
/// on the same background as the component previews.
///
/// The item name stays out, the model has no name for the game, only the one
/// in the editor.
class LorePreview extends StatelessWidget {
  const LorePreview({required this.item, super.key});

  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final lore = item.lore;
    final remaining = lore.totalItems - lore.items.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.preview_outlined,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.lore_preview_title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Flexible(
          child: Container(
            key: const Key('lore_preview'),
            decoration: BoxDecoration(
              color: previewBackground,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: previewBorder),
            ),
            // Only as high as the lines, and scrolls inside once they don't
            // fit.
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // Like the gap between the lines of a tooltip in game.
                spacing: 4,
                children: [
                  for (final line in lore.items) _line(line.text),
                  if (remaining > 0)
                    Text(
                      context.l10n.lore_preview_more(remaining),
                      style: const TextStyle(
                        color: previewPlaceholderColor,
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _line(String text) {
    return Text.rich(
      withTextShadow(
        MiniMessageParser.parse(
          text,
          componentContext: ComponentContext.lore,
          fontWeight: previewFontWeight,
        ),
      ),
    );
  }
}
