import 'dart:typed_data';

import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/service/generator/generator_models.dart';
import 'package:stelaris/api/state/actions/build/build_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/generator_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_generator_api.dart';

const Project _project = Project(
  id: 'p1',
  displayName: 'Eldoria',
  key: 'eldoria',
);
const Project _other = Project(id: 'p2', displayName: 'Other', key: 'other');

Store<AppState> _store({GeneratorState generator = const GeneratorState()}) =>
    Store<AppState>(
      initialState: AppState(
        selectedProject: _project,
        generator: GeneratorState(
          projectId: 'p1',
          branches: generator.branches,
          selectedBranch: generator.selectedBranch,
          versions: generator.versions,
        ),
      ),
    );

void main() {
  late FakeGeneratorApi api;

  setUp(() => api = FakeGeneratorApi());

  group('LoadBranchesAction', () {
    test('selects develop when the list has it', () async {
      final store = _store();
      api.branchList = ['main', 'develop'];

      await store.dispatchAndWait(LoadBranchesAction(api: api));

      final generator = store.state.generator;
      expect(generator.branches, const RequestState.done(['main', 'develop']));
      expect(generator.selectedBranch, 'develop');
    });

    test('keeps a selection the list still has', () async {
      final store = _store(
        generator: const GeneratorState(selectedBranch: 'release/2.x'),
      );
      api.branchList = ['develop', 'release/2.x'];

      await store.dispatchAndWait(LoadBranchesAction(api: api));

      expect(store.state.generator.selectedBranch, 'release/2.x');
    });

    test('is loading while the request runs', () async {
      final store = _store();
      api.hold = true;

      final done = store.dispatchAndWait(LoadBranchesAction(api: api));
      expect(store.state.generator.branches.isLoading, isTrue);

      api.release();
      await done;
      expect(store.state.generator.branches.isLoading, isFalse);
    });

    test('a failure is kept in the state, not thrown', () async {
      final store = _store();
      api.branchesFailure = const GeneratorFailure(
        GeneratorFailureKind.unavailable,
        statusCode: 502,
      );

      final status = await store.dispatchAndWait(LoadBranchesAction(api: api));

      expect(status.originalError, isNull);
      expect(
        store.state.generator.branches.failure?.kind,
        GeneratorFailureKind.unavailable,
      );
    });

    test('an error that is not from the generator is unexpected', () async {
      final store = _store();
      api.rawError = StateError('boom');

      final status = await store.dispatchAndWait(LoadBranchesAction(api: api));

      expect(status.originalError, isNull);
      expect(
        store.state.generator.branches.failure,
        const GeneratorFailure(GeneratorFailureKind.unexpected),
      );
    });
  });

  group('LoadPublishedVersionsAction', () {
    test('stores the versions newest first', () async {
      final store = _store();
      api.versions = [
        publishedVersion('1.4.2'),
        publishedVersion('1.5.0'),
        publishedVersion('1.5.0-SNAPSHOT'),
      ];

      await store.dispatchAndWait(
        LoadPublishedVersionsAction(_project, api: api),
      );

      expect(store.state.generator.versions.value?.map((it) => it.version), [
        '1.5.0',
        '1.5.0-SNAPSHOT',
        '1.4.2',
      ]);
    });

    test('drops the answer when another project was selected', () async {
      final store = _store();
      api.hold = true;

      final done = store.dispatchAndWait(
        LoadPublishedVersionsAction(_project, api: api),
      );
      store.dispatchSync(SyncGeneratorProjectAction(_other.id));
      api.release();
      await done;

      expect(store.state.generator.projectId, 'p2');
      expect(store.state.generator.versions, const RequestState.idle());
    });
  });

  group('DownloadLocalBuildAction', () {
    test('saves the file under the name the generator gave', () async {
      final store = _store();
      final saved = <String>[];

      await store.dispatchAndWait(
        DownloadLocalBuildAction(
          _project,
          'develop',
          api: api,
          saveFile: (Uint8List bytes, String name) => saved.add(name),
        ),
      );

      expect(api.calls, ['localBuild p1 develop']);
      expect(saved, ['eldoria-local.zip']);
      expect(
        store.state.generator.localBuild,
        const RequestState.done('eldoria-local.zip'),
      );
    });

    test('a failure saves nothing', () async {
      final store = _store();
      final saved = <String>[];
      api.localBuildFailure = const GeneratorFailure(
        GeneratorFailureKind.rejected,
        statusCode: 422,
      );

      await store.dispatchAndWait(
        DownloadLocalBuildAction(
          _project,
          'develop',
          api: api,
          saveFile: (_, name) => saved.add(name),
        ),
      );

      expect(saved, isEmpty);
      expect(store.state.generator.localBuild.isFailed, isTrue);
    });

    test('a saver that cannot save is a failure', () async {
      final store = _store();

      await store.dispatchAndWait(
        DownloadLocalBuildAction(
          _project,
          'develop',
          api: api,
          saveFile: (_, _) => throw UnsupportedError('no web'),
        ),
      );

      expect(
        store.state.generator.localBuild.failure?.kind,
        GeneratorFailureKind.unexpected,
      );
    });
  });

  group('PublishReleaseAction', () {
    test('a success keeps the result and reloads the versions', () async {
      final store = _store();

      await store.dispatchAndWait(
        PublishReleaseAction(_project, '1.5.0', 'develop', api: api),
      );
      await store.waitAllActions([]);

      expect(api.calls, ['publish p1 1.5.0 develop', 'publishedVersions p1']);
      expect(
        store.state.generator.publish.value?.coordinates,
        'net.onelitefeather.vulpes.content:eldoria:1.5.0',
      );
      expect(store.state.generator.publishVersion, '1.5.0');
    });

    test('a conflict reloads the versions', () async {
      final store = _store();
      api.publishFailure = const GeneratorFailure(
        GeneratorFailureKind.versionExists,
        statusCode: 409,
      );

      await store.dispatchAndWait(
        PublishReleaseAction(_project, '1.5.0', 'develop', api: api),
      );
      await store.waitAllActions([]);

      expect(api.calls, ['publish p1 1.5.0 develop', 'publishedVersions p1']);
      expect(
        store.state.generator.publish.failure?.kind,
        GeneratorFailureKind.versionExists,
      );
    });

    test('a rejected publish does not reload the versions', () async {
      final store = _store();
      api.publishFailure = const GeneratorFailure(
        GeneratorFailureKind.rejected,
        statusCode: 422,
        diagnostics: [Diagnostic(file: 'A.java', line: 3, message: 'x')],
      );

      await store.dispatchAndWait(
        PublishReleaseAction(_project, '1.5.0', 'develop', api: api),
      );

      expect(api.calls, ['publish p1 1.5.0 develop']);
      expect(store.state.generator.publish.failure?.diagnostics, hasLength(1));
    });
  });

  test('SyncGeneratorProjectAction clears the results of another project', () {
    final store = _store(
      generator: GeneratorState(
        branches: const RequestState.done(['develop']),
        selectedBranch: 'develop',
        versions: RequestState.done([publishedVersion('1.0.0')]),
      ),
    );

    store.dispatchSync(SyncGeneratorProjectAction('p2'));

    final generator = store.state.generator;
    expect(generator.projectId, 'p2');
    expect(generator.versions, const RequestState.idle());
    expect(generator.selectedBranch, 'develop');
    expect(generator.branches.value, ['develop']);
  });
}
