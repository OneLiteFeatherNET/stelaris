import 'dart:convert';
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
  void Function(List<int> bytes, String fileName)? saveFile,
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
            saveFile: saveFile ?? (_, _) {},
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
    expect(find.text('Name of m2'), findsWidgets);
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
    /// `key "displayName" fileName`.
    Future<List<String>> run(
      WidgetTester tester, {
      required List<AssetModel> assets,
      required List<String?> selections,
      int modelStatus = 201,
    }) async {
      final uploads = <String>[];
      ApiService()
          .assetApi
          .apiClient
          .dio
          .httpClientAdapter = FakeHttpClientAdapter((RequestOptions options) {
        if (options.method != 'POST') {
          return FakeHttpClientAdapter.response({'elements': <Object?>[]});
        }
        final form = options.data as FormData;
        final fields = Map.fromEntries(form.fields);
        final fileName = form.files.single.value.filename!;
        uploads.add('${fields['key']} "${fields['displayName']}" $fileName');
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

      // The model takes the name the backend stored for the texture.
      expect(uploads, [
        'vulpes:item/sapphire "Sapphire" sapphire.png',
        'vulpes:item/sapphire "${sapphireTexture.displayName}" sapphire.json',
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

  group('opened model', () {
    late List<AssetModel> assets;
    late List<RequestOptions> requests;

    /// Opens the ruby model. Requests after that go to [answer]; the content
    /// of a model, which the preview loads, is always an empty model.
    Future<void> openRuby(
      WidgetTester tester, {
      ResponseBody Function(RequestOptions options)? answer,
      Future<PickedAssetFile?> Function()? pickFile,
      void Function(List<int> bytes, String fileName)? saveFile,
    }) async {
      assets = [_ruby];
      await _pump(
        tester,
        library: _Library(assets, {}),
        selectedId: 'm1',
        pickFile: pickFile,
        saveFile: saveFile,
      );
      await _settlePreview(tester);
      requests = [];
      ApiService()
          .assetApi
          .apiClient
          .dio
          .httpClientAdapter = FakeHttpClientAdapter((options) {
        requests.add(options);
        final isContent =
            options.method == 'GET' && options.uri.path.endsWith('/content');
        if (isContent || answer == null) {
          return ResponseBody.fromString('{"elements":[]}', 200);
        }
        return answer(options);
      });
    }

    /// Pumps until [done] holds and the preview no longer loads.
    Future<void> settleUntil(WidgetTester tester, bool Function() done) =>
        pumpUntil(
          tester,
          action: () async {},
          done: () =>
              done() &&
              find.byType(CircularProgressIndicator).evaluate().isEmpty,
        );

    bool shows(String text) => find.text(text).evaluate().isNotEmpty;

    ResponseBody problem(int status) => FakeHttpClientAdapter.response({
      'title': 'Refused',
      'status': status,
    }, statusCode: status);

    testWidgets('download saves the model file under its name', (tester) async {
      final saved = <(String, String)>[];
      await openRuby(
        tester,
        saveFile: (bytes, fileName) =>
            saved.add((utf8.decode(bytes), fileName)),
      );

      await tester.tap(find.byKey(const Key('model_download')));
      await settleUntil(tester, () => saved.isNotEmpty);

      expect(saved, [('{"elements":[]}', 'm1.json')]);
    });

    testWidgets('notes are saved from their dialog', (tester) async {
      await openRuby(
        tester,
        answer: (_) => FakeHttpClientAdapter.response(_ruby.toJson()),
      );

      await tester.tap(find.byKey(const Key('model_notes')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Glows at night');
      await tester.tap(find.text('Save'));
      await settleUntil(
        tester,
        () => find.byType(TextField).evaluate().isEmpty,
      );

      expect(requests.where((r) => r.method == 'PATCH'), hasLength(1));
    });

    testWidgets('info shows the key and id of the model', (tester) async {
      await openRuby(tester);

      await tester.tap(find.byKey(const Key('model_info')));
      await tester.pumpAndSettle();

      final dialog = find.byType(Dialog);
      expect(
        find.descendant(
          of: dialog,
          matching: find.textContaining('vulpes:item/ruby'),
        ),
        findsWidgets,
      );
      expect(
        find.descendant(of: dialog, matching: find.textContaining('m1')),
        findsWidgets,
      );
    });

    testWidgets('update replaces the file and shows the new one', (
      tester,
    ) async {
      final updated = _ruby.copyWith(sha1: 'sha-m1-v2');
      await openRuby(
        tester,
        pickFile: () async =>
            PickedAssetFile(name: 'ruby_v2.json', bytes: Uint8List(3)),
        answer: (_) {
          assets[0] = updated;
          return FakeHttpClientAdapter.response(updated.toJson());
        },
      );

      await tester.tap(find.byKey(const Key('model_update')));
      // The new file has a new sha1, so the preview loads it.
      await settleUntil(
        tester,
        () =>
            shows('Name of m1 was updated.') &&
            requests.any((r) => r.method == 'GET'),
      );

      final upload = requests.firstWhere((r) => r.method == 'POST');
      expect(
        (upload.data as FormData).files.single.value.filename,
        'ruby_v2.json',
      );
    });

    testWidgets('update after a change by someone else says so and reloads', (
      tester,
    ) async {
      await openRuby(
        tester,
        pickFile: () async =>
            PickedAssetFile(name: 'ruby.json', bytes: Uint8List(3)),
        answer: (_) => problem(412),
      );
      // Someone else stored a new file meanwhile.
      assets[0] = _ruby.copyWith(sha1: 'sha-m1-theirs');

      await tester.tap(find.byKey(const Key('model_update')));
      await settleUntil(
        tester,
        () => find
            .textContaining('was changed in the meantime')
            .evaluate()
            .isNotEmpty,
      );

      expect(find.textContaining('was updated'), findsNothing);
    });

    testWidgets('a refused update shows the error and keeps the model', (
      tester,
    ) async {
      await openRuby(
        tester,
        pickFile: () async =>
            PickedAssetFile(name: 'ruby.bbmodel', bytes: Uint8List(3)),
        answer: (_) => problem(400),
      );

      await tester.tap(find.byKey(const Key('model_update')));
      await settleUntil(
        tester,
        () => find.byType(SnackBar).evaluate().isNotEmpty,
      );

      expect(find.textContaining('was updated'), findsNothing);
      expect(find.text('Name of m1'), findsWidgets);
    });

    testWidgets('a restored version is announced and the page reloads', (
      tester,
    ) async {
      final restored = _ruby.copyWith(sha1: 'sha-m1-r1');
      await openRuby(
        tester,
        answer: (options) {
          if (options.uri.path.endsWith('/restore')) {
            assets[0] = restored;
            return FakeHttpClientAdapter.response(restored.toJson());
          }
          return FakeHttpClientAdapter.response({
            'items': [
              {
                'id': 'r-2',
                'number': 2,
                'sha1': 'sha-m1',
                'size': 64,
                'current': true,
              },
              {'id': 'r-1', 'number': 1, 'sha1': 'sha-m1-r1', 'size': 32},
            ],
            'totalItems': 2,
            'totalPages': 1,
            'currentPage': 0,
            'pageSize': 50,
          });
        },
      );

      await tester.tap(find.byKey(const Key('model_revisions')));
      await settleUntil(tester, () => shows('Version 1'));
      await tester.tap(find.byTooltip('Restore this version'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Restore'));
      // The restored file has a new sha1, so the preview loads it.
      await settleUntil(
        tester,
        () =>
            shows('Version 1 of Name of m1 was restored.') &&
            requests.any((r) => r.uri.path.endsWith('/m1/content')),
      );

      expect(find.text('Versions of Name of m1'), findsNothing);
    });
  });
}
