import 'dart:typed_data';

import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/asset/loading/asset_library.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/feature/asset/textures/texture_usage_sources.dart';
import 'package:stelaris/feature/asset/textures/textures_page.dart';
import 'package:stelaris/feature/base/chips/info_chip.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/l10n/app_localizations_delegates.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';
import '../../../support/pack_icon_pngs.dart';
import '../../../support/pump_until.dart';

AssetModel _asset(
  String id,
  String key,
  AssetKind kind, {
  String? name,
  String? sourceAssetId,
}) => AssetModel(
  id: id,
  projectId: 'p-1',
  displayName: name ?? 'Name of $id',
  key: key,
  kind: kind,
  fileName: '$id.png',
  contentType: 'image/png',
  size: 64,
  sha1: 'sha-$id',
  sourceAssetId: sourceAssetId,
);

final _axe = _asset('b1', 'vulpes:item/axe', AssetKind.BBMODEL, name: 'Axe');
final _gem = _asset('t1', 'vulpes:block/gem', AssetKind.TEXTURE, name: 'Gem');
final _stone = _asset(
  't2',
  'vulpes:block/stone',
  AssetKind.TEXTURE,
  name: 'Polished Stone',
);
final _blade = _asset(
  't3',
  'vulpes:item/axe_blade',
  AssetKind.TEXTURE,
  name: 'Blade',
  sourceAssetId: 'b1',
);

DioException _failure() => DioException(
  requestOptions: RequestOptions(path: '/asset'),
  type: DioExceptionType.connectionError,
);

/// Answers the page's lookups from memory, without requests.
class _Library extends AssetLibrary {
  _Library(this.assets) : super(ApiService().assetApi);

  final List<AssetModel> assets;
  bool fail = false;

  @override
  Future<List<AssetModel>> assetsOf(String projectId, AssetKind kind) async {
    if (fail) throw _failure();
    return [
      for (final asset in assets)
        if (asset.kind == kind) asset,
    ];
  }

  @override
  Future<Set<String>> textureKeysOf(String projectId, AssetModel asset) async =>
      const {};

  @override
  Future<List<int>> contentOf(String projectId, AssetModel asset) async =>
      png16;
}

