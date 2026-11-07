import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/service/generator/generator_models.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/generator_state.dart';
import 'package:stelaris/feature/build/generator_page.dart';
import 'package:stelaris/feature/build/publish/version_proposal.dart';
import 'package:stelaris_models/stelaris_models.dart';

class BuildStateFactory
    extends VmFactory<AppState, GeneratorPage, BuildViewModel> {
  BuildStateFactory();

  @override
  BuildViewModel fromStore() => BuildViewModel(
    project: state.selectedProject,
    generator: state.generator,
  );
}

/// Why the typed custom version cannot be published.
enum CustomVersionError {
  /// Not `X.Y.Z`.
  malformed,

  /// A release that is already published; a release is final.
  published,
}

class BuildViewModel extends Vm {
  BuildViewModel({required this.project, required this.generator})
    : super(equals: [project, generator]);

  final Project? project;
  final GeneratorState generator;

  /// The selected project, when the generator can address it.
  Project? get usableProject {
    final Project? project = this.project;
    final String? id = project?.id;
    return id == null || id.isEmpty ? null : project;
  }

  /// The branch to build against, when the branch list offers one.
  String? get baseBranch =>
      generator.branches.isDone ? generator.selectedBranch : null;

  /// The project and branch "Test locally" and "Publish" need.
  bool get canBuild => usableProject != null && baseBranch != null;

  /// The next version, once the published versions are known. Null under
  /// Custom, which publishes the typed version instead.
  VersionProposal? get proposal {
    final List<PublishedVersion>? versions = generator.versions.value;
    if (!generator.versions.isDone || versions == null) return null;
    if (generator.bump == BumpPart.custom) return null;
    return proposeVersion(
      channel: generator.channel,
      bump: generator.bump,
      published: versions.map((it) => it.version),
    );
  }

  /// The newest published release, the base of [proposal].
  String? get latestPublishedRelease => latestRelease(
    generator.versions.value?.map((it) => it.version) ?? const [],
  );

  /// The newest published version of [channel], with its coordinates.
  PublishedVersion? latestPublished(ReleaseChannel channel) {
    final List<PublishedVersion> versions =
        generator.versions.value ?? const [];
    final Iterable<String> names = versions.map((it) => it.version);
    final String? latest = channel == ReleaseChannel.release
        ? latestRelease(names)
        : latestSnapshot(names);
    return versions.where((it) => it.version == latest).firstOrNull;
  }

  /// The typed version as it would be published, or null while it is not
  /// `X.Y.Z`, or is a release that is already published.
  String? get customPublishVersion {
    final String? version = customVersion(
      generator.customVersion ?? '',
      generator.channel,
    );
    if (version == null) return null;
    if (generator.channel == ReleaseChannel.release && isPublished(version)) {
      return null;
    }
    return version;
  }

  /// Why the typed custom version cannot be published; null when it can, or
  /// when Custom is not selected.
  CustomVersionError? get customError {
    if (generator.bump != BumpPart.custom) return null;
    final String raw = generator.customVersion ?? '';
    if (customVersion(raw, generator.channel) == null) {
      return CustomVersionError.malformed;
    }
    if (customPublishVersion == null) return CustomVersionError.published;
    return null;
  }

  /// The version publish sends, when one can be sent now.
  String? get publishableVersion {
    if (!canBuild || generator.publish.isLoading) return null;
    if (generator.bump == BumpPart.custom) return customPublishVersion;
    final VersionProposal? proposal = this.proposal;
    return proposal is ProposedVersion ? proposal.version : null;
  }

  /// Whether [version] is already published, so publishing replaces it.
  bool isPublished(String version) =>
      generator.versions.value?.any((it) => it.version == version) ?? false;
}
