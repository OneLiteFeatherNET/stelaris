import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/service/generator/generator_models.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The outlined frame of each block on the generator page.
class GeneratorSection extends StatelessWidget {
  const GeneratorSection({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }
}

/// Says that the page shows simulated data.
class GeneratorDemoBanner extends StatelessWidget {
  const GeneratorDemoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.tertiaryContainer,
      borderRadius: BorderRadius.circular(AppShapes.medium),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.science_outlined, color: colors.onTertiaryContainer),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                context.l10n.generator_demo_banner,
                style: TextStyle(color: colors.onTertiaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A line of muted text, for the "nothing to do here yet" states.
class GeneratorNote extends StatelessWidget {
  const GeneratorNote(this.text, {this.icon = Icons.info_outline, super.key});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// A small spinner with [text] next to it.
class GeneratorLoading extends StatelessWidget {
  const GeneratorLoading(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    );
  }
}

/// The detail lines of [failure]: what the service said, or what the kind
/// of failure means when it said nothing, and the status.
List<String> failureDetails(AppLocalizations l10n, GeneratorFailure failure) {
  final String? message = failure.message;
  return [
    if (message != null && message.trim().isNotEmpty)
      message
    else if (failure.kind == GeneratorFailureKind.network)
      l10n.generator_error_network
    else if (failure.kind == GeneratorFailureKind.unavailable)
      l10n.generator_error_unavailable,
    if (failure.statusCode != null)
      l10n.generator_error_status('${failure.statusCode}'),
  ];
}

/// A failed request: [title], the details of [failure], and a retry.
class GeneratorError extends StatelessWidget {
  const GeneratorError({
    required this.title,
    required this.failure,
    this.onRetry,
    super.key,
  });

  final String title;
  final GeneratorFailure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final List<String> details = failureDetails(context.l10n, failure);
    return Material(
      color: colors.errorContainer,
      borderRadius: BorderRadius.circular(AppShapes.medium),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colors.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  for (final line in details)
                    Text(
                      line,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onErrorContainer,
                      ),
                    ),
                ],
              ),
            ),
            if (onRetry != null)
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.generator_retry),
                style: TextButton.styleFrom(
                  foregroundColor: colors.onErrorContainer,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Copies [text] and confirms it.
Future<void> copyToClipboard(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) {
    context.showInfoSnackBar(context.l10n.generator_copied);
  }
}

/// A filled button that shows a spinner instead of its icon while [busy].
class GeneratorActionButton extends StatelessWidget {
  const GeneratorActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.busy = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: busy ? null : onPressed,
      icon: busy
          ? const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon),
      label: Text(label),
    );
  }
}
