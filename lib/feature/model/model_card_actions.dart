import 'package:flutter/material.dart';

/// A row of icon-button actions (delete, and more to come) shown in a
/// [ModelGridCard]'s header. Each child wraps a plain IconButton. Content
/// below the title (e.g. a key badge) means the header can be taller than
/// one line, so the row is top-aligned against it rather than centered
/// against the whole block. 30x30 keeps each button's box close to
/// titleMedium's line-box height (~24px), but Text's font leading and
/// IconButton's own centering don't share the same top inset, so a small
/// manual offset closes the remaining gap between the title's glyphs and
/// the icons.
class ModelCardActions extends StatelessWidget {
  const ModelCardActions({
    required this.color,
    required this.children,
    super.key,
  });

  final Color color;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -6),
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
