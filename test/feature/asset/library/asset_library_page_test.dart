import 'dart:convert';
import 'dart:typed_data';

import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/asset_model.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/asset/item_model_asset_preview.dart';
import 'package:stelaris/feature/asset/library/asset_library_page.dart';
import 'package:stelaris/feature/asset/loading/asset_library.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';
import '../../../support/pump_until.dart';

const _rubyModel = 'vulpes:item/ruby';
const _sapphireModel = 'vulpes:item/sapphire';
const _gemTexture = 'vulpes:item/gem';
const _rubyGemModel = 'vulpes:item/ruby_gem';

/// A 1x1 PNG, the bytes the texture content request answers with.
final Uint8List _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
);

const _unavailable = 'The 3D preview is not available on this platform.';
const _previewFailed = 'The model could not be shown.';

Map<String, Object?> _assetJson({
  required String id,
  required String key,
  required String kind,
  String? fileName,
  String sha1 = 'bbbb',
}) => {
  'id': id,
  'projectId': 'p-1',
  'key': key,
  'kind': kind,
  'fileName': fileName ?? '$id.json',
  'contentType': 'application/json',
  'size': 512,
  'sha1': sha1,
  'derivedAssetIds': <String>[],
};

/// Answers the page's requests from [assets]: the list per kind and the content
/// of each asset. An upload answers with [uploaded] and adds it to [assets], or
/// with [uploadProblem] and adds nothing.
class _Backend {
  _Backend({
    required List<Map<String, Object?>> assets,
    this.uploaded,
    this.uploadProblem,
  }) : assets = [...assets];

  final List<Map<String, Object?>> assets;
  final Map<String, Object?>? uploaded;
  final Map<String, Object?>? uploadProblem;

  final List<RequestOptions> requests = [];

  ResponseBody handle(RequestOptions options) {
    requests.add(options);
    if (options.method == 'POST') {
      final problem = uploadProblem;
      if (problem != null) {
        return FakeHttpClientAdapter.response(
          problem,
          statusCode: problem['status']! as int,
        );
      }
      assets.add(uploaded!);
      return FakeHttpClientAdapter.response(uploaded, statusCode: 201);
    }
    final segments = options.uri.pathSegments;
    if (segments.last == 'content') {
      final id = segments[segments.length - 2];
      final asset = assets.firstWhere((asset) => asset['id'] == id);
      if (asset['kind'] == 'TEXTURE') {
        return ResponseBody.fromBytes(_png, 200);
      }
      return ResponseBody.fromBytes(utf8.encode('{}'), 200);
    }
    final kind = options.uri.queryParameters['kind'];
    final items = assets.where((asset) => asset['kind'] == kind).toList();
    return FakeHttpClientAdapter.response({
      'items': items,
      'totalItems': items.length,
      'totalPages': 1,
      'currentPage': 0,
      'pageSize': 50,
    });
  }

  int requestsTo(String pathSuffix) =>
      requests.where((r) => r.uri.path.endsWith(pathSuffix)).length;

  List<String?> get queriedKinds => [
    for (final request in requests)
      if (request.method == 'GET' &&
          request.uri.queryParameters.containsKey('kind'))
        request.uri.queryParameters['kind'],
  ];
}

/// Renders the page with [kinds] in a window wide enough for the side panel.
Future<void> _pump(
  WidgetTester tester, {
  required _Backend backend,
  Set<AssetKind> kinds = const {AssetKind.MODEL, AssetKind.BBMODEL},
  String title = 'Models',
  bool withProject = true,
  Future<PickedAssetFile?> Function()? pickFile,
}) async {
  // Wide enough for the side panel, which opens from 840 logical pixels on.
  tester.view.physicalSize = const Size(1200, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  ApiService().assetApi.apiClient.dio.httpClientAdapter = FakeHttpClientAdapter(
    backend.handle,
  );
  final store = Store<AppState>(
    initialState: withProject
        ? const AppState().copyWith(
            selectedProject: const Project(
              id: 'p-1',
              key: 'vulpes',
              displayName: 'Vulpes',
            ),
          )
        : const AppState(),
  );
  await tester.pumpWidget(
    StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 1000,
            height: 700,
            child: AssetLibraryPage(
              kinds: kinds,
              title: title,
              pickFile: pickFile ?? () async => null,
            ),
          ),
        ),
      ),
    ),
  );
}

