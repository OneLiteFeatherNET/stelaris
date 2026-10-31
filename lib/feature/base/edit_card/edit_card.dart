import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// A card that shows one value and opens a dialog to change it.
///
/// Edit cards are outlined, where a model card, which opens a page, is
/// filled, so a grid of fields doesn't read as a list of models. The value
/// is the large text, the label a small one above it with the [icon] of the
/// field's kind, and an optional [footer] holds a rule or hint. The card is
/// as high as its content, the footer always takes two lines, so cards with
/// a footer in a row are equally high. On hover and focus a pencil shows in
/// the corner. Without [onTap] the card only shows the value, e.g. one the
/// app derives, and has no pencil.
class EditCard extends StatefulWidget {
  const EditCard({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.footer,
    this.preview,
    super.key,
  });

  final IconData icon;
  final String label;

  /// Empty shows a placeholder instead.
  final String value;
  final String? footer;
  final VoidCallback? onTap;

  /// Shown instead of the value text, e.g. a text component with its
  /// formatting. It shows its own placeholder, so the card keeps its height
  /// when the value is cleared.
  final Widget? preview;

  @override
  State<EditCard> createState() => _EditCardState();
}

class _EditCardState extends State<EditCard> {
  bool _highlighted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final muted = colorScheme.onSurfaceVariant;
    final empty = widget.value.isEmpty;
    final footer = widget.footer;
    final footerStyle = theme.textTheme.bodySmall?.copyWith(color: muted);

    return Card.outlined(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: _tappable(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(widget.icon, size: 18, color: muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: muted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Kept in the layout, so the row doesn't jump on hover, and
                  // a card without a pencil is as high as one with it.
                  if (widget.onTap == null)
                    const SizedBox.square(dimension: 18)
                  else
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 120),
                      opacity: _highlighted ? 1 : 0,
                      child: Tooltip(
                        message: context.l10n.edit_card_edit(widget.label),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: muted,
                        ),
                      ),
                    ),
                ],
              ),
              // The preview's frame needs more room below the pencil.
              SizedBox(height: widget.preview != null ? 10 : 6),
              if (widget.preview case final preview?)
                // The card's right padding is smaller for the pencil, this
                // evens out the frame of the preview.
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: preview,
                )
              else
                Text(
                  empty ? context.l10n.edit_card_placeholder : widget.value,
                  key: const Key('edit_card_value'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: empty ? muted : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (footer != null) ...[
                const SizedBox(height: 4),
                Stack(
                  children: [
                    // Reserves two lines, whatever the footer's length.
                    Text('\n', style: footerStyle),
                    Text(
                      footer,
                      style: footerStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  /// [child] with the ink and the hover of a tap, or as is without [onTap].
  Widget _tappable(Widget child) {
    final onTap = widget.onTap;
    if (onTap == null) return child;
    return InkWell(
      onTap: onTap,
      onHover: (value) => setState(() => _highlighted = value),
      onFocusChange: (value) => setState(() => _highlighted = value),
      child: child,
    );
  }
}
