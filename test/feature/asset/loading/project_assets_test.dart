import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/feature/asset/loading/asset_library.dart';
import 'package:stelaris/feature/asset/loading/project_assets.dart';
import 'package:stelaris_models/stelaris_models.dart';

AssetModel _asset(String id, String key, AssetKind kind) => AssetModel(
  id: id,
  projectId: 'p-1',
  displayName: 'Name of $id',
  key: key,
  kind: kind,
  fileName: '$id.json',
  contentType: 'application/json',
  size: 64,
  sha1: 'sha-$id',
);

final _ruby = _asset('m1', 'vulpes:item/ruby', AssetKind.MODEL);
final _sword = _asset('m2', 'vulpes:item/sword', AssetKind.MODEL);
final _axe = _asset('b1', 'vulpes:item/axe', AssetKind.BBMODEL);
final _gem = _asset('t1', 'vulpes:block/gem', AssetKind.TEXTURE);

DioException _failure() => DioException(
  requestOptions: RequestOptions(path: '/asset'),
  type: DioExceptionType.connectionError,
);

/// Answers from memory; [answer] decides what one `assetsOf` call returns.
class _Library extends AssetLibrary {
  _Library({this.assets = const [], this.references = const {}})
    : super(ApiService().assetApi);

  List<AssetModel> assets;
  Map<String, Set<String>> references;

  /// When set, `assetsOf` waits for it before answering.
  Completer<void>? gate;
  bool failLists = false;
  final Set<String> unreadable = {};

  @override
  Future<List<AssetModel>> assetsOf(String projectId, AssetKind kind) async {
    final snapshot = assets;
    final fail = failLists;
    await gate?.future;
    if (fail) throw _failure();
    return [
      for (final asset in snapshot)
        if (asset.kind == kind) asset,
    ];
  }

  /// When set, `textureKeysOf` waits for it before answering.
  Completer<void>? readGate;
  int reading = 0;
  int mostReadingAtOnce = 0;

  @override
  Future<Set<String>> textureKeysOf(String projectId, AssetModel asset) async {
    reading++;
    if (reading > mostReadingAtOnce) mostReadingAtOnce = reading;
    try {
      await readGate?.future;
      if (unreadable.contains(asset.id)) throw const FormatException('broken');
      return references[asset.id] ?? const {};
    } finally {
      reading--;
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads models sorted by key, textures and then references', () async {
    final library = _Library(
      assets: [_ruby, _axe, _gem],
      references: {
        'm1': {'vulpes:block/gem'},
      },
    );
    final assets = ProjectAssets(library: library, projectId: 'p-1');
    addTearDown(assets.dispose);

    await assets.load();

    expect(assets.models.map((model) => model.key), [
      'vulpes:item/axe',
      'vulpes:item/ruby',
    ]);
    expect(assets.textures, [_gem]);
    expect(assets.references[_ruby], {'vulpes:block/gem'});
    expect(assets.referencesLoaded, isTrue);
    expect(assets.listed, isTrue);
    expect(assets.loading, isFalse);
  });

  test('first load failure sets loadError and keeps listed false', () async {
    final failures = <ProblemDetail>[];
    final library = _Library()..failLists = true;
    final assets = ProjectAssets(
      library: library,
      projectId: 'p-1',
      onReloadFailed: failures.add,
    );
    addTearDown(assets.dispose);

    await assets.load();

    expect(assets.loadError, isNotNull);
    expect(assets.listed, isFalse);
    expect(assets.loading, isFalse);
    expect(failures, isEmpty);
  });

  test(
    'failed reload keeps the list and reports through onReloadFailed',
    () async {
      final failures = <ProblemDetail>[];
      final library = _Library(assets: [_ruby]);
      final assets = ProjectAssets(
        library: library,
        projectId: 'p-1',
        onReloadFailed: failures.add,
      );
      addTearDown(assets.dispose);
      await assets.load();

      library.failLists = true;
      await assets.load();

      expect(assets.models, [_ruby]);
      expect(assets.loadError, isNull);
      expect(failures, hasLength(1));
    },
  );

  test('an older load finishing last is ignored', () async {
    final library = _Library(assets: [_ruby]);
    final assets = ProjectAssets(library: library, projectId: 'p-1');
    addTearDown(assets.dispose);

    final gate = library.gate = Completer<void>();
    final first = assets.load();
    library
      ..gate = null
      ..assets = [_sword];
    await assets.load();
    gate.complete();
    await first;

    expect(assets.models, [_sword]);
  });

  test('skips model files that cannot be read', () async {
    final library = _Library(
      assets: [_ruby, _sword],
      references: {
        'm1': {'vulpes:block/gem'},
        'm2': {'vulpes:block/gem'},
      },
    )..unreadable.add('m2');
    final assets = ProjectAssets(library: library, projectId: 'p-1');
    addTearDown(assets.dispose);

    await assets.load();

    expect(assets.references.keys, [_ruby]);
  });

  test('reads the model files a few at a time', () async {
    final models = [
      for (var i = 0; i < ProjectAssets.parallelReads * 2; i++)
        _asset('m$i', 'vulpes:item/m$i', AssetKind.MODEL),
    ];
    final library = _Library(
      assets: models,
      references: {
        for (final model in models) model.id: {'vulpes:block/gem'},
      },
    );
    final gate = library.readGate = Completer<void>();
    final assets = ProjectAssets(library: library, projectId: 'p-1');
    addTearDown(assets.dispose);

    final loading = assets.load();
    await pumpEventQueue();

    expect(library.reading, ProjectAssets.parallelReads);
    gate.complete();
    await loading;

    expect(library.mostReadingAtOnce, ProjectAssets.parallelReads);
    expect(assets.references.keys, unorderedEquals(models));
    expect(assets.referencesLoaded, isTrue);
  });

  testWidgets('resume runs onResume instead of the plain load', (tester) async {
    var resumed = 0;
    final library = _Library(assets: [_ruby]);
    final assets = ProjectAssets(
      library: library,
      projectId: 'p-1',
      onResume: () async => resumed++,
    );
    addTearDown(assets.dispose);
    await assets.load();
    library.assets = [_sword];

    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(resumed, 1);
    expect(assets.models, [_ruby]);
  });
}
