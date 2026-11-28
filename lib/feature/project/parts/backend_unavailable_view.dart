import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Shown in place of the project selection when the projects could not be
/// loaded, so nobody is left on a page that offers to create a project the
/// server can't take.
class BackendUnavailableView extends StatelessWidget {
  const BackendUnavailableView({
    required this.onRetry,
    this.isRetrying = false,
    super.key,
  });

  /// Loads the projects again.
  final VoidCallback onRetry;

  /// Whether a retry is under way, which disables the button.
  final bool isRetrying;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_outlined, size: 64, color: colorScheme.outline),
          const SizedBox(height: 24),
          Text(
            context.l10n.project_selection_unavailable_title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.project_selection_unavailable_message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: isRetrying ? null : onRetry,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            // Same size as the icon, so the button doesn't change its width.
            icon: isRetrying
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: Text(context.l10n.project_selection_unavailable_retry),
          ),
        ],
      ),
    );
  }
}
