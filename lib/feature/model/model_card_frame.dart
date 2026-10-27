import 'package:material_ui/material_ui.dart';

/// The look of a card in a model grid, without any model behind it: the
/// [content] and an optional [trailing] widget (e.g. actions or a status
/// badge) in the header, an optional one-line [summary] below it, and a
/// footer of [footerIcon] and [footerText] below a divider when the text is
/// set.
class ModelCardFrame extends StatelessWidget {
  const ModelCardFrame({
    required this.content,
    this.trailing,
    this.summary,
    this.footerIcon,
    this.footerText,
    this.onTap,
    super.key,
  });

  final Widget content;
  final Widget? trailing;
  final String? summary;
  final IconData? footerIcon;
  final String? footerText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mutedSmall = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    final summary = this.summary;
    final footerText = this.footerText;
    final footerIcon = this.footerIcon;
    final trailing = this.trailing;

    // Fill only, no outline — the content sheet behind it already provides
    // the framing, so fill + border on top of that read as nested boxes.
    return Card.filled(
      clipBehavior: Clip.antiAlias,
      color: colorScheme.surfaceContainerLow,
      child: InkWell(
        key: const Key('model_grid_card_inkwell'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: content),
                  ?trailing,
                ],
              ),
              if (summary != null) ...[
                const SizedBox(height: 6),
                Text(
                  summary,
                  style: mutedSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (footerText != null) ...[
                const SizedBox(height: 8),
                Divider(height: 1, color: colorScheme.outlineVariant),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (footerIcon != null) ...[
                      Icon(
                        footerIcon,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        footerText,
                        style: mutedSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
