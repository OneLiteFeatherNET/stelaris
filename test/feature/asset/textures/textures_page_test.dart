import 'dart:typed_data';

import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/search_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
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

const _state = AppState(
  selectedProject: Project(id: 'p-1', key: 'vulpes', displayName: 'Vulpes'),
);

void _resume(WidgetTester tester) => tester.binding
  ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
  ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);

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

Future<void> _pump(
  WidgetTester tester, {
  required _Library library,
  Future<PickedAssetFile?> Function()? pickFile,
  TextureUsageSources sources = const TextureUsageSources(),
  Future<TextureUsageSources> Function(String projectId)? loadSources,
  ValueChanged<String>? openLocation,
  Store<AppState>? store,
}) async {
  tester.view.physicalSize = const Size(1200, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    StoreProvider<AppState>(
      store: store ?? Store<AppState>(initialState: _state),
      child: MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TexturesPage(
            library: library,
            loadUsageSources: loadSources ?? (_) async => sources,
            openLocation: openLocation ?? (_) {},
            pickFile: pickFile ?? () async => null,
            saveFile: (_, _) {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Opens the info dialog of the texture [id] by tapping its card.
Future<void> _openInfo(WidgetTester tester, String id) async {
  await tester.tap(find.text(_names[id]!));
  await tester.pumpAndSettle();
}

/// Opens the card menu of the texture [id].
Future<void> _openMenu(WidgetTester tester, String id) async {
  await tester.tap(
    find.descendant(
      of: find.byKey(ValueKey('texture_$id')),
      matching: find.byTooltip('More actions'),
    ),
  );
  await tester.pumpAndSettle();
}

const _names = {'t1': 'Gem', 't2': 'Polished Stone', 't3': 'Blade'};

/// The labels of the open card menu.
List<String> _menuLabels(WidgetTester tester) => [
  for (final item in tester.widgetList<PopupMenuItem<void>>(
    find.byType(PopupMenuItem<void>),
  ))
    for (final text in tester.widgetList<Text>(
      find.descendant(of: find.byWidget(item), matching: find.byType(Text)),
    ))
      text.data ?? '',
];

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

  testWidgets('search from the store filters by key and display name', (
    tester,
  ) async {
    final store = Store<AppState>(initialState: _state);
    await _pump(
      tester,
      library: _Library([_gem, _stone, _blade]),
      store: store,
    );

    store.dispatch(UpdateSearchQueryAction('POLISHED'));
    await tester.pumpAndSettle();
    expect(_keys(tester), ['vulpes:block/stone']);

    store.dispatch(UpdateSearchQueryAction('item/'));
    await tester.pumpAndSettle();
    expect(_keys(tester), ['vulpes:item/axe_blade']);
  });

  testWidgets('registers the textures page as the search section', (
    tester,
  ) async {
    final store = Store<AppState>(initialState: _state);
    await _pump(tester, library: _Library([_gem]), store: store);

    expect(store.state.modelSearch.section, AssetNavigationEntry.textures);
  });

  testWidgets('search without hits shows no matches', (tester) async {
    final store = Store<AppState>(initialState: _state);
    await _pump(tester, library: _Library([_gem]), store: store);

    store.dispatch(UpdateSearchQueryAction('zzz'));
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

  testWidgets('an uploaded texture is listed', (tester) async {
    final assets = [_gem];
    await _pump(
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
      done: () => find.text('Polished Stone').evaluate().isNotEmpty,
    );

    expect(_keys(tester), ['vulpes:block/gem', 'vulpes:block/stone']);
  });

  testWidgets('tap on a card opens the info dialog with used in', (
    tester,
  ) async {
    await _pump(
      tester,
      library: _Library([_gem]),
      sources: const TextureUsageSources(
        fonts: [FontModel(uiName: 'Icons', id: 'f1', textureAssetId: 't1')],
      ),
    );

    await _openInfo(tester, 't1');

    expect(find.byType(Dialog), findsOneWidget);
    expect(
      find.descendant(of: find.byType(Dialog), matching: find.text('Icons')),
      findsOneWidget,
    );
  });

  testWidgets('menu of an uploaded texture offers every action', (
    tester,
  ) async {
    await _pump(tester, library: _Library([_gem]));

    await _openMenu(tester, 't1');

    expect(_menuLabels(tester), [
      'Notes',
      'Info',
      'Versions',
      'Update',
      'Download',
      'Delete',
    ]);
  });

  testWidgets('menu of an extracted texture has no update and no delete', (
    tester,
  ) async {
    await _pump(tester, library: _Library([_axe, _blade]));

    await _openMenu(tester, 't3');

    expect(_menuLabels(tester), ['Notes', 'Info', 'Versions', 'Download']);
  });

  testWidgets('delete dialog warns about every use', (tester) async {
    await _pump(
      tester,
      library: _Library([_gem]),
      sources: const TextureUsageSources(
        fonts: [FontModel(uiName: 'Icons', id: 'f1', textureAssetId: 't1')],
      ),
    );

    await _openMenu(tester, 't1');
    await tester.tap(find.text('Delete'));
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

  testWidgets('confirming deletes and reloads the grid', (tester) async {
    final assets = [_gem, _stone];
    final requests = <RequestOptions>[];
    await _pump(tester, library: _Library(assets));
    ApiService().assetApi.apiClient.dio.httpClientAdapter =
        FakeHttpClientAdapter((RequestOptions options) {
          requests.add(options);
          assets.remove(_gem);
          return FakeHttpClientAdapter.response(_gem.toJson());
        });

    await _openMenu(tester, 't1');
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await pumpUntil(
      tester,
      action: () async {
        await tester.tap(find.text('Delete').last);
      },
      done: () => find.text('Gem').evaluate().isEmpty,
    );

    expect(requests.single.method, 'DELETE');
    expect(requests.single.uri.path, endsWith('/delete/t1'));
    expect(_keys(tester), ['vulpes:block/stone']);
  });

  testWidgets('jump to a model closes the dialog and opens the models page', (
    tester,
  ) async {
    final locations = <String>[];
    await _pump(
      tester,
      library: _Library([_axe, _blade]),
      openLocation: locations.add,
    );

    await _openInfo(tester, 't3');
    await tester.tap(find.byKey(const ValueKey('texture_used_model_b1')));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
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

  testWidgets('resume reloads the fonts and pack metas', (tester) async {
    var sources = const TextureUsageSources();
    await _pump(
      tester,
      library: _Library([_gem]),
      loadSources: (_) async => sources,
    );

    sources = const TextureUsageSources(
      fonts: [FontModel(uiName: 'Icons', id: 'f1', textureAssetId: 't1')],
    );
    _resume(tester);
    await tester.pumpAndSettle();
    await _openInfo(tester, 't1');

    expect(
      find.descendant(of: find.byType(Dialog), matching: find.text('Icons')),
      findsOneWidget,
    );
  });

  testWidgets('unused filter can be turned off when the usages fail', (
    tester,
  ) async {
    var fail = false;
    await _pump(
      tester,
      library: _Library([_gem, _stone]),
      loadSources: (_) async {
        if (fail) throw _failure();
        return const TextureUsageSources(
          fonts: [FontModel(uiName: 'Icons', id: 'f1', textureAssetId: 't1')],
        );
      },
    );
    await tester.tap(find.byKey(const Key('textures_unused')));
    await tester.pumpAndSettle();
    expect(_keys(tester), ['vulpes:block/stone']);

    fail = true;
    _resume(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('textures_unused')));
    await tester.pumpAndSettle();

    expect(_keys(tester), ['vulpes:block/gem', 'vulpes:block/stone']);
  });

  testWidgets('deleting clears the texture from the fonts in the store', (
    tester,
  ) async {
    const icons = FontModel(uiName: 'Icons', id: 'f1', textureAssetId: 't1');
    final store = Store<AppState>(
      initialState: _state.copyWith(
        fonts: const PaginatedResult(
          items: [icons],
          totalItems: 1,
          totalPages: 1,
          currentPage: 1,
          pageSize: 10,
        ),
        selectedFont: icons,
      ),
    );
    final assets = [_gem];
    await _pump(
      tester,
      library: _Library(assets),
      sources: const TextureUsageSources(fonts: [icons]),
      store: store,
    );
    ApiService().assetApi.apiClient.dio.httpClientAdapter =
        FakeHttpClientAdapter((RequestOptions options) {
          assets.remove(_gem);
          return FakeHttpClientAdapter.response(_gem.toJson());
        });

    await _openMenu(tester, 't1');
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await pumpUntil(
      tester,
      action: () async {
        await tester.tap(find.text('Delete').last);
      },
      done: () => store.state.selectedFont?.textureAssetId == null,
    );

    expect(store.state.fonts.items.single.textureAssetId, isNull);
  });
}