/// Waits until [finder] shows up, letting the requests run.
Future<void> _waitFor(WidgetTester tester, Finder finder) => pumpUntil(
  tester,
  action: () async {},
  done: () => finder.evaluate().isNotEmpty,
);

/// Taps [finder] and pumps the frames of the reaction. Not settling, because a
/// preview that is still loading keeps a spinner running.
Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// Whether the preview of a model has finished loading, shown or failed.
bool _modelPreviewSettled() =>
    find.text(_unavailable).evaluate().isNotEmpty ||
    find.text(_previewFailed).evaluate().isNotEmpty;

/// The sha1 of the model the preview shows, null when no model is shown.
String? _shownSha1(WidgetTester tester) {
  final previews = find.byType(ItemModelPreview);
  if (previews.evaluate().isEmpty) return null;
  return tester.widget<ItemModelPreview>(previews).asset.sha1;
}

Map<String, Object?> _ruby() => _assetJson(
  id: 'm-1',
  key: _rubyModel,
  kind: 'MODEL',
  fileName: 'ruby.json',
);

Map<String, Object?> _sapphire() => _assetJson(
  id: 'b-1',
  key: _sapphireModel,
  kind: 'BBMODEL',
  fileName: 'sapphire.bbmodel',
);

Map<String, Object?> _gem() => _assetJson(
  id: 't-1',
  key: _gemTexture,
  kind: 'TEXTURE',
  fileName: 'gem.png',
);

