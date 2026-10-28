import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/app_shapes.dart';

/// A section of a detail page on its own filled surface, so the sections read
/// apart from each other. Its [child] is inset by 16. The surface is one step
/// above the page's background, without elevation or outline.
class EditSectionCard extends StatelessWidget {
  const EditSectionCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: AppShapes.rounded(AppShapes.medium),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}
