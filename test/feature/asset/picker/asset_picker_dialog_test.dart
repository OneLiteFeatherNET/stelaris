import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/feature/asset/picker/asset_picker_dialog.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/feature/asset/preview/texture_preview.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';
import '../../../support/pump_until.dart';

const _rubyModel = 'vulpes:item/ruby';
const _gemKey = 'minecraft:item/ruby_gem';

Map<String, Object?> _assetJson({
  required String id,
  required String key,
  required String kind,
  String? displayName,
  String? fileName,
  int? width,
  int? height,
  String? sourceAssetId,
  String sha1 = 'bbbb',
}) => {
  'id': id,
  'projectId': 'p-1',
  'key': key,
  'displayName': displayName ?? key,
  'kind': kind,
  'fileName': fileName ?? '$id.json',
  'contentType': 'application/json',
  'size': 512,
  'sha1': sha1,
  'derivedAssetIds': <String>[],
  'width': ?width,
  'height': ?height,
  'sourceAssetId': ?sourceAssetId,
};

/// Answers the picker's requests: the list per kind, and the upload with [upload].
class _Backend {
  _Backend({
    this.models = const [],
    this.bbmodels = const [],
    this.textures = const [],
    this.listStatus = 200,
    this.upload,
  });

  final List<Map<String, Object?>> models;
  final List<Map<String, Object?>> bbmodels;
  final List<Map<String, Object?>> textures;
  final int listStatus;
  final ResponseBody Function(RequestOptions options)? upload;

  final List<RequestOptions> requests = [];

  ResponseBody handle(RequestOptions options) {
    requests.add(options);
    if (options.method == 'POST') return upload!(options);
    if (listStatus != 200) {
      return FakeHttpClientAdapter.response({
        'title': 'Server error',
        'status': listStatus,
        'detail': 'The server is down.',
      }, statusCode: listStatus);
    }
    final kind = options.uri.queryParameters['kind'];
    final items = switch (kind) {
      'MODEL' => models,
      'BBMODEL' => bbmodels,
      'TEXTURE' => textures,
      _ => const <Map<String, Object?>>[],
    };
    return FakeHttpClientAdapter.response({
      'items': items,
      'totalItems': items.length,
      'totalPages': 1,
      'currentPage': 0,
      'pageSize': 50,
    });
  }

  List<String?> get queriedKinds => [
    for (final request in requests)
      if (request.method == 'GET') request.uri.queryParameters['kind'],
  ];
}

/// What the dialog resolved with. [closed] is false while it stays open.
class _Outcome {
  bool closed = false;
  AssetModel? asset;
}

Future<void> _open(
  WidgetTester tester, {
  required _Backend backend,
  required _Outcome outcome,
  Future<PickedAssetFile?> Function()? pickFile,
  String? selectedKey,
  Widget Function(AssetModel asset)? previewBuilder,
  bool texture = false,
  bool hideExtracted = false,
  bool replaceable = false,
}) async {
  ApiService().assetApi.apiClient.dio.httpClientAdapter = FakeHttpClientAdapter(
    backend.handle,
  );
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              outcome.asset = await showAssetPickerDialog(
                context,
                projectId: 'p-1',
                selectedKey: selectedKey,
                previewBuilder: previewBuilder,
                namespace: texture ? 'cygnus' : null,
                kinds: texture ? textureAssetKinds : modelAssetKinds,
                uploadKinds: texture
                    ? textureAssetKinds
                    : const {...AssetKind.values},
                keyFolder: texture ? 'font' : 'item',
                hideExtracted: hideExtracted,
                replaceable: replaceable,
                pickFile: pickFile ?? () async => null,
              );
              outcome.closed = true;
            },
            child: const Text('open picker'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open picker'));
  await tester.pumpAndSettle();
}

/// Waits until [finder] shows up, letting the requests run.
Future<void> _waitFor(WidgetTester tester, Finder finder) => pumpUntil(
  tester,
  action: () async {},
  done: () => finder.evaluate().isNotEmpty,
);

Future<void> _tap(WidgetTester tester, String text) =>
    _tapFinder(tester, find.text(text));

