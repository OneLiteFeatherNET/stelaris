import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/service/generator/generator_models.dart';
import 'package:stelaris/api/state/factory/build/build_vm_state.dart';
import 'package:stelaris/api/state/generator_state.dart';
import 'package:stelaris/feature/build/parts/generator_parts.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// "Published versions": what the project has in the releases and snapshots
/// repositories, newest first, each with a local build download and its
/// Gradle line.
class PublishedVersionsTab extends StatelessWidget {
  const PublishedVersionsTab({
    required this.vm,
    required this.onReload,
    required this.onDownload,
    super.key,
  });

  final BuildViewModel vm;
  final VoidCallback onReload;
  final ValueChanged<String> onDownload;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return GeneratorSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.generator_versions_description),
          const SizedBox(height: 16),
          ..._content(context),
        ],
      ),
    );
  }

  List<Widget> _content(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    if (vm.usableProject == null) {
      return [GeneratorNote(l10n.generator_no_project)];
    }
    final RequestState<List<PublishedVersion>> versions = vm.generator.versions;
    final GeneratorFailure? failure = versions.failure;
    if (failure != null) {
      return [
        GeneratorError(
          title: failure.kind == GeneratorFailureKind.unavailable
              ? l10n.generator_versions_unavailable
              : l10n.generator_versions_failed,
          failure: failure,
          onRetry: onReload,
        ),
      ];
    }
    final List<PublishedVersion>? list = versions.value;
    if (list == null) {
      return [GeneratorLoading(l10n.generator_publish_versions_loading)];
    }
    if (list.isEmpty) {
      return [
        GeneratorNote(
          l10n.generator_versions_empty,
          icon: Icons.inventory_2_outlined,
        ),
      ];
    }
    final GeneratorFailure? downloadFailure =
        vm.generator.versionDownloadFailure;
    return [
      if (versions.isLoading) const LinearProgressIndicator(),
      if (downloadFailure != null) ...[
        GeneratorError(
          title: l10n.generator_download_failed,
          failure: downloadFailure,
        ),
        const SizedBox(height: 8),
      ],
      for (final version in list)
        _VersionRow(
          version: version,
          downloading: vm.generator.downloadingVersion == version.version,
          canDownload: vm.generator.downloadingVersion == null,
          onDownload: () => onDownload(version.version),
        ),
    ];
  }
}

class _VersionRow extends StatelessWidget {
  const _VersionRow({
    required this.version,
    required this.downloading,
    required this.canDownload,
    required this.onDownload,
  });

  final PublishedVersion version;
  final bool downloading;
  final bool canDownload;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final TextStyle? muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(version.version, style: theme.textTheme.titleMedium),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                        version.channel == ReleaseChannel.release
                            ? l10n.generator_channel_release
                            : l10n.generator_channel_snapshot,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                SelectableText(version.coordinates),
                Text(version.repositoryUrl, style: muted),
              ],
            ),
          ),
          IconButton(
            onPressed: canDownload ? onDownload : null,
            tooltip: l10n.generator_versions_download(version.version),
            icon: downloading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
          ),
          IconButton(
            onPressed: () =>
                copyToClipboard(context, gradleLineFor(version.coordinates)),
            tooltip: l10n.generator_versions_copy,
            icon: const Icon(Icons.copy),
          ),
        ],
      ),
    );
  }
}
