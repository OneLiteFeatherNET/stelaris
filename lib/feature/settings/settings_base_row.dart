import 'package:flutter/material.dart';
import 'package:stelaris/util/constants.dart';

/// The [SettingsBaseRow] is a widget implementation which defines how the structure of a settings row should look like.
/// In detail each row consists a title, a divider and a child widget.
/// The title is a string which is displayed at the top of the row.
/// The divider is a horizontal line which separates the title from the child widget.
/// The child widget is the actual content of the row.
/// What the child widget is, depends on the context usage.
class SettingsBaseRow extends StatelessWidget {
  const SettingsBaseRow({
    required this.title,
    required this.child,
    this.semanticsLabel,
    super.key,
  });

  final String title;
  final Widget child;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: semanticsLabel ?? title,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: theme.colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            const Divider(thickness: 1),
            heightTen,
            child,
          ],
        ),
      ),
    );
  }
}
