import 'package:material_ui/material_ui.dart';

/// The muted heading above a section of cards, as on a detail page. An
/// optional [trailing] widget, e.g. a reset button, sits at its right end.
class EditSectionHeading extends StatelessWidget {
  const EditSectionHeading({required this.title, this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heading = Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
    final trailing = this.trailing;
    if (trailing == null) return heading;
    return Row(
      children: [
        Expanded(child: heading),
        trailing,
      ],
    );
  }
}
