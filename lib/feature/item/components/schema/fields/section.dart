import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/constants.dart';

/// A framed group of fields with a [title], used for lists and nested objects.
class SchemaSection extends StatelessWidget {
  const SchemaSection({
    required this.title,
    required this.children,
    this.trailing,
    super.key,
  });

  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 4, 12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
              ?trailing,
            ],
          ),
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
