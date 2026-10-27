import 'dart:typed_data';

import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/asset/loading/asset_library.dart';
import 'package:stelaris/feature/asset/models/models_page.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_asset_api.dart';
import '../../../support/fake_http_client_adapter.dart';
import '../../../support/pump_until.dart';

AssetModel _asset(String id, String key, AssetKind kind) => AssetModel(
  id: id,
  projectId: 'p-1',
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

/// Answers the page's lookups from memory, without requests.
class _Library extends AssetLibrary {
  _Library(this.assets, this.references) : super(ApiService().assetApi);

  final List<AssetModel> assets;
  final Map<String, Set<String>> references;

  @override
  Future<List<AssetModel>> assetsOf(String projectId, AssetKind kind) async => [
    for (final asset in assets)
      if (asset.kind == kind) asset,
  ];

  @override
  Future<Set<String>> textureKeysOf(String projectId, AssetModel asset) async =>
      references[asset.id] ?? const {};
}

Future<List<String?>> _pump(
  WidgetTester tester, {
  required _Library library,
  String? selectedId,
  Size size = const Size(1200, 800),
  Future<PickedAssetFile?> Function()? pickFile,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  // The 3D preview of a selected model loads through the shared library.
  serveAssets(const []);
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
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ModelsPage(
            library: library,
            selectedId: selectedId,
            onSelected: selections.add,
            pickFile: pickFile ?? () async => null,
            loadUsages: (_) async => {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return selections;
}

/// Waits until the 3D preview of the selected model has loaded, its requests
/// run on real timers.
Future<void> _settlePreview(WidgetTester tester) => pumpUntil(
  tester,
  action: () async {},
  done: () => find.byType(CircularProgressIndicator).evaluate().isEmpty,
);

void main() {
  // A content cached by another test would never resolve in this one.
  setUp(AssetLibrary.shared.clearContents);

  testWidgets('lists the models sorted by key without textures', (
    tester,
  ) async {
    await _pump(tester, library: _Library([_sword, _gem, _axe, _ruby], {}));

    final keys = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .map((tile) => ((tile.title! as Text).data));
    expect(keys, ['vulpes:item/axe', 'vulpes:item/ruby', 'vulpes:item/sword']);
  });

  testWidgets('counts the missing textures of each model', (tester) async {
    await _pump(
      tester,
      library: _Library(
        [_ruby, _sword, _gem],
        {
          'm1': {'vulpes:block/gem', 'vulpes:item/glow', 'vulpes:item/rim'},
          'm2': {'vulpes:block/gem'},
        },
      ),
    );

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('model_missing_m1')),
        matching: find.text('2 missing'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('model_missing_m2')), findsNothing);
  });

  testWidgets('selecting a model shows its detail next to the list', (
    tester,
  ) async {
    final selections = await _pump(
      tester,
      library: _Library([_ruby, _sword], {}),
    );

    await tester.tap(find.text('vulpes:item/sword'));
    await _settlePreview(tester);

    expect(selections, ['m2']);
    expect(
      tester.widget<Text>(find.byKey(const Key('model_detail_title'))).data,
      'vulpes:item/sword',
    );
    expect(find.byKey(const Key('models_list')), findsOneWidget);
  });

  testWidgets('a narrow page shows the detail alone with a way back', (
    tester,
  ) async {
    final selections = await _pump(
      tester,
      library: _Library([_ruby], {}),
      selectedId: 'm1',
      size: const Size(600, 900),
    );
    await _settlePreview(tester);

    expect(find.byKey(const Key('models_list')), findsNothing);
    expect(find.byKey(const Key('model_detail_title')), findsOneWidget);

    await tester.tap(find.byKey(const Key('models_back')));
    await tester.pump();

    expect(selections, [null]);
    expect(find.byKey(const Key('models_list')), findsOneWidget);
  });

  testWidgets('an uploaded model is listed and selected', (tester) async {
    final assets = [_ruby];
    final selections = await _pump(
      tester,
      library: _Library(assets, {}),
      pickFile: () async =>
          PickedAssetFile(name: 'sword.json', bytes: Uint8List(3)),
    );
    ApiService().assetApi.apiClient.dio.httpClientAdapter =
        FakeHttpClientAdapter((RequestOptions options) {
          assets.add(_sword);
          return FakeHttpClientAdapter.response(_sword.toJson());
        });

    await tester.tap(find.byKey(const Key('models_upload')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose a file'));
    await tester.pumpAndSettle();
    await pumpUntil(
      tester,
      action: () async {
        await tester.tap(find.text('Upload').last);
      },
      // The new model's preview loads too, so the page can settle.
      done: () =>
          selections.isNotEmpty &&
          find.byType(CircularProgressIndicator).evaluate().isEmpty,
    );

    expect(selections, ['m2']);
    expect(find.text('vulpes:item/sword'), findsWidgets);
  });
}
