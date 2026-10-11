import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/component/component_preview.dart';
import 'package:stelaris/util/component_context.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/minimessage_parser.dart';

/// Shows the item name and its lore lines together with their formatting,
/// the way they appear in game, on the same background as the component
/// previews.
class LorePreview extends StatelessWidget {
  const LorePreview({required this.item, super.key});

  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lore = item.lore;
    final remaining = lore.totalItems - lore.items.length;

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
            child: Container(
              key: const Key('lore_preview'),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: previewBackground,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: previewBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _line(item.uiName, ComponentContext.itemName),
                  for (final line in lore.items)
                    _line(line.text, ComponentContext.lore),
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

  Widget _line(String text, ComponentContext componentContext) {
    return Text.rich(
      withContrastHalo(
        MiniMessageParser.parse(text, componentContext: componentContext),
      ),
    );
  }
}
