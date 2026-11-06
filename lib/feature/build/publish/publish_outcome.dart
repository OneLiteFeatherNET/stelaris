import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/service/generator/generator_models.dart';
import 'package:stelaris/feature/build/parts/generator_parts.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// How many characters of the base commit are shown; the copy holds all.
const int shortCommitLength = 10;

/// Asks before anything is published. Says that an already published
/// snapshot is replaced when [replaces].
Future<bool> confirmPublish(
  BuildContext context, {
  required String version,
  required ReleaseChannel channel,
  required String branch,
  required bool replaces,
}) async {
  final AppLocalizations l10n = context.l10n;
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.generator_confirm_title(version)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.generator_confirm_body(
                version,
                channel == ReleaseChannel.release
                    ? l10n.generator_channel_release
                    : l10n.generator_channel_snapshot,
                branch,
              ),
            ),
            if (replaces) ...[
              const SizedBox(height: 12),
              GeneratorNote(
                l10n.generator_confirm_replace(version),
                icon: Icons.warning_amber_rounded,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.button_cancel),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.publish),
          label: Text(l10n.generator_publish_button(version)),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// A successful publish: where the version went and how to depend on it.
class PublishResultView extends StatelessWidget {
  const PublishResultView({required this.result, super.key});

  final PublishResult result;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final String version = result.coordinates.split(':').last;
    final String commit = result.base.commit;
    final String shortCommit = commit.length > shortCommitLength
        ? commit.substring(0, shortCommitLength)
        : commit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              l10n.generator_publish_success(version),
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ResultRow(
          label: l10n.generator_result_coordinates,
          value: result.coordinates,
          copy: result.coordinates,
          tooltip: l10n.generator_copy,
        ),
        _ResultRow(
          label: l10n.generator_result_revision,
          value: result.revision,
        ),
        _ResultRow(
          label: l10n.generator_result_base,
          value: '${result.base.branch} @ $shortCommit',
          copy: commit,
          tooltip: l10n.generator_copy_commit,
        ),
        _ResultRow(
          label: l10n.generator_result_gradle,
          value: result.gradleLine,
          copy: result.gradleLine,
          tooltip: l10n.generator_copy,
        ),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    this.copy,
    this.tooltip,
  });

  final String label;
  final String value;
  final String? copy;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? copy = this.copy;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: copy == null
                ? null
                : IconButton(
                    onPressed: () => copyToClipboard(context, copy),
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: tooltip,
                  ),
          ),
        ],
      ),
    );
  }
}

/// A publish the service refused because the code does not compile: every
/// compiler error it returned.
class PublishDiagnosticsView extends StatelessWidget {
  const PublishDiagnosticsView({required this.failure, super.key});

  final GeneratorFailure failure;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final AppLocalizations l10n = context.l10n;
    final TextStyle? mono = theme.textTheme.bodySmall?.copyWith(
      fontFamily: 'monospace',
      color: colors.onErrorContainer,
    );
    final String? message = failure.message;

    return Material(
      color: colors.errorContainer,
      borderRadius: BorderRadius.circular(AppShapes.medium),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: colors.onErrorContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.generator_publish_rejected,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (failure.diagnostics.isEmpty && message != null) ...[
              const SizedBox(height: 8),
              Text(message, style: mono),
            ],
            if (failure.diagnostics.isNotEmpty) ...[
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final diagnostic in failure.diagnostics)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: SelectableText(
                          [
                            if (diagnostic.location != null)
                              diagnostic.location!,
                            diagnostic.message,
                          ].join(': '),
                          style: mono,
                        ),
                      ),
                  ],
                ),
              ),
            ],
            if (failure.truncated) ...[
              const SizedBox(height: 8),
              Text(
                l10n.generator_publish_truncated,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onErrorContainer,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