Future<void> _tapFinder(WidgetTester tester, Finder finder) async {
  // The upload form can push its buttons below the dialog's fold.
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Switches the picker to its upload.
Future<void> _openUpload(WidgetTester tester) async {
  await _waitFor(tester, find.byKey(const Key('asset_picker_upload')));
  await _tapFinder(tester, find.byKey(const Key('asset_picker_upload')));
}

/// Confirms the upload.
Future<void> _confirmUpload(WidgetTester tester) =>
    _tapFinder(tester, find.text('Upload'));

void main() {
  final models = [
    _assetJson(
      id: 'm-1',
      key: _rubyModel,
      kind: 'MODEL',
      fileName: 'ruby.json',
    ),
  ];
  final bbmodels = [
    _assetJson(
      id: 'b-1',
      key: 'vulpes:item/sapphire',
      kind: 'BBMODEL',
      fileName: 'sapphire.bbmodel',
    ),
  ];

  testWidgets('lists the models and Blockbench models of the project', (
    tester,
  ) async {
    final backend = _Backend(models: models, bbmodels: bbmodels);
    final outcome = _Outcome();

    await _open(tester, backend: backend, outcome: outcome);
    await _waitFor(tester, find.text('vulpes:item/sapphire'));

    expect(backend.queriedKinds, unorderedEquals(['MODEL', 'BBMODEL']));
    expect(find.text(_rubyModel), findsOneWidget);
    expect(find.text('vulpes:item/sapphire'), findsOneWidget);
  });

  testWidgets('names each asset by its name over its key and kind', (
    tester,
  ) async {
    final backend = _Backend(
      models: [
        _assetJson(
          id: 'm-1',
          key: _rubyModel,
          kind: 'MODEL',
          displayName: 'Red Ruby',
        ),
      ],
    );
    final outcome = _Outcome();

    await _open(tester, backend: backend, outcome: outcome);
    await _waitFor(tester, find.text('Red Ruby'));

    expect(find.text('$_rubyModel · Model'), findsOneWidget);
  });

  testWidgets('choosing a model and confirming returns that model', (
    tester,
  ) async {
    final outcome = _Outcome();
    await _open(
      tester,
      backend: _Backend(models: models),
      outcome: outcome,
    );
    await _waitFor(tester, find.text(_rubyModel));

    await _tap(tester, _rubyModel);
    await _tap(tester, 'Choose');

    expect(outcome.closed, isTrue, reason: 'choosing must close the dialog');
    expect(outcome.asset?.key, _rubyModel);
  });

  testWidgets('cancelling returns null', (tester) async {
    final outcome = _Outcome();
    await _open(
      tester,
      backend: _Backend(models: models),
      outcome: outcome,
    );
    await _waitFor(tester, find.text(_rubyModel));

    await _tap(tester, 'Cancel');

    expect(outcome.closed, isTrue);
    expect(outcome.asset, isNull);
  });

  testWidgets('choosing shows the preview of the selected model', (
    tester,
  ) async {
    await _open(
      tester,
      backend: _Backend(models: models),
      outcome: _Outcome(),
      previewBuilder: (asset) => Text('preview of ${asset.key}'),
    );
    await _waitFor(tester, find.text(_rubyModel));

    await _tap(tester, _rubyModel);

    expect(find.text('preview of $_rubyModel'), findsOneWidget);
  });

  testWidgets('a failed list request shows the error and a retry', (
    tester,
  ) async {
    await _open(
      tester,
      backend: _Backend(listStatus: 500),
      outcome: _Outcome(),
    );
    await _waitFor(tester, find.text('Try again'));

    expect(find.text('The models could not be loaded.'), findsOneWidget);
    expect(find.text('The server is down.'), findsOneWidget);
  });

  testWidgets(
    'the upload takes the place of the list, is prefilled with the suggested '
    'key and selects the new model',
    (tester) async {
      final backend = _Backend(
        models: models,
        upload: (_) => FakeHttpClientAdapter.response(
          _assetJson(
            id: 'b-2',
            key: _gemKey,
            kind: 'BBMODEL',
            fileName: 'Ruby Gem.bbmodel',
          ),
          statusCode: 201,
        ),
      );
      final outcome = _Outcome();
      await _open(
        tester,
        backend: backend,
        outcome: outcome,
        pickFile: () async => PickedAssetFile(
          name: 'Ruby Gem.bbmodel',
          bytes: Uint8List.fromList([1, 2, 3]),
        ),
      );
      await _waitFor(tester, find.text(_rubyModel));
      expect(
        find.text('Choose a file'),
        findsNothing,
        reason: 'the picker only lists, the upload has its own dialog',
      );

      await _openUpload(tester);
      expect(find.text('Upload a model'), findsOneWidget);
      expect(find.text(_rubyModel), findsNothing, reason: 'the list is gone');
      await _tap(tester, 'Choose a file');
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('asset_upload_key')))
            .controller!
            .text,
        'item/ruby_gem',
      );

      await _confirmUpload(tester);
      await _waitFor(tester, find.text(_gemKey));

      final upload = backend.requests.singleWhere((r) => r.method == 'POST');
      expect(upload.uri.path, endsWith('/project/p-1/asset'));
      final form = upload.data as FormData;
      expect(
        form.fields.any(
          (field) => field.key == 'key' && field.value == _gemKey,
        ),
        isTrue,
        reason: 'the multipart form carries the edited key',
      );
      expect(form.files.single.value.filename, 'Ruby Gem.bbmodel');
      expect(find.text('Upload a model'), findsNothing);
      expect(find.text('Choose a model'), findsOneWidget);
      expect(outcome.closed, isFalse, reason: 'back in the list');

      await _tap(tester, 'Choose');

      expect(
        outcome.asset?.key,
        _gemKey,
        reason: 'the uploaded model is selected',
      );
    },
  );

  testWidgets(
    'a key already in use keeps the upload open and shows the conflict',
    (tester) async {
      final outcome = _Outcome();
      await _open(
        tester,
        backend: _Backend(
          models: models,
          upload: (_) => FakeHttpClientAdapter.response({
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
          }, statusCode: 409),
        ),
        outcome: outcome,
        pickFile: () async =>
            PickedAssetFile(name: 'ruby.json', bytes: Uint8List.fromList([1])),
      );

      await _openUpload(tester);
      await _tap(tester, 'Choose a file');
      await _confirmUpload(tester);
      await _waitFor(tester, find.text('Key is already in use'));

      expect(
        find.text('Upload a model'),
        findsOneWidget,
        reason: 'the upload stays open',
      );
      expect(outcome.closed, isFalse);
    },
  );

  testWidgets('a rejected file shows the reason under the file', (
    tester,
  ) async {
    await _open(
      tester,
      backend: _Backend(
        upload: (_) => FakeHttpClientAdapter.response({
          'title': 'Validation failed',
          'status': 400,
          'code': 'VALIDATION_FAILED',
          'errors': [
            {'field': 'file', 'message': 'The file is not a model'},
          ],
        }, statusCode: 400),
      ),
      outcome: _Outcome(),
      pickFile: () async =>
          PickedAssetFile(name: 'broken.json', bytes: Uint8List.fromList([1])),
    );

    await _openUpload(tester);
    await _tap(tester, 'Choose a file');
    await _confirmUpload(tester);
    await _waitFor(tester, find.text('The file is not a model'));

    expect(find.text('Upload a model'), findsOneWidget);
  });

  testWidgets('going back drops the upload and shows the list again', (
    tester,
  ) async {
    final backend = _Backend(models: models);
    final outcome = _Outcome();
    await _open(
      tester,
      backend: backend,
      outcome: outcome,
      pickFile: () async =>
          PickedAssetFile(name: 'ruby.json', bytes: Uint8List.fromList([1])),
    );

    await _openUpload(tester);
    await _tap(tester, 'Choose a file');
    await _tapFinder(tester, find.byKey(const Key('asset_picker_back')));

    expect(find.text(_rubyModel), findsOneWidget);
    expect(outcome.closed, isFalse);
    expect(backend.requests.where((r) => r.method == 'POST'), isEmpty);
    expect(backend.queriedKinds, hasLength(2), reason: 'no reload');

    await _openUpload(tester);
    expect(
      find.text('Choose a file'),
      findsOneWidget,
      reason: 'a new upload starts without the dropped file',
    );
  });

  testWidgets('an uploaded texture is reported but not chosen', (tester) async {
    final outcome = _Outcome();
    await _open(
      tester,
      backend: _Backend(
        upload: (_) => FakeHttpClientAdapter.response(
          _assetJson(
            id: 't-1',
            key: 'vulpes:item/gem',
            kind: 'TEXTURE',
            fileName: 'gem.png',
          ),
          statusCode: 201,
        ),
      ),
      outcome: outcome,
      pickFile: () async =>
          PickedAssetFile(name: 'gem.png', bytes: Uint8List.fromList([1])),
    );

    await _openUpload(tester);
    await _tap(tester, 'Choose a file');
    await _confirmUpload(tester);
    await _waitFor(
      tester,
      find.text(
        'Uploaded the texture vulpes:item/gem. Only models can be chosen for an item.',
      ),
    );
    await _tap(tester, 'Choose');

    expect(
      outcome.closed,
      isFalse,
      reason: 'nothing is chosen, so Choose does nothing',
    );
  });

  group('embedded', () {
    Future<List<String>> pumpEmbedded(WidgetTester tester) async {
      final calls = <String>[];
      ApiService().assetApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter(_Backend(models: models).handle);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AssetPicker(
              projectId: 'p-1',
              embedded: true,
              onPicked: (asset) => calls.add('picked ${asset.key}'),
              onCancel: () => calls.add('cancel'),
              pickFile: () async => null,
            ),
          ),
        ),
      );
      await _waitFor(tester, find.text(_rubyModel));
      return calls;
    }

    testWidgets('the back button and Cancel lead back', (tester) async {
      final calls = await pumpEmbedded(tester);

      await _tapFinder(tester, find.byKey(const Key('asset_picker_back')));
      await _tap(tester, 'Cancel');

      expect(calls, ['cancel', 'cancel']);
    });

    testWidgets('choosing hands the asset on', (tester) async {
      final calls = await pumpEmbedded(tester);

      await _tap(tester, _rubyModel);
      await _tap(tester, 'Choose');

      expect(calls, ['picked $_rubyModel']);
    });

    testWidgets('Cancel in the upload goes back to the list', (tester) async {
      final calls = await pumpEmbedded(tester);

      await _openUpload(tester);
      await _tap(tester, 'Cancel');

      expect(find.text(_rubyModel), findsOneWidget);
      expect(calls, isEmpty);
    });
  });

  group('texture', () {
    final ghost = _assetJson(
      id: 't-1',
      key: 'cygnus:font/ghost',
      kind: 'TEXTURE',
      fileName: 'ghost.png',
      width: 32,
      height: 32,
    );

    testWidgets('lists only the textures, with their size', (tester) async {
      final backend = _Backend(models: models, textures: [ghost]);
      await _open(tester, backend: backend, outcome: _Outcome(), texture: true);
      await _waitFor(
        tester,
        find.text('cygnus:font/ghost · Texture · 32 × 32'),
      );

      expect(backend.queriedKinds, ['TEXTURE']);
      expect(find.text('Choose a texture'), findsOneWidget);
      expect(find.text(_rubyModel), findsNothing);
    });

    testWidgets('hides the textures extracted from a Blockbench model', (
      tester,
    ) async {
      final extracted = _assetJson(
        id: 't-2',
        key: 'cygnus:item/sapphire_skin',
        kind: 'TEXTURE',
        sourceAssetId: 'b-1',
      );
      await _open(
        tester,
        backend: _Backend(textures: [ghost, extracted]),
        outcome: _Outcome(),
        texture: true,
        hideExtracted: true,
      );
      await _waitFor(tester, find.text('cygnus:font/ghost'));

      expect(find.textContaining('sapphire_skin'), findsNothing);
    });

    testWidgets('an empty list names the textures and offers the upload', (
      tester,
    ) async {
      await _open(
        tester,
        backend: _Backend(),
        outcome: _Outcome(),
        texture: true,
      );
      await _waitFor(tester, find.text('This project has no textures yet.'));

      expect(find.byKey(const Key('asset_picker_upload')), findsOneWidget);
    });

    testWidgets('suggests the key in the given folder', (tester) async {
      await _open(
        tester,
        backend: _Backend(),
        outcome: _Outcome(),
        texture: true,
        pickFile: () async =>
            PickedAssetFile(name: 'Ghost.png', bytes: Uint8List.fromList([1])),
      );

      await _openUpload(tester);
      await _tap(tester, 'Choose a file');

      expect(find.text('Upload a texture'), findsOneWidget);
      expect(find.text('font/ghost'), findsOneWidget);
      expect(
        find.text('The path in the resource pack, e.g. font/ruby'),
        findsOneWidget,
      );
    });

    testWidgets('the upload shows the chosen texture', (tester) async {
      await _open(
        tester,
        backend: _Backend(),
        outcome: _Outcome(),
        texture: true,
        pickFile: () async =>
            PickedAssetFile(name: 'ghost.png', bytes: Uint8List.fromList([1])),
      );

      await _openUpload(tester);
      expect(find.byType(TexturePreview), findsNothing);
      await _tap(tester, 'Choose a file');

      expect(find.byType(TexturePreview), findsOneWidget);
    });

    testWidgets('an uploaded texture is selected for Choose', (tester) async {
      final outcome = _Outcome();
      await _open(
        tester,
        backend: _Backend(
          upload: (_) => FakeHttpClientAdapter.response(ghost, statusCode: 201),
        ),
        outcome: outcome,
        texture: true,
        pickFile: () async =>
            PickedAssetFile(name: 'ghost.png', bytes: Uint8List.fromList([1])),
      );

      await _openUpload(tester);
      await _tap(tester, 'Choose a file');
      await _confirmUpload(tester);
      await _waitFor(tester, find.text('cygnus:font/ghost'));
      await _tap(tester, 'Choose');

      expect(outcome.closed, isTrue);
      expect(outcome.asset?.key, 'cygnus:font/ghost');
    });

    group('new version', () {
      Future<void> openAndSelect(
        WidgetTester tester,
        _Backend backend, {
        bool replaceable = true,
      }) async {
        await _open(
          tester,
          backend: backend,
          outcome: _Outcome(),
          texture: true,
          replaceable: replaceable,
          pickFile: () async => PickedAssetFile(
            name: 'ghost.png',
            bytes: Uint8List.fromList([7]),
          ),
        );
        await _waitFor(tester, find.text('cygnus:font/ghost'));
        await _tap(tester, 'cygnus:font/ghost');
      }

      testWidgets('replaces the file of the selected texture', (tester) async {
        final backend = _Backend(
          textures: [ghost],
          upload: (_) => FakeHttpClientAdapter.response(
            _assetJson(
              id: 't-1',
              key: 'cygnus:font/ghost',
              kind: 'TEXTURE',
              displayName: 'Ghost',
              sha1: 'cccc',
            ),
          ),
        );
        await openAndSelect(tester, backend);

        await _tap(tester, 'Upload new version');
        expect(find.text('New version of cygnus:font/ghost'), findsOneWidget);
        await _tap(tester, 'Choose a file');
        expect(
          find.byKey(const Key('asset_upload_key')),
          findsNothing,
          reason: 'a new version keeps the key and name',
        );
        expect(find.byKey(const Key('asset_upload_name')), findsNothing);

        await _confirmUpload(tester);
        await _waitFor(tester, find.text('Stored a new version of Ghost.'));

        final replace = backend.requests.singleWhere((r) => r.method == 'POST');
        expect(replace.uri.path, endsWith('/project/p-1/asset/t-1/content'));
        expect(replace.headers['If-Match'], '"bbbb"');
      });

      testWidgets('a conflict names the texture and closing loads the list '
          'anew', (tester) async {
        final backend = _Backend(
          textures: [ghost],
          upload: (_) => FakeHttpClientAdapter.response({
            'title': 'Precondition failed',
            'status': 412,
          }, statusCode: 412),
        );
        await openAndSelect(tester, backend);

        await _tap(tester, 'Upload new version');
        await _tap(tester, 'Choose a file');
        await _confirmUpload(tester);
        await _waitFor(
          tester,
          find.text(
            'cygnus:font/ghost was changed meanwhile. '
            'Go back to see the stored version.',
          ),
        );
        await _tapFinder(tester, find.byKey(const Key('asset_picker_back')));
        await _waitFor(tester, find.text('cygnus:font/ghost'));

        expect(backend.queriedKinds, ['TEXTURE', 'TEXTURE']);
      });

      testWidgets('is not offered unless the picker allows it', (tester) async {
        await openAndSelect(
          tester,
          _Backend(textures: [ghost]),
          replaceable: false,
        );

        expect(find.text('Upload new version'), findsNothing);
      });
    });
  });
}
