import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/service/generator/generator_models.dart';
import 'package:stelaris/api/state/factory/build/build_vm_state.dart';
import 'package:stelaris/api/state/generator_state.dart';
import 'package:stelaris/feature/build/parts/generator_parts.dart';
import 'package:stelaris/feature/build/publish/publish_outcome.dart';
import 'package:stelaris/feature/build/publish/version_proposal.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// "Publish": proposes the next version from the published ones and
/// publishes it on the chosen channel after a confirmation.
class PublishTab extends StatelessWidget {
  const PublishTab({
    required this.vm,
    required this.onChannel,
    required this.onBump,
    required this.onPublish,
    required this.onReloadVersions,
    super.key,
  });

  final BuildViewModel vm;
  final ValueChanged<ReleaseChannel> onChannel;
  final ValueChanged<BumpPart> onBump;

  /// Confirms and publishes the proposed version.
  final VoidCallback onPublish;
  final VoidCallback onReloadVersions;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final GeneratorState generator = vm.generator;

    return GeneratorSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.generator_publish_description),
          const SizedBox(height: 16),
          if (vm.usableProject == null)
            GeneratorNote(l10n.generator_no_project)
          else ...[
            Wrap(
              spacing: 16,
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
                  onSelectionChanged: (selected) => onChannel(selected.first),
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
            const SizedBox(height: 20),
            _proposal(context),
            ..._outcome(context),
          ],
        ],
      ),
    );
  }

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
    final VersionProposal? proposal = vm.proposal;
    return switch (proposal) {
      null => GeneratorLoading(l10n.generator_publish_versions_loading),
      UnreadableVersion(:final raw) => GeneratorNote(
        l10n.generator_publish_unreadable(raw),
        icon: Icons.warning_amber_rounded,
      ),
      ProposedVersion(:final version) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.generator_publish_version(version),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
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

  List<Widget> _outcome(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final RequestState<PublishResult> publish = vm.generator.publish;
    final PublishResult? result = publish.isDone ? publish.value : null;
    final GeneratorFailure? failure = publish.failure;
    final Widget? view = switch ((result, failure?.kind)) {
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
    return [
      if (view != null) ...[const SizedBox(height: 20), view],
    ];
  }
}
