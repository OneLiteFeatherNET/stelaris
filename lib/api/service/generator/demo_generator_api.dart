import 'dart:typed_data';

import 'package:stelaris/api/service/generator/generator_api.dart';
import 'package:stelaris/api/service/generator/generator_models.dart';
import 'package:stelaris/feature/build/publish/version_proposal.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// A [GeneratorApi] that simulates the generator in memory, for as long as
/// the service has no release endpoints. Used unless `config.json` sets
/// `"generatorDemo": false`; the page then says that its data is simulated.
///
/// Every project starts with the same few versions. A publish adds to them
/// and refuses an existing release version as the service would, and a
/// download saves an empty zip.
class DemoGeneratorApi implements GeneratorApi {
  DemoGeneratorApi({this.delay = const Duration(milliseconds: 600)});

  /// How long each simulated request takes.
  final Duration delay;

  static const String group = 'net.onelitefeather.vulpes.content';
  static const String releasesUrl =
      'https://repo.onelitefeather.dev/onelitefeather-releases';
  static const String snapshotsUrl =
      'https://repo.onelitefeather.dev/onelitefeather-snapshots';

  static const List<String> _seed = [
    '0.1.0',
    '0.2.0',
    '0.2.1',
    '0.2.12',
    '0.3.0-SNAPSHOT',
  ];

  /// The 22 bytes of a zip without entries.
  static final Uint8List _emptyZip = Uint8List.fromList([
    0x50, 0x4b, 0x05, 0x06, //
    ...List<int>.filled(18, 0),
  ]);

  final Map<String, List<String>> _published = {};

  List<String> _versionsOf(Project project) =>
      _published.putIfAbsent(project.id ?? project.key, () => [..._seed]);

  Future<void> _wait() => Future<void>.delayed(delay);

  @override
  Future<List<String>> branches() async {
    await _wait();
    return const ['develop', 'main', 'feature/blockstates'];
  }

  @override
  Future<LocalBuildFile> localBuild(Project project, String baseBranch) async {
    await _wait();
    return LocalBuildFile(_emptyZip, '${project.key}-local.zip');
  }

  @override
  Future<PublishResult> publish(
    Project project,
    String version,
    String baseBranch,
  ) async {
    await _wait();
    final List<String> versions = _versionsOf(project);
    final bool snapshot = version.endsWith('-SNAPSHOT');
    if (!snapshot && versions.contains(version)) {
      throw GeneratorApiException(
        GeneratorFailure(
          GeneratorFailureKind.versionExists,
          statusCode: 409,
          message: 'Version $version is already published.',
        ),
      );
    }
    if (!versions.contains(version)) versions.add(version);
    return PublishResult(
      coordinates: '$group:${project.key}:$version',
      revision: _hex('${project.key}:$version:revision', 64),
      base: BaseCommit(
        repository: 'OneLiteFeatherNET/vulpes-base',
        branch: baseBranch,
        commit: _hex(baseBranch, 40),
      ),
      repositoryUrl: snapshot ? snapshotsUrl : releasesUrl,
    );
  }

  @override
  Future<List<PublishedVersion>> publishedVersions(Project project) async {
    await _wait();
    return newestFirst([
      for (final version in _versionsOf(project))
        PublishedVersion(
          version: version,
          channel: version.endsWith('-SNAPSHOT')
              ? ReleaseChannel.snapshot
              : ReleaseChannel.release,
          coordinates: '$group:${project.key}:$version',
          repositoryUrl: version.endsWith('-SNAPSHOT')
              ? snapshotsUrl
              : releasesUrl,
        ),
    ]);
  }

  @override
  Future<LocalBuildFile> publishedVersionBuild(
    Project project,
    String version,
  ) async {
    await _wait();
    return LocalBuildFile(_emptyZip, '${project.key}-$version.zip');
  }

  /// A stable hex string of [length] derived from [seed], so the simulated
  /// commit and revision look real and stay the same between publishes.
  static String _hex(String seed, int length) {
    final buffer = StringBuffer();
    var hash = seed.hashCode;
    while (buffer.length < length) {
      hash = (hash * 31 + 17) & 0x7fffffff;
      buffer.write(hash.toRadixString(16).padLeft(8, '0'));
    }
    return buffer.toString().substring(0, length);
  }
}
