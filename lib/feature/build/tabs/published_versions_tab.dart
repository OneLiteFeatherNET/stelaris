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
/// repositories, newest first, as a grid of cards that fills a wide screen.
/// Each card downloads its local build and copies its Gradle line.
class PublishedVersionsTab extends StatelessWidget {
  const PublishedVersionsTab({
    required this.vm,
    required this.onReload,
    required this.onDownload,
    super.key,
  });

  /// How many cards stand in for the list while it loads.
  static const int _skeletonCards = 3;

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
    final String? downloading = vm.generator.downloadingVersion;
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
              _CardGrid(
                children: List.filled(
                  _skeletonCards,
                  const PublishedVersionCardSkeleton(),
                ),
              )
            else ...[
              if (downloadFailure != null)
                GeneratorError(
                  title: l10n.generator_download_failed,
                  failure: downloadFailure,
                ),
              _CardGrid(
                children: [
                  for (final version in list)
                    PublishedVersionCard(
                      version: version,
                      downloading: downloading == version.version,
                      onDownload: downloading == null
                          ? () => onDownload(version.version)
                          : null,
                    ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Cards as many to a row as fit, all as wide.
class _CardGrid extends StatelessWidget {
  const _CardGrid({required this.children});

  /// The narrowest a card gets before a row holds one card fewer.
  static const double _minCardWidth = 340;
  static const double _spacing = 12;
  static const int _maxColumns = 6;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int columns = ((width + _spacing) / (_minCardWidth + _spacing))
            .floor()
            .clamp(1, _maxColumns);
        final double cardWidth = ((width - _spacing * (columns - 1)) / columns)
            .floorToDouble();
        return Wrap(
          spacing: _spacing,
          runSpacing: _spacing,
          children: [
            for (final child in children)
              SizedBox(width: cardWidth, child: child),
          ],
        );
      },
    );
  }
}

/// One published version: number, channel, coordinates and repository, with
/// the download of its local build and a copy of its Gradle line. Outlined,
/// like the value cards of a detail page.
class PublishedVersionCard extends StatelessWidget {
  const PublishedVersionCard({
    required this.version,
    required this.onDownload,
    this.downloading = false,
    super.key,
  });

  final PublishedVersion version;

  /// Null disables the download, e.g. while another one runs.
  final VoidCallback? onDownload;
  final bool downloading;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final TextStyle? muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final bool release = version.channel == ReleaseChannel.release;
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          version.version,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
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
                  const SizedBox(height: 6),
                  Text(
                    version.coordinates,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    version.repositoryUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: muted,
                  ),
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
      ),
    );
  }
}

/// Stands in for a [PublishedVersionCard] while the versions load.
class PublishedVersionCardSkeleton extends StatelessWidget {
  const PublishedVersionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SkeletonBar(widthFactor: 0.35, height: 16),
            SizedBox(height: 10),
            SkeletonBar(widthFactor: 0.8, height: 12),
            SizedBox(height: 6),
            SkeletonBar(widthFactor: 0.6, height: 10),
          ],
        ),
      ),
    );
  }
}
