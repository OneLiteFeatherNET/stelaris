import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/service/generator/generator_models.dart';
import 'package:stelaris/api/state/factory/build/build_vm_state.dart';
import 'package:stelaris/api/state/generator_state.dart';
import 'package:stelaris/feature/base/edit_card/edit_card.dart';
import 'package:stelaris/feature/build/parts/branch_selector.dart';
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
    required this.onCustomVersion,
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

  /// Stores the version typed under Custom.
  final ValueChanged<String> onCustomVersion;

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
              spacing: 24,
              children: [
                GeneratorText(l10n.generator_publish_description),
                // The channel and the raise on one line while there is room.
                Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    GeneratorLabeled(
                      label: l10n.generator_channel_label,
                      child: SegmentedButton<ReleaseChannel>(
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
                    ),
                    GeneratorLabeled(
                      label: l10n.generator_bump_label,
                      child: SegmentedButton<BumpPart>(
                        showSelectedIcon: false,
                        segments: [
                          if (vm.generator.channel == ReleaseChannel.snapshot)
                            ButtonSegment(
                              value: BumpPart.current,
                              label: Text(l10n.generator_bump_current),
                              enabled:
                                  vm.latestPublished(ReleaseChannel.snapshot) !=
                                  null,
                            ),
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
                          ButtonSegment(
                            value: BumpPart.custom,
                            label: Text(l10n.generator_bump_custom),
                          ),
                        ],
                        selected: {generator.bump},
                        onSelectionChanged: (selected) =>
                            onBump(selected.first),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: BranchSelector.maxWidth, child: branchSelector),
                _proposal(context),
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

  /// The proposed version above its publish button, or why there is none.
  Widget _proposal(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final RequestState<List<PublishedVersion>> versions = vm.generator.versions;
    final GeneratorFailure? failure = versions.failure;
    if (failure != null) {
      return GeneratorError(
        title: l10n.generator_publish_versions_failed,
        failure: failure,
        onRetry: onReloadVersions,
      );
    }
    if (vm.generator.bump == BumpPart.custom) return _custom(context);
    return switch (vm.proposal) {
      null => GeneratorLoading(l10n.generator_publish_versions_loading),
      UnreadableVersion(:final raw) => GeneratorNote(
        l10n.generator_publish_unreadable(raw),
        icon: Icons.warning_amber_rounded,
        color: Theme.of(context).colorScheme.error,
      ),
      NoSnapshot() => GeneratorNote(l10n.generator_publish_no_snapshot),
      ProposedVersion(:final version) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          SizedBox(
            width: _cardWidth,
            child: EditCard(
              icon: vm.generator.channel == ReleaseChannel.release
                  ? Icons.new_releases_outlined
                  : Icons.science_outlined,
              label: vm.generator.channel == ReleaseChannel.release
                  ? l10n.generator_channel_release
                  : l10n.generator_channel_snapshot,
              value: version,
              footer: _footer(l10n, version),
            ),
          ),
          GeneratorActionButton(
            icon: Icons.publish,
            label: l10n.generator_publish_button(version),
            busy: vm.generator.publish.isLoading,
            onPressed: vm.publishableVersion == null ? null : onPublish,
          ),
        ],
      ),
    };
  }

  /// What the proposal card says about [version]: the release it raises, or
  /// the snapshot it republishes.
  String _footer(AppLocalizations l10n, String version) {
    if (vm.generator.bump == BumpPart.current) {
      return l10n.generator_publish_republish(version);
    }
    return switch (vm.latestPublishedRelease) {
      final String latest => l10n.generator_publish_latest(latest),
      null => l10n.generator_publish_first,
    };
  }

  /// The typed version above its publish button. A snapshot is published
  /// as `X.Y.Z-SNAPSHOT`, so the field shows the suffix it adds.
  Widget _custom(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final GeneratorState generator = vm.generator;
    final String? version = vm.customPublishVersion;
    final String raw = generator.customVersion ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        SizedBox(
          width: _cardWidth,
          child: TextFormField(
            initialValue: generator.customVersion,
            decoration: InputDecoration(
              labelText: l10n.generator_custom_label,
              hintText: l10n.generator_custom_hint,
              errorMaxLines: 2,
              suffixText: generator.channel == ReleaseChannel.snapshot
                  ? '-SNAPSHOT'
                  : null,
              errorText: switch (vm.customError) {
                CustomVersionError.malformed => l10n.generator_custom_malformed,
                CustomVersionError.published => l10n.generator_custom_published(
                  raw,
                ),
                null => null,
              },
            ),
            onChanged: onCustomVersion,
          ),
        ),
        GeneratorActionButton(
          icon: Icons.publish,
          label: version == null
              ? l10n.generator_publish_custom_button
              : l10n.generator_publish_button(version),
          busy: generator.publish.isLoading,
          onPressed: vm.publishableVersion == null ? null : onPublish,
        ),
      ],
    );
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
