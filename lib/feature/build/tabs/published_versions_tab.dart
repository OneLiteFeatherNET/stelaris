import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/service/generator/generator_models.dart';
import 'package:stelaris/api/state/factory/build/build_vm_state.dart';
import 'package:stelaris/api/state/generator_state.dart';
import 'package:stelaris/feature/base/chips/info_chip.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/feature/base/skeleton_bar.dart';
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

  /// How many rows stand in for the list while it loads.
  static const int _skeletonRows = 3;

  final BuildViewModel vm;
  final VoidCallback onReload;
  final ValueChanged<String> onDownload;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final RequestState<List<PublishedVersion>> versions = vm.generator.versions;
    final List<PublishedVersion>? list = versions.value;

    if (list != null && list.isEmpty && !versions.isFailed) {
      return EmptyDataWidget.full(
        header: l10n.generator_versions_empty,
        subHeader: l10n.generator_versions_empty_hint,
        icon: Icons.inventory_2_outlined,
      );
    }

    final GeneratorFailure? failure = versions.failure;
    final GeneratorFailure? downloadFailure =
        vm.generator.versionDownloadFailure;
    return GeneratorTabBody(
      children: [
        GeneratorSection(
          title: l10n.generator_versions_title,
          children: [
            GeneratorText(l10n.generator_versions_description),
            if (failure != null)
              GeneratorError(
                title: failure.kind == GeneratorFailureKind.unavailable
                    ? l10n.generator_versions_unavailable
                    : l10n.generator_versions_failed,
                failure: failure,
                onRetry: onReload,
              )
            else if (list == null)
              const _SkeletonList(rows: _skeletonRows)
            else ...[
              if (downloadFailure != null)
                GeneratorError(
                  title: l10n.generator_download_failed,
                  failure: downloadFailure,
                ),
              _VersionList(
                versions: list,
                downloading: vm.generator.downloadingVersion,
                onDownload: onDownload,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _VersionList extends StatelessWidget {
  const _VersionList({
    required this.versions,
    required this.downloading,
    required this.onDownload,
  });

  final List<PublishedVersion> versions;

  /// The version being downloaded; all downloads wait for it.
  final String? downloading;
  final ValueChanged<String> onDownload;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, version) in versions.indexed) ...[
          if (index > 0) const Divider(height: 1),
          _VersionRow(
            version: version,
            downloading: downloading == version.version,
            onDownload: downloading == null
                ? () => onDownload(version.version)
                : null,
          ),
        ],
      ],
    );
  }
}

class _VersionRow extends StatelessWidget {
  const _VersionRow({
    required this.version,
    required this.downloading,
    required this.onDownload,
  });

  final PublishedVersion version;
  final bool downloading;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final TextStyle? muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final bool release = version.channel == ReleaseChannel.release;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      version.version,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InfoChip(
                      icon: release
                          ? Icons.new_releases_outlined
                          : Icons.science_outlined,
                      text: release
                          ? l10n.generator_channel_release
                          : l10n.generator_channel_snapshot,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SelectableText(
                  version.coordinates,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
                Text(version.repositoryUrl, style: muted),
              ],
            ),
          ),
          IconButton(
            onPressed: onDownload,
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

/// Stands in for the list while it loads, in the shape of its rows.
class _SkeletonList extends StatelessWidget {
  const _SkeletonList({required this.rows});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < rows; i++)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                SkeletonBar(widthFactor: 0.2, height: 16),
                SizedBox(height: 8),
                SkeletonBar(widthFactor: 0.5, height: 12),
                SizedBox(height: 6),
                SkeletonBar(widthFactor: 0.4, height: 10),
              ],
            ),
          ),
      ],
    );
  }
}
