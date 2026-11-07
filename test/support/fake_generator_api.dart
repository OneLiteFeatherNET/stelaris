import 'dart:async';
import 'dart:typed_data';

import 'package:stelaris/api/service/generate_api.dart';
import 'package:stelaris/api/service/generator/generator_models.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// A [GeneratorApi] that answers from fields and records every call, so no
/// test of the generator page reaches dio or the network.
///
/// Set a `*Failure` to make the request throw it. Set [hold] to keep every
/// request open until [release] is called.
class FakeGeneratorApi implements GeneratorApi {
  FakeGeneratorApi({
    this.branchList = const ['main', 'develop'],
    List<PublishedVersion>? versions,
  }) : versions = versions ?? [];

  List<String> branchList;
  List<PublishedVersion> versions;

  GeneratorFailure? branchesFailure;
  GeneratorFailure? localBuildFailure;
  GeneratorFailure? publishFailure;
  GeneratorFailure? versionsFailure;

  /// Thrown as is, for errors that are not from the generator.
  Object? rawError;

  bool hold = false;
  Completer<void> _released = Completer<void>();

  final List<String> calls = [];

  /// Lets every held request answer.
  void release() {
    hold = false;
    _released.complete();
    _released = Completer<void>();
  }

  Future<void> _answer(String call, GeneratorFailure? failure) async {
    calls.add(call);
    if (hold) await _released.future;
    final Object? raw = rawError;
    if (raw != null) throw raw;
    if (failure != null) throw GeneratorApiException(failure);
  }

  @override
  Future<List<String>> branches() async {
    await _answer('branches', branchesFailure);
    return branchList;
  }

  @override
  Future<LocalBuildFile> localBuild(Project project, String baseBranch) async {
    await _answer('localBuild ${project.id} $baseBranch', localBuildFailure);
    return LocalBuildFile(Uint8List(0), '${project.key}-local.zip');
  }

  @override
  Future<PublishResult> publish(
    Project project,
    String version,
    String baseBranch,
  ) async {
    await _answer('publish ${project.id} $version $baseBranch', publishFailure);
    return PublishResult(
      coordinates: 'net.onelitefeather.vulpes.content:${project.key}:$version',
      revision: 'f00d',
      base: BaseCommit(
        repository: 'OneLiteFeatherNET/vulpes-base',
        branch: baseBranch,
        commit: '0123456789abcdef0123456789abcdef01234567',
      ),
      repositoryUrl: 'https://repo.test/releases',
    );
  }

  @override
  Future<List<PublishedVersion>> publishedVersions(Project project) async {
    await _answer('publishedVersions ${project.id}', versionsFailure);
    return versions;
  }

  @override
  Future<LocalBuildFile> publishedVersionBuild(
    Project project,
    String version,
  ) async {
    await _answer('publishedVersionBuild ${project.id} $version', null);
    return LocalBuildFile(Uint8List(0), '${project.key}-$version.zip');
  }
}

/// A published version of `eldoria` for the fake.
PublishedVersion publishedVersion(String version) => PublishedVersion(
  version: version,
  channel: version.endsWith('-SNAPSHOT')
      ? ReleaseChannel.snapshot
      : ReleaseChannel.release,
  coordinates: 'net.onelitefeather.vulpes.content:eldoria:$version',
  repositoryUrl: version.endsWith('-SNAPSHOT')
      ? 'https://repo.test/snapshots'
      : 'https://repo.test/releases',
);
