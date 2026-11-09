import 'package:stelaris/api/service/generator/generator_models.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The requests of the generator page against the vulpes-generator.
///
/// Every endpoint is keyed by the project id. The [Project] is passed whole
/// so an implementation can also name files after the project key. Every
/// failure is thrown as a [GeneratorApiException].
abstract interface class GeneratorApi {
  /// The branches of vulpes-base.
  Future<List<String>> branches();

  /// The current snapshot of [project] as a local build zip, compiled
  /// against [baseBranch].
  Future<LocalBuildFile> localBuild(Project project, String baseBranch);

  /// Publishes [version] of [project], compiled against [baseBranch].
  Future<PublishResult> publish(
    Project project,
    String version,
    String baseBranch,
  );

  /// The versions of [project] in the releases and snapshots repositories.
  Future<List<PublishedVersion>> publishedVersions(Project project);

  /// The local build zip of the published [version] of [project].
  Future<LocalBuildFile> publishedVersionBuild(Project project, String version);
}
