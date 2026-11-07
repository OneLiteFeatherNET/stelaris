import 'package:async_redux/async_redux.dart';
import 'package:flutter/foundation.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/service/generate_api.dart';
import 'package:stelaris/api/service/generator/generator_models.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/generator_state.dart';
import 'package:stelaris/feature/build/download/download_helper.dart'
    as download;
import 'package:stelaris/feature/build/publish/version_proposal.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The branch the page selects when the list has it.
const String defaultBaseBranch = 'develop';

/// Runs [request] and turns whatever it throws into a [GeneratorFailure], so
/// no request of the generator page fails as an unhandled exception.
Future<(T?, GeneratorFailure?)> _attempt<T>(
  Future<T> Function() request,
) async {
  try {
    return (await request(), null);
  } on GeneratorApiException catch (error) {
    return (null, error.failure);
  } catch (error) {
    // Shown as a plain failure; the raw error is for the console only.
    debugPrint('Generator request failed: $error');
    return (null, const GeneratorFailure(GeneratorFailureKind.unexpected));
  }
}

/// A generator action: reads and replaces the generator slice of the state.
abstract class _GeneratorAction extends ReduxAction<AppState> {
  _GeneratorAction({GeneratorApi? api}) : injectedApi = api;

  /// The generator a test hands in; [ApiService.generatorApi] when null.
  final GeneratorApi? injectedApi;

  GeneratorApi get api => injectedApi ?? ApiService().generatorApi;

  GeneratorState get generator => state.generator;

  AppState withGenerator(GeneratorState generator) =>
      state.copyWith(generator: generator);

  void update(GeneratorState Function(GeneratorState) change) =>
      dispatchSync(_UpdateGenerator(change));

  /// Whether the answer of a request for [project] still belongs on the page.
  bool isCurrent(Project project) => generator.projectId == project.id;
}

class _UpdateGenerator extends ReduxAction<AppState> {
  _UpdateGenerator(this.change);

  final GeneratorState Function(GeneratorState) change;

  @override
  AppState reduce() => state.copyWith(generator: change(state.generator));
}

/// Binds the project-bound requests of the page to [projectId], clearing the
/// results of another project. Does nothing for the same project.
class SyncGeneratorProjectAction extends _GeneratorAction {
  SyncGeneratorProjectAction(this.projectId);

  final String? projectId;

  @override
  AppState? reduce() {
    if (generator.projectId == projectId) return null;
    return withGenerator(generator.forProject(projectId));
  }
}

/// Loads the vulpes-base branches and keeps the selection when it is still
/// one of them; otherwise selects `develop`, or the first branch.
class LoadBranchesAction extends _GeneratorAction {
  LoadBranchesAction({super.api});

  @override
  Future<AppState?> reduce() async {
    update(
      (it) => it.copyWith(branches: RequestState.loading(it.branches.value)),
    );
    final (branches, failure) = await _attempt(api.branches);
    if (branches == null) {
      return withGenerator(
        generator.copyWith(branches: RequestState.failed(failure!)),
      );
    }
    final String? selected = generator.selectedBranch;
    final String? next = branches.contains(selected)
        ? selected
        : branches.contains(defaultBaseBranch)
        ? defaultBaseBranch
        : branches.firstOrNull;
    return withGenerator(
      generator.copyWith(
        branches: RequestState.done(branches),
        selectedBranch: () => next,
      ),
    );
  }
}

class SelectBaseBranchAction extends _GeneratorAction {
  SelectBaseBranchAction(this.branch);

  final String branch;

  @override
  AppState reduce() =>
      withGenerator(generator.copyWith(selectedBranch: () => branch));
}

class SelectReleaseChannelAction extends _GeneratorAction {
  SelectReleaseChannelAction(this.channel);

  final ReleaseChannel channel;

  @override
  AppState reduce() => withGenerator(generator.copyWith(channel: channel));
}

class SelectBumpPartAction extends _GeneratorAction {
  SelectBumpPartAction(this.bump);

  final BumpPart bump;

  /// Choosing Custom starts from the version the proposal had been, without
  /// `-SNAPSHOT`, so the field begins where the publish was heading.
  @override
  AppState reduce() {
    final bool starting = bump == BumpPart.custom && generator.bump != bump;
    return withGenerator(
      generator.copyWith(
        bump: bump,
        customVersion: starting ? _proposedRelease() : null,
      ),
    );
  }

