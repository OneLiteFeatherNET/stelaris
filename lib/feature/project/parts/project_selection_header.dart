import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/l10n_ext.dart';

class ProjectSelectionHeader extends StatelessWidget {
  const ProjectSelectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      context.l10n.project_selection_title,
      textAlign: TextAlign.center,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
