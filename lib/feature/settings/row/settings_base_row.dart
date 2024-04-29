import 'package:flutter/material.dart';
import 'package:stelaris_ui/util/constants.dart';

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
    super.key,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const Divider(thickness: 1),
        heightTen,
        child,
      ],
    );
  }
}
