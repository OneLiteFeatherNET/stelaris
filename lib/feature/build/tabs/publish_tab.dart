import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/service/generator/generator_models.dart';
import 'package:stelaris/api/state/factory/build/build_vm_state.dart';
import 'package:stelaris/api/state/generator_state.dart';
import 'package:stelaris/feature/base/edit_card/edit_card.dart';
import 'package:stelaris/feature/build/parts/generator_parts.dart';
import 'package:stelaris/feature/build/publish/publish_outcome.dart';
import 'package:stelaris/feature/build/publish/version_proposal.dart';
import 'package:stelaris/feature/build/tabs/published_versions_tab.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// "Publish": proposes the next version from the published ones and
/// publishes it on the chosen channel after a confirmation.
class PublishTab extends StatelessWidget {
  const PublishTab({
    required this.vm,
    required this.branchSelector,
    required this.onChannel,
    required this.onBump,
    required this.onPublish,
    required this.onReloadVersions,
    required this.onDownloadVersion,
    super.key,
  });

  /// As wide as one card of an edit card grid.
  static const double _cardWidth = 320;

  final BuildViewModel vm;

  /// The shared branch field, at the top of the section.
  final Widget branchSelector;
  final ValueChanged<ReleaseChannel> onChannel;
  final ValueChanged<BumpPart> onBump;

  /// Confirms and publishes the proposed version.
  final VoidCallback onPublish;
  final VoidCallback onReloadVersions;

  /// Downloads the local build of a published version.
  final ValueChanged<String> onDownloadVersion;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final GeneratorState generator = vm.generator;
    final Widget? outcome = _outcome(context);

    return GeneratorTabBody(
      children: [
        GeneratorColumns(
          start: [
            GeneratorSection(
              title: l10n.generator_publish_title,
              children: [
                GeneratorText(l10n.generator_publish_description),
                branchSelector,
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SegmentedButton<ReleaseChannel>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: ReleaseChannel.release,
                          label: Text(l10n.generator_channel_release),
                        ),
                        ButtonSegment(
                          value: ReleaseChannel.snapshot,
                          label: Text(l10n.generator_channel_snapshot),
                        ),
                      ],
                      selected: {generator.channel},
                      onSelectionChanged: (selected) =>
                          onChannel(selected.first),
                    ),
                    SegmentedButton<BumpPart>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: BumpPart.major,
                          label: Text(l10n.generator_bump_major),
                        ),
                        ButtonSegment(
                          value: BumpPart.minor,
                          label: Text(l10n.generator_bump_minor),
                        ),
                        ButtonSegment(
                          value: BumpPart.patch,
                          label: Text(l10n.generator_bump_patch),
                        ),
                      ],
                      selected: {generator.bump},
                      onSelectionChanged: (selected) => onBump(selected.first),
                    ),
                  ],
                ),
                ..._proposal(context),
              ],
            ),
          ],
          end: [
            if (outcome != null)
              GeneratorSection(
                title: l10n.generator_publish_outcome_title,
                children: [outcome],
              ),
            GeneratorSection(
              title: l10n.generator_current_title,
              children: [
                for (final channel in ReleaseChannel.values)
                  _current(context, channel),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// The newest published version of [channel], or that there is none.
  Widget _current(BuildContext context, ReleaseChannel channel) {
    final AppLocalizations l10n = context.l10n;
    if (!vm.generator.versions.isDone) {
      return const PublishedVersionCardSkeleton();
    }
    final PublishedVersion? latest = vm.latestPublished(channel);
    if (latest == null) {
      return GeneratorNote(
        '${channel == ReleaseChannel.release ? l10n.generator_channel_release : l10n.generator_channel_snapshot}: '
        '${l10n.generator_current_none}',
      );
    }
    final String? downloading = vm.generator.downloadingVersion;
    return PublishedVersionCard(
      version: latest,
      downloading: downloading == latest.version,
      onDownload: downloading == null
          ? () => onDownloadVersion(latest.version)
          : null,
    );
  }

  List<Widget> _proposal(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final RequestState<List<PublishedVersion>> versions = vm.generator.versions;
    final GeneratorFailure? failure = versions.failure;
    if (failure != null) {
      return [
        GeneratorError(
          title: l10n.generator_publish_versions_failed,
          failure: failure,
          onRetry: onReloadVersions,
        ),
      ];
    }
    return switch (vm.proposal) {
      null => [GeneratorLoading(l10n.generator_publish_versions_loading)],
      UnreadableVersion(:final raw) => [
        GeneratorNote(
          l10n.generator_publish_unreadable(raw),
          icon: Icons.warning_amber_rounded,
          color: Theme.of(context).colorScheme.error,
        ),
      ],
      ProposedVersion(:final version) => [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: SizedBox(
            width: _cardWidth,
            child: EditCard(
              icon: vm.generator.channel == ReleaseChannel.release
                  ? Icons.new_releases_outlined
                  : Icons.science_outlined,
              label: vm.generator.channel == ReleaseChannel.release
                  ? l10n.generator_channel_release
                  : l10n.generator_channel_snapshot,
              value: version,
              footer: switch (vm.latestPublishedRelease) {
                final String latest => l10n.generator_publish_latest(latest),
                null => l10n.generator_publish_first,
              },
            ),
          ),
        ),
        GeneratorActionButton(
          icon: Icons.publish,
          label: l10n.generator_publish_button(version),
          busy: vm.generator.publish.isLoading,
          onPressed: vm.publishableVersion == null ? null : onPublish,
        ),
      ],
    };
  }

  Widget? _outcome(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final RequestState<PublishResult> publish = vm.generator.publish;
    final PublishResult? result = publish.isDone ? publish.value : null;
    final GeneratorFailure? failure = publish.failure;
    return switch ((result, failure?.kind)) {
      (final PublishResult result, _) => PublishResultView(result: result),
      (_, GeneratorFailureKind.versionExists) => GeneratorNote(
        l10n.generator_publish_conflict(vm.generator.publishVersion ?? ''),
        icon: Icons.warning_amber_rounded,
      ),
      (_, GeneratorFailureKind.rejected) => PublishDiagnosticsView(
        failure: failure!,
      ),
      (_, final GeneratorFailureKind _) => GeneratorError(
        title: l10n.generator_publish_failed,
        failure: failure!,
        onRetry: vm.publishableVersion == null ? null : onPublish,
      ),
      _ => null,
    };
  }
}
