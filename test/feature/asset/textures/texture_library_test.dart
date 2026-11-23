import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/feature/asset/loading/asset_library.dart';
import 'package:stelaris/feature/asset/textures/texture_library.dart';
import 'package:stelaris/feature/asset/textures/texture_usage_sources.dart';
import 'package:stelaris_models/stelaris_models.dart';

AssetModel _texture(String id, {String sha1 = ''}) => AssetModel(
  id: id,
  projectId: 'p-1',
  displayName: 'Name of $id',
  key: 'vulpes:block/$id',
  kind: AssetKind.TEXTURE,
  fileName: '$id.png',
  contentType: 'image/png',
  size: 64,
  sha1: sha1.isEmpty ? 'sha-$id' : sha1,
);

final _gem = _texture('t1');

const _font = FontModel(uiName: 'Icons', id: 'f1', textureAssetId: 't1');

/// Answers the lookups from memory and counts the content loads.
class _Library extends AssetLibrary {
  _Library(this.assets) : super(ApiService().assetApi);

  final List<AssetModel> assets;
  int contentLoads = 0;

  /// The texture listings asked for.
  int listings = 0;

  @override
  Future<List<AssetModel>> assetsOf(String projectId, AssetKind kind) async {
    if (kind == AssetKind.TEXTURE) listings++;
    return [
      for (final asset in assets)
        if (asset.kind == kind) asset,
    ];
  }

  @override
  Future<Set<String>> textureKeysOf(String projectId, AssetModel asset) async =>
      const {};

  @override
  Future<List<int>> contentOf(String projectId, AssetModel asset) async {
    contentLoads++;
    return const [1, 2, 3];
  }
}

TextureLibrary _textures(
  List<AssetModel> assets,
  Future<TextureUsageSources> Function(String projectId) loadUsageSources, {
  _Library? library,
}) {
  final textures = TextureLibrary(
    library: library ?? _Library(assets),
    projectId: 'p-1',
    loadUsageSources: loadUsageSources,
  );
  addTearDown(textures.dispose);
  return textures;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'usages are null until assets, references and sources are loaded',
    () async {
      final sources = Completer<TextureUsageSources>();
      final textures = _textures([_gem], (_) => sources.future);

      final loading = textures.load();
      await Future<void>.delayed(Duration.zero);
      expect(textures.textures, [_gem]);
      expect(textures.usagesOf(_gem), isNull);

      sources.complete(const TextureUsageSources(fonts: [_font]));
      await loading;

      expect(textures.usagesOf(_gem)!.fonts, [_font]);
      expect(textures.usagesFailed, isFalse);
    },
  );

  test(
    'a failed source load sets usagesFailed and loadSources retries',
    () async {
      var calls = 0;
      final textures = _textures([_gem], (_) async {
        if (++calls == 1) throw StateError('offline');
        return const TextureUsageSources(fonts: [_font]);
      });

      await textures.load();
      expect(textures.usagesFailed, isTrue);
      expect(textures.usagesOf(_gem), isNull);

      await textures.loadSources();
      expect(textures.usagesFailed, isFalse);
      expect(textures.usagesOf(_gem)!.fonts, [_font]);
    },
  );

  test('an older source load ending last is ignored', () async {
    final first = Completer<TextureUsageSources>();
    final second = Completer<TextureUsageSources>();
    final answers = [first, second];
    final textures = _textures([_gem], (_) => answers.removeAt(0).future);

    final load = textures.load();
    final retry = textures.loadSources();
    second.complete(const TextureUsageSources(fonts: [_font]));
    await retry;
    first.complete(const TextureUsageSources());
    await load;

    expect(textures.usagesOf(_gem)!.fonts, [_font]);
  });

  test('a reload keeps the uses until its sources are in', () async {
    final answers = [
      Completer<TextureUsageSources>()
        ..complete(const TextureUsageSources(fonts: [_font])),
      Completer<TextureUsageSources>(),
    ];
    final textures = _textures([_gem], (_) => answers.removeAt(0).future);
    await textures.load();
    final reloading = answers.first;

    final reload = textures.load();
    await Future<void>.delayed(Duration.zero);
    expect(textures.usagesOf(_gem)!.fonts, [_font]);

    reloading.complete(const TextureUsageSources());
    await reload;
    expect(textures.usagesOf(_gem)!.fonts, isEmpty);
  });

  test('a failed reload keeps the uses', () async {
    var calls = 0;
    final textures = _textures([_gem], (_) async {
      if (++calls == 2) throw StateError('offline');
      return const TextureUsageSources(fonts: [_font]);
    });
    await textures.load();

    await textures.load();

    expect(textures.usagesFailed, isFalse);
    expect(textures.usagesOf(_gem)!.fonts, [_font]);
  });

  testWidgets('resume loads the assets and the sources again', (
    tester,
  ) async {
    final library = _Library([_gem]);
    var sourceLoads = 0;
    final textures = _textures([_gem], (_) async {
      sourceLoads++;
      return const TextureUsageSources();
    }, library: library);
    await textures.load();

    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(library.listings, 2);
    expect(sourceLoads, 2);
  });

  test('thumbnailOf loads each sha1 once', () async {
    final library = _Library([_gem]);
    final textures = _textures(
      [_gem],
      (_) async => const TextureUsageSources(),
      library: library,
    );

    await textures.thumbnailOf(_gem);
    await textures.thumbnailOf(_texture('t2', sha1: 'sha-t1'));

    expect(library.contentLoads, 1);
  });
}