Future<List<String?>> _pump(
  WidgetTester tester, {
  required _Library library,
  String? selectedId,
  Future<PickedAssetFile?> Function()? pickFile,
  TextureUsageSources sources = const TextureUsageSources(),
  ValueChanged<String>? openLocation,
}) async {
  tester.view.physicalSize = const Size(1200, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final selections = <String?>[];
  await tester.pumpWidget(
    StoreProvider<AppState>(
      store: Store<AppState>(
        initialState: const AppState(
          selectedProject: Project(
            id: 'p-1',
            key: 'vulpes',
            displayName: 'Vulpes',
          ),
        ),
      ),
      child: MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TexturesPage(
            library: library,
            selectedId: selectedId,
            onSelected: selections.add,
            loadUsageSources: (_) async => sources,
            openLocation: openLocation ?? (_) {},
            pickFile: pickFile ?? () async => null,
            saveFile: (_, _) {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return selections;
}

List<String> _keys(WidgetTester tester) => tester
    .widgetList<InfoChip>(find.byType(InfoChip))
    .map((chip) => chip.text)
    .toList();

void main() {
  setUp(AssetLibrary.shared.clearContents);

  testWidgets('lists every texture with name and key', (tester) async {
    await _pump(tester, library: _Library([_axe, _gem, _stone]));

    expect(find.text('Textures (2)'), findsOneWidget);
    expect(find.text('Gem'), findsOneWidget);
    expect(find.text('Polished Stone'), findsOneWidget);
    expect(_keys(tester), ['vulpes:block/gem', 'vulpes:block/stone']);
  });

  testWidgets('search filters by key and display name, case insensitive', (
    tester,
  ) async {
    await _pump(tester, library: _Library([_gem, _stone, _blade]));

    await tester.enterText(
      find.byKey(const Key('textures_search')),
      'POLISHED',
    );
    await tester.pumpAndSettle();
    expect(_keys(tester), ['vulpes:block/stone']);

    await tester.enterText(find.byKey(const Key('textures_search')), 'item/');
    await tester.pumpAndSettle();
    expect(_keys(tester), ['vulpes:item/axe_blade']);
  });

  testWidgets('origin filter separates uploaded and extracted', (tester) async {
    await _pump(tester, library: _Library([_axe, _gem, _blade]));

    await tester.tap(find.text('Extracted'));
    await tester.pumpAndSettle();
    expect(_keys(tester), ['vulpes:item/axe_blade']);
    expect(find.text('From Axe'), findsOneWidget);

    await tester.tap(find.text('Uploaded').first);
    await tester.pumpAndSettle();
    expect(_keys(tester), ['vulpes:block/gem']);
  });

  testWidgets('search without hits shows no matches', (tester) async {
    await _pump(tester, library: _Library([_gem]));

    await tester.enterText(find.byKey(const Key('textures_search')), 'zzz');
    await tester.pumpAndSettle();

    expect(find.text('No texture matches the search.'), findsOneWidget);
    expect(
      find.textContaining('This project has no textures yet'),
      findsNothing,
    );
  });

  testWidgets('empty project shows the empty text', (tester) async {
    await _pump(tester, library: _Library([]));

    expect(
      find.textContaining('This project has no textures yet'),
      findsOneWidget,
    );
  });

  testWidgets('first load failure shows retry', (tester) async {
    await _pump(tester, library: _Library([_gem])..fail = true);

    expect(find.text('The textures could not be loaded.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('upload selects the new texture', (tester) async {
    final assets = [_gem];
    final selections = await _pump(
      tester,
      library: _Library(assets),
      pickFile: () async =>
          PickedAssetFile(name: 'stone.png', bytes: Uint8List.fromList(png16)),
    );
    ApiService().assetApi.apiClient.dio.httpClientAdapter =
        FakeHttpClientAdapter((RequestOptions options) {
          assets.add(_stone);
          return FakeHttpClientAdapter.response(_stone.toJson());
        });

    await tester.tap(find.byKey(const Key('textures_upload')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose a file'));
    await tester.pumpAndSettle();
    await pumpUntil(
      tester,
      action: () async {
        await tester.tap(find.text('Upload').last);
      },
      done: () => selections.isNotEmpty,
    );

    expect(selections, ['t2']);
  });

  testWidgets('extracted texture has no delete and no update', (tester) async {
    await _pump(tester, library: _Library([_axe, _blade]), selectedId: 't3');

    expect(find.byKey(const Key('model_download')), findsOneWidget);
    expect(find.byKey(const Key('texture_delete')), findsNothing);
    expect(find.byKey(const Key('model_update')), findsNothing);
  });

  testWidgets('delete dialog warns about every use', (tester) async {
    await _pump(
      tester,
      library: _Library([_gem]),
      selectedId: 't1',
      sources: const TextureUsageSources(
        fonts: [FontModel(uiName: 'Icons', id: 'f1', textureAssetId: 't1')],
      ),
    );

    await tester.tap(find.byKey(const Key('texture_delete')));
    await tester.pumpAndSettle();

    expect(find.text('Delete Gem?'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.textContaining('Icons'),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('lose this texture'), findsOneWidget);
  });

  testWidgets('confirming deletes, returns to the grid and reloads', (
    tester,
  ) async {
    final assets = [_gem, _stone];
    final requests = <RequestOptions>[];
    final selections = await _pump(
      tester,
      library: _Library(assets),
      selectedId: 't1',
    );
    ApiService().assetApi.apiClient.dio.httpClientAdapter =
        FakeHttpClientAdapter((RequestOptions options) {
          requests.add(options);
          assets.remove(_gem);
          return FakeHttpClientAdapter.response(_gem.toJson());
        });

    await tester.tap(find.byKey(const Key('texture_delete')));
    await tester.pumpAndSettle();
    await pumpUntil(
      tester,
      action: () async {
        await tester.tap(find.text('Delete').last);
      },
      done: () => selections.isNotEmpty,
    );

    expect(requests.single.method, 'DELETE');
    expect(requests.single.uri.path, endsWith('/delete/t1'));
    expect(selections, [null]);
  });

  testWidgets('tap on a model opens the models page with its id', (
    tester,
  ) async {
    final locations = <String>[];
    await _pump(
      tester,
      library: _Library([_axe, _blade]),
      selectedId: 't3',
      openLocation: locations.add,
    );

    await tester.tap(find.byKey(const ValueKey('texture_used_model_b1')));

    expect(locations, ['/assets/models?id=b1']);
  });

  testWidgets('unused filter shows only textures nobody uses', (tester) async {
    await _pump(
      tester,
      library: _Library([_axe, _gem, _stone, _blade]),
      sources: const TextureUsageSources(
        fonts: [FontModel(uiName: 'Icons', id: 'f1', textureAssetId: 't1')],
      ),
    );

    await tester.tap(find.byKey(const Key('textures_unused')));
    await tester.pumpAndSettle();

    expect(_keys(tester), ['vulpes:block/stone']);
  });
}
