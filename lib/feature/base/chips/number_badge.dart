import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/app_shapes.dart';

/// A number in a small round badge, e.g. the number of a lore line or the
/// length of a font line. A circle for short numbers, a pill for longer ones.
class NumberBadge extends StatelessWidget {
  const NumberBadge({
    required this.number,
    this.background,
    this.foreground,
    super.key,
  });

  final int number;

  /// Defaults to the secondary container color of the theme.
  final Color? background;

  /// Defaults to the color on the secondary container.
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Sized by its number, not by the room around it, so it stays a badge
    // wherever it sits.
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background ?? colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(AppShapes.full),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Text(
              '$number',
              style: theme.textTheme.labelMedium?.copyWith(
                color: foreground ?? colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
