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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GeneratorNote(
          l10n.generator_publish_success(version),
          icon: Icons.check_circle_outline,
          color: theme.colorScheme.primary,
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

/// One value of the result, labelled as on an edit card, with a copy
/// button when it is worth copying.
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          if (copy != null)
            IconButton(
              onPressed: () => copyToClipboard(context, copy),
              icon: const Icon(Icons.copy),
              tooltip: tooltip,
            ),
        ],
      ),
    );
  }
}

/// A publish the service refused, most often because the code does not
/// compile: every compiler error it returned, as source is shown elsewhere.
class PublishDiagnosticsView extends StatelessWidget {
  const PublishDiagnosticsView({required this.failure, super.key});

  final GeneratorFailure failure;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final AppLocalizations l10n = context.l10n;
    const TextStyle mono = TextStyle(fontFamily: 'monospace');
    final String? message = failure.message;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GeneratorNote(
          l10n.generator_publish_rejected,
          icon: Icons.error_outline,
          color: colors.error,
        ),
        if (failure.diagnostics.isEmpty && message != null) ...[
          const SizedBox(height: 8),
          GeneratorText(message),
        ],
        if (failure.diagnostics.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card.filled(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            color: colors.surfaceContainerHighest,
            shape: AppShapes.rounded(AppShapes.small),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: SelectableText.rich(
                  TextSpan(
                    style: mono,
                    children: [
                      for (final (index, diagnostic)
                          in failure.diagnostics.indexed) ...[
                        if (index > 0) const TextSpan(text: '\n'),
                        if (diagnostic.location != null)
                          TextSpan(
                            text: '${diagnostic.location}: ',
                            style: TextStyle(color: colors.error),
                          ),
                        TextSpan(text: diagnostic.message),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        if (failure.truncated) ...[
          const SizedBox(height: 8),
          GeneratorText(l10n.generator_publish_truncated),
        ],
      ],
    );
  }
}