  String _proposedRelease() {
    final List<PublishedVersion>? versions = generator.versions.value;
    if (!generator.versions.isDone || versions == null) return '';
    final VersionProposal proposal = proposeVersion(
      channel: generator.channel,
      bump: generator.bump,
      published: versions.map((it) => it.version),
    );
    return switch (proposal) {
      ProposedVersion(:final version) => releaseNumber(version),
      UnreadableVersion() => '',
    };
  }
}

/// Stores the version typed under Custom.
class SetCustomVersionAction extends _GeneratorAction {
  SetCustomVersionAction(this.version);

  final String version;

  @override
  AppState reduce() =>
      withGenerator(generator.copyWith(customVersion: version));
}

/// Loads the published versions of [project], newest first.
class LoadPublishedVersionsAction extends _GeneratorAction {
  LoadPublishedVersionsAction(this.project, {super.api});

  final Project project;

  @override
  Future<AppState?> reduce() async {
    if (!isCurrent(project)) return null;
    update(
      (it) => it.copyWith(versions: RequestState.loading(it.versions.value)),
    );
    final (versions, failure) = await _attempt(
      () => api.publishedVersions(project),
    );
    if (!isCurrent(project)) return null;
    return withGenerator(
      generator.copyWith(
        versions: versions == null
            ? RequestState.failed(failure!)
            : RequestState.done(newestFirst(versions)),
      ),
    );
  }
}

/// Downloads the local build of [project] against [baseBranch] and saves it.
class DownloadLocalBuildAction extends _GeneratorAction {
  DownloadLocalBuildAction(
    this.project,
    this.baseBranch, {
    super.api,
    download.FileSaver? saveFile,
  }) : _saveFile = saveFile ?? download.saveFile;

  final Project project;
  final String baseBranch;
  final download.FileSaver _saveFile;

  @override
  Future<AppState?> reduce() async {
    if (!isCurrent(project) || generator.localBuild.isLoading) return null;
    update((it) => it.copyWith(localBuild: const RequestState.loading()));
    final (filename, failure) = await _attempt(() async {
      final LocalBuildFile file = await api.localBuild(project, baseBranch);
      _saveFile(file.bytes, file.filename);
      return file.filename;
    });
    if (!isCurrent(project)) return null;
    return withGenerator(
      generator.copyWith(
        localBuild: filename == null
            ? RequestState.failed(failure!)
            : RequestState.done(filename),
      ),
    );
  }
}

/// Downloads the local build of the published [version] and saves it.
class DownloadPublishedVersionAction extends _GeneratorAction {
  DownloadPublishedVersionAction(
    this.project,
    this.version, {
    super.api,
    download.FileSaver? saveFile,
  }) : _saveFile = saveFile ?? download.saveFile;

  final Project project;
  final String version;
  final download.FileSaver _saveFile;

  @override
  Future<AppState?> reduce() async {
    if (!isCurrent(project) || generator.downloadingVersion != null) {
      return null;
    }
    update(
      (it) => it.copyWith(
        downloadingVersion: () => version,
        versionDownloadFailure: () => null,
      ),
    );
    final (_, failure) = await _attempt(() async {
      final LocalBuildFile file = await api.publishedVersionBuild(
        project,
        version,
      );
      _saveFile(file.bytes, file.filename);
      return true;
    });
    if (!isCurrent(project)) return null;
    return withGenerator(
      generator.copyWith(
        downloadingVersion: () => null,
        versionDownloadFailure: () => failure,
      ),
    );
  }
}

/// Publishes [version] of [project] against [baseBranch]. A success and a
/// conflict both reload the published versions, so the list shows what the
/// repository now holds.
class PublishReleaseAction extends _GeneratorAction {
  PublishReleaseAction(
    this.project,
    this.version,
    this.baseBranch, {
    super.api,
  });

  final Project project;
  final String version;
  final String baseBranch;

  @override
  Future<AppState?> reduce() async {
    if (!isCurrent(project) || generator.publish.isLoading) return null;
    update(
      (it) => it.copyWith(
        publish: const RequestState.loading(),
        publishVersion: version,
      ),
    );
    final (result, failure) = await _attempt(
      () => api.publish(project, version, baseBranch),
    );
    if (!isCurrent(project)) return null;
    if (result != null || failure?.kind == GeneratorFailureKind.versionExists) {
      dispatch(LoadPublishedVersionsAction(project, api: injectedApi));
    }
    return withGenerator(
      generator.copyWith(
        publish: result == null
            ? RequestState.failed(failure!)
            : RequestState.done(result),
      ),
    );
  }
}
