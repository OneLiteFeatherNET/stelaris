import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/constants.dart';

/// A group of fields with a [title], used for lists and nested objects.
///
/// Grouped by a light tint instead of a border, so nested groups don't stack
/// up lines.
class SchemaSection extends StatelessWidget {
  const SchemaSection({
    required this.title,
    required this.children,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;

  /// A hint shown once under the [title], e.g. instead of repeating it below
  /// every entry.
  final String? subtitle;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = this.subtitle;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 12),
      decoration: BoxDecoration(
        // Translucent, so a nested group stands out from the one around it.
        color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          // The floating label of an outlined input needs room below the header.
          if (children.isNotEmpty) verticalSpacing10,
          ...spaced(children),
        ],
      ),
    );
  }
}

/// A muted text in place of an input, for values that can't be edited.
class SchemaHint extends StatelessWidget {
  const SchemaHint(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// The [children] with the vertical spacing of the dialog between them.
List<Widget> spaced(List<Widget> children) => [
  for (var i = 0; i < children.length; i++) ...[
    if (i > 0) verticalSpacing10,
    children[i],
  ],
];
