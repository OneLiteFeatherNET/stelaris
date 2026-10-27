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
import 'package:stelaris/feature/base/chips/info_chip.dart';
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
        .widgetList<InfoChip>(find.byType(InfoChip))
        .map((chip) => chip.text);
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

    expect(find.byKey(const ValueKey('model_missing_m1')), findsOneWidget);
    expect(
      find.byTooltip('2 textures of this model are missing'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('model_missing_m2')), findsNothing);
  });

  testWidgets('a wide page lays the cards out in columns', (tester) async {
    await _pump(tester, library: _Library([_ruby, _sword, _axe], {}));

    final first = tester.getTopLeft(find.byKey(const ValueKey('model_b1')));
    final second = tester.getTopLeft(find.byKey(const ValueKey('model_m1')));
    expect(second.dy, first.dy);
    expect(second.dx, greaterThan(first.dx));
  });

  testWidgets('a narrow page stacks the cards in one column', (tester) async {
    await _pump(
      tester,
      library: _Library([_ruby, _sword], {}),
      size: const Size(400, 900),
    );

    final first = tester.getTopLeft(find.byKey(const ValueKey('model_m1')));
    final second = tester.getTopLeft(find.byKey(const ValueKey('model_m2')));
    expect(second.dx, first.dx);
    expect(second.dy, greaterThan(first.dy));
  });

  testWidgets('a model opens in place of the grid with a way back', (
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
    expect(find.byKey(const Key('models_grid')), findsNothing);

    await tester.tap(find.byKey(const Key('page_header_back_button')));
    await tester.pump();

    expect(selections, ['m2', null]);
    expect(find.byKey(const Key('models_grid')), findsOneWidget);
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

  testWidgets('an uploaded missing texture turns present', (tester) async {
    final assets = [_ruby];
    final selections = await _pump(
      tester,
      library: _Library(assets, {
        'm1': {'vulpes:item/glow'},
      }),
      selectedId: 'm1',
      pickFile: () async =>
          PickedAssetFile(name: 'whatever.png', bytes: Uint8List(3)),
    );
    await _settlePreview(tester);
    expect(find.text('Missing'), findsOneWidget);
    final glow = _asset('t9', 'vulpes:item/glow', AssetKind.TEXTURE);
    final uploadedKeys = <Object?>[];
    ApiService().assetApi.apiClient.dio.httpClientAdapter =
        FakeHttpClientAdapter((RequestOptions options) {
          if (options.method == 'POST') {
            final form = options.data as FormData;
            uploadedKeys.addAll([
              for (final field in form.fields)
                if (field.key == 'key') field.value,
            ]);
            assets.add(glow);
            return FakeHttpClientAdapter.response(glow.toJson());
          }
          return FakeHttpClientAdapter.response({'elements': <Object?>[]});
        });

    final upload = find.byKey(
      const ValueKey('model_texture_upload_vulpes:item/glow'),
    );
    await tester.ensureVisible(upload);
    await tester.tap(upload);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose a file'));
    await tester.pumpAndSettle();
    await pumpUntil(
      tester,
      action: () async {
        await tester.tap(find.text('Upload').last);
      },
      done: () =>
          find.text('Missing').evaluate().isEmpty &&
          find.byType(CircularProgressIndicator).evaluate().isEmpty,
    );

    expect(uploadedKeys, ['vulpes:item/glow']);
    expect(find.text('Missing'), findsNothing);
    expect(selections, isEmpty);
  });

  group('new from texture', () {
    final sapphireTexture = _asset(
      't5',
      'vulpes:item/sapphire',
      AssetKind.TEXTURE,
    );
    final sapphireModel = _asset('m5', 'vulpes:item/sapphire', AssetKind.MODEL);

    /// Starts "new from texture" with `sapphire.png`; the backend answers
    /// the model upload with [modelStatus]. Returns the uploads as
    /// `key fileName`.
    Future<List<String>> run(
      WidgetTester tester, {
      required List<AssetModel> assets,
      required List<String?> selections,
      int modelStatus = 201,
    }) async {
      final uploads = <String>[];
      ApiService().assetApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter((RequestOptions options) {
            if (options.method != 'POST') {
              return FakeHttpClientAdapter.response({'elements': <Object?>[]});
            }
            final form = options.data as FormData;
            final key = form.fields.firstWhere((f) => f.key == 'key').value;
            final fileName = form.files.single.value.filename!;
            uploads.add('$key $fileName');
            if (fileName.endsWith('.png')) {
              assets.add(sapphireTexture);
              return FakeHttpClientAdapter.response(sapphireTexture.toJson());
            }
            if (modelStatus != 201) {
              return FakeHttpClientAdapter.response({
                'title': 'Server error',
                'status': modelStatus,
                'detail': 'The store is down.',
              }, statusCode: modelStatus);
            }
            assets.add(sapphireModel);
            return FakeHttpClientAdapter.response(sapphireModel.toJson());
          });

      await tester.tap(find.byKey(const Key('models_from_texture')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose a file'));
      await tester.pumpAndSettle();
      await pumpUntil(
        tester,
        action: () async {
          await tester.tap(find.text('Upload').last);
        },
        done: () =>
            uploads.length == 2 &&
            find.byType(Dialog).evaluate().isEmpty &&
            find.byType(CircularProgressIndicator).evaluate().isEmpty &&
            (modelStatus == 201
                ? selections.isNotEmpty
                : find.byType(SnackBar).evaluate().isNotEmpty),
      );
      return uploads;
    }

    testWidgets('uploads the texture and its model and selects it', (
      tester,
    ) async {
      final assets = [_ruby];
      final selections = await _pump(
        tester,
        library: _Library(assets, {}),
        pickFile: () async =>
            PickedAssetFile(name: 'sapphire.png', bytes: Uint8List(3)),
      );

      final uploads = await run(tester, assets: assets, selections: selections);

      expect(uploads, [
        'vulpes:item/sapphire sapphire.png',
        'vulpes:item/sapphire sapphire.json',
      ]);
      expect(selections, ['m5']);
    });

    testWidgets('keeps the texture when the model can not be stored', (
      tester,
    ) async {
      final assets = [_ruby];
      final selections = await _pump(
        tester,
        library: _Library(assets, {}),
        pickFile: () async =>
            PickedAssetFile(name: 'sapphire.png', bytes: Uint8List(3)),
      );

      await run(
        tester,
        assets: assets,
        selections: selections,
        modelStatus: 500,
      );

      expect(assets, contains(sapphireTexture));
      expect(find.text('The store is down.'), findsOneWidget);
      expect(selections, isEmpty);
    });
  });
}
