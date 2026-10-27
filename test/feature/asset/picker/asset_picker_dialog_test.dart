import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/feature/asset/picker/asset_picker_dialog.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
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
  String? fileName,
}) => {
  'id': id,
  'projectId': 'p-1',
  'key': key,
  'kind': kind,
  'fileName': fileName ?? '$id.json',
  'contentType': 'application/json',
  'size': 512,
  'sha1': 'bbbb',
  'derivedAssetIds': <String>[],
};

/// Answers the picker's requests: the list per kind, and the upload with [upload].
class _Backend {
  _Backend({
    this.models = const [],
    this.bbmodels = const [],
    this.listStatus = 200,
    this.upload,
  });

  final List<Map<String, Object?>> models;
  final List<Map<String, Object?>> bbmodels;
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

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

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
    'an upload is prefilled with the suggested key and selects the new model',
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

      await _tap(tester, 'Choose a file');
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'minecraft:item/ruby_gem',
      );

      await _tap(tester, 'Upload');
      await _waitFor(tester, find.text(_gemKey));
      await _tap(tester, 'Choose');

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
      expect(
        outcome.asset?.key,
        _gemKey,
        reason: 'the uploaded model is chosen',
      );
    },
  );

  testWidgets(
    'a key already in use keeps the dialog open and shows the conflict',
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
      await _waitFor(tester, find.text(_rubyModel));

      await _tap(tester, 'Choose a file');
      await _tap(tester, 'Upload');
      await _waitFor(tester, find.text('Key is already in use'));

      expect(
        find.text('Choose a model'),
        findsOneWidget,
        reason: 'the dialog stays open',
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
    await _waitFor(tester, find.text('Choose a file'));

    await _tap(tester, 'Choose a file');
    await _tap(tester, 'Upload');
    await _waitFor(tester, find.text('The file is not a model'));

    expect(find.text('Choose a model'), findsOneWidget);
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
    await _waitFor(tester, find.text('Choose a file'));

    await _tap(tester, 'Choose a file');
    await _tap(tester, 'Upload');
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
}