void main() {
  setUp(() => AssetLibrary.shared.clearContents());

  testWidgets(
    'the models page lists models and Blockbench models, not textures',
    (tester) async {
      final backend = _Backend(assets: [_ruby(), _sapphire(), _gem()]);

      await _pump(tester, backend: backend);
      await _waitFor(tester, find.text(_sapphireModel));

      expect(backend.queriedKinds, unorderedEquals(['MODEL', 'BBMODEL']));
      expect(find.text(_rubyModel), findsOneWidget);
      expect(find.text(_sapphireModel), findsOneWidget);
      expect(
        find.text(_gemTexture),
        findsNothing,
        reason: 'textures belong to the textures page',
      );
    },
  );

  testWidgets('the textures page lists the textures of the project', (
    tester,
  ) async {
    final backend = _Backend(assets: [_ruby(), _gem()]);

    await _pump(
      tester,
      backend: backend,
      kinds: const {AssetKind.TEXTURE},
      title: 'Textures',
    );
    await _waitFor(tester, find.text(_gemTexture));

    expect(backend.queriedKinds, ['TEXTURE']);
    expect(find.text(_rubyModel), findsNothing);
  });

  testWidgets('selecting a texture shows the image in the preview', (
    tester,
  ) async {
    final backend = _Backend(assets: [_gem()]);
    await _pump(
      tester,
      backend: backend,
      kinds: const {AssetKind.TEXTURE},
      title: 'Textures',
    );
    await _waitFor(tester, find.text(_gemTexture));

    await _tap(tester, find.text(_gemTexture));
    final preview = find.byKey(const Key('asset_library_texture_preview'));
    await pumpUntil(
      tester,
      action: () async {},
      done: () => find
          .descendant(of: preview, matching: find.byType(Image))
          .evaluate()
          .isNotEmpty,
    );

    final image = tester.widget<Image>(
      find.descendant(of: preview, matching: find.byType(Image)),
    );
    expect(
      image.filterQuality,
      FilterQuality.none,
      reason: 'a texture is scaled up without smoothing',
    );
  });

  testWidgets('an upload adds the model to the list and selects it', (
    tester,
  ) async {
    final backend = _Backend(
      assets: [_ruby()],
      uploaded: _assetJson(
        id: 'm-2',
        key: _rubyGemModel,
        kind: 'MODEL',
        fileName: 'Ruby Gem.json',
      ),
    );
    await _pump(
      tester,
      backend: backend,
      pickFile: () async => PickedAssetFile(
        name: 'Ruby Gem.json',
        bytes: Uint8List.fromList([1, 2, 3]),
      ),
    );
    await _waitFor(tester, find.text(_rubyModel));

    await _tap(tester, find.byKey(const Key('asset_library_upload')));
    await _tap(tester, find.text('Upload a file'));
    await pumpUntil(
      tester,
      action: () async {},
      done: () => find.text('File: Ruby Gem.json').evaluate().isNotEmpty,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      _rubyGemModel,
      reason: 'the key is suggested from the file name',
    );

    await _tap(
      tester,
      find.descendant(of: find.byType(Dialog), matching: find.text('Upload')),
    );
    await pumpUntil(
      tester,
      action: () async {},
      done: () =>
          find.text(_rubyGemModel).evaluate().isNotEmpty &&
          _modelPreviewSettled(),
    );

    final upload = backend.requests.singleWhere((r) => r.method == 'POST');
    final form = upload.data as FormData;
    expect(
      form.fields.any(
        (field) => field.key == 'key' && field.value == _rubyGemModel,
      ),
      isTrue,
      reason: 'the upload carries the key',
    );
    expect(
      find.byKey(const Key('item_model_preview')),
      findsOneWidget,
      reason: 'the uploaded model is selected and previewed',
    );
    expect(
      find.text('Upload an asset'),
      findsNothing,
      reason: 'the dialog closes',
    );
  });

  testWidgets(
    'a key already in use keeps the upload open and shows the conflict',
    (tester) async {
      final backend = _Backend(
        assets: [_ruby()],
        uploadProblem: {
          'title': 'Conflict',
          'status': 409,
          'detail': 'The key is already in use.',
          'code': 'CONFLICT',
          'errors': [
            {
              'field': 'key',
              'code': 'ASSET_KEY_CONFLICT',
              'message': 'Key is already in use',
            },
          ],
        },
      );
      await _pump(
        tester,
        backend: backend,
        pickFile: () async =>
            PickedAssetFile(name: 'ruby.json', bytes: Uint8List.fromList([1])),
      );
      await _waitFor(tester, find.text(_rubyModel));

      await _tap(tester, find.byKey(const Key('asset_library_upload')));
      await _tap(tester, find.text('Upload a file'));
      await pumpUntil(
        tester,
        action: () async {},
        done: () => find.text('File: ruby.json').evaluate().isNotEmpty,
      );
      await _tap(
        tester,
        find.descendant(of: find.byType(Dialog), matching: find.text('Upload')),
      );
      await _waitFor(tester, find.text('Key is already in use'));

      expect(
        find.text('Upload an asset'),
        findsOneWidget,
        reason: 'the dialog stays open so the key can be changed',
      );
      expect(
        find.text(_rubyGemModel),
        findsNothing,
        reason: 'nothing was added',
      );
    },
  );

  testWidgets(
    'a resumed app lists the models again and previews the model saved last',
    (tester) async {
      // Own sha1s: the downloaded contents are cached by sha1 for the run.
      final backend = _Backend(
        assets: [
          _assetJson(
            id: 'm-1',
            key: _rubyModel,
            kind: 'MODEL',
            fileName: 'ruby.json',
            sha1: 'sha-resume-old',
          ),
        ],
      );
      await _pump(tester, backend: backend);
      await _waitFor(tester, find.text(_rubyModel));
      await _tap(tester, find.text(_rubyModel));
      await pumpUntil(tester, action: () async {}, done: _modelPreviewSettled);
      final listsBefore = backend.queriedKinds.where((k) => k == 'MODEL');
      final contentBefore = backend.requestsTo('/m-1/content');

      // Saved again in Blockbench under the same key: a new sha1.
      backend.assets[0] = _assetJson(
        id: 'm-1',
        key: _rubyModel,
        kind: 'MODEL',
        fileName: 'ruby.json',
        sha1: 'sha-resume-new',
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await pumpUntil(
        tester,
        action: () async {},
        done: () =>
            backend.queriedKinds.where((k) => k == 'MODEL').length >
                listsBefore.length &&
            _shownSha1(tester) == 'sha-resume-new' &&
            backend.requestsTo('/m-1/content') > contentBefore,
      );

      expect(
        backend.requestsTo('/m-1/content'),
        contentBefore + 1,
        reason: 'the preview loads the model saved last',
      );
      expect(
        find.byKey(const Key('item_model_preview')),
        findsOneWidget,
        reason: 'the selection is kept',
      );
    },
  );

  testWidgets('without a selected project the page shows the empty state', (
    tester,
  ) async {
    final backend = _Backend(assets: [_ruby()]);

    await _pump(tester, backend: backend, withProject: false);
    await tester.pump();

    expect(find.text('Open a project to see its assets.'), findsOneWidget);
    expect(backend.requests, isEmpty, reason: 'nothing is requested');
  });
}
