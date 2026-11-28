import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/l10n_ext.dart';

class ProjectSelectionHeader extends StatelessWidget {
  const ProjectSelectionHeader({
    this.onRefresh,
    this.isRefreshing = false,
    super.key,
  });

  /// Loads the projects again, null hides the refresh button.
  final VoidCallback? onRefresh;

  /// Whether a refresh is under way, which disables the button.
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Padded on both sides, so a long title stays centered and clear of
        // the button.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Text(
            context.l10n.project_selection_title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (onRefresh != null)
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: context.l10n.project_selection_refresh_tooltip,
              onPressed: isRefreshing ? null : onRefresh,
              // Same size as the icon, so the button doesn't jump.
              icon: isRefreshing
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
            ),
          ),
      ],
    );
  }
}
