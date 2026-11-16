import 'package:material_ui/material_ui.dart';

/// A row of compact icon-button actions in the header of a card, e.g. a
/// `CardActionsMenu` and a `DeleteIconButton` on a model grid card. Each
/// child wraps a plain IconButton. Content
/// below the title (e.g. a key badge) means the header can be taller than
/// one line, so the row is top-aligned against it rather than centered
/// against the whole block. 30x30 keeps each button's box close to
/// titleMedium's line-box height (~24px), but Text's font leading and
/// IconButton's own centering don't share the same top inset, so a small
/// manual [offset] closes the remaining gap between the title's glyphs and
/// the icons.
class CardActions extends StatelessWidget {
  const CardActions({
    required this.color,
    required this.children,
    this.offset = const Offset(0, -6),
    super.key,
  });

  final Color color;
  final List<Widget> children;

  /// Moves the row against the title, [Offset.zero] next to a smaller text
  /// the row is centered on.
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: IconButtonTheme(
        data: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: color,
            iconSize: 19,
            padding: EdgeInsets.zero,
            minimumSize: const Size(30, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}
