import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/feature/asset/upload/asset_upload_controller.dart';
import 'package:stelaris/feature/asset/upload/asset_upload_form.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';

PickedAssetFile _file(String name, [int size = 3]) =>
    PickedAssetFile(name: name, bytes: Uint8List(size));

/// Shows the form of a controller whose file dialog answers with the next of
/// [picks], or fails for a pick that is null.
Future<AssetUploadController> _pump(
  WidgetTester tester, {
  List<PickedAssetFile?> picks = const [],
  Set<AssetKind> kinds = const {...AssetKind.values},
  String? fixedKey,
}) async {
  final queue = [...picks];
  final controller = AssetUploadController(
    projectId: 'p-1',
    namespace: 'vulpes',
    kinds: kinds,
    fixedKey: fixedKey,
    pickFile: () async =>
        queue.removeAt(0) ?? (throw StateError('the file was not readable')),
  );
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: AssetUploadForm(controller: controller)),
    ),
  );
  return controller;
}

Future<void> _choose(WidgetTester tester) async {
  await tester.tap(find.text('Choose a file'));
  await tester.pumpAndSettle();
}

TextField _keyField(WidgetTester tester) =>
    tester.widget<TextField>(find.byKey(const Key('asset_upload_key')));

TextField _nameField(WidgetTester tester) =>
    tester.widget<TextField>(find.byKey(const Key('asset_upload_name')));

void main() {
  testWidgets('asks for a file until one is chosen', (tester) async {
    await _pump(tester);

    expect(find.byKey(const Key('asset_upload_drop_zone')), findsOneWidget);
    expect(find.text('Drag a file here'), findsOneWidget);
    expect(find.byKey(const Key('asset_upload_key')), findsNothing);
  });

  testWidgets(
    'a chosen file shows its kind and size and suggests name and key',
    (tester) async {
      final controller = await _pump(
        tester,
        picks: [_file('Ruby Gem.bbmodel', 2048)],
      );

      await _choose(tester);

      expect(find.text('Ruby Gem.bbmodel'), findsOneWidget);
      expect(find.text('Blockbench model · 2.0 KB'), findsOneWidget);
      expect(_nameField(tester).controller!.text, 'Ruby Gem');
      expect(_keyField(tester).controller!.text, 'item/ruby_gem');
      expect(_keyField(tester).decoration!.prefixText, 'vulpes:');
      expect(
        _nameField(tester).focusNode!.hasFocus,
        isTrue,
        reason: 'the suggested name is what the user checks next',
      );
      expect(controller.canUpload, isTrue);
    },
  );

  testWidgets('another file replaces the chosen one and its key', (
    tester,
  ) async {
    await _pump(tester, picks: [_file('ruby.json'), _file('gem.png')]);
    await _choose(tester);

    await tester.tap(find.byTooltip('Choose another file'));
    await tester.pumpAndSettle();

    expect(find.text('ruby.json'), findsNothing);
    expect(find.text('Texture · 3 B'), findsOneWidget);
    expect(_nameField(tester).controller!.text, 'Gem');
    expect(_keyField(tester).controller!.text, 'item/gem');
  });

  testWidgets('a typed name stays when another file is chosen', (tester) async {
    await _pump(tester, picks: [_file('ruby.json'), _file('gem.png')]);
    await _choose(tester);
    await tester.enterText(
      find.byKey(const Key('asset_upload_name')),
      'Red Ruby',
    );

    await tester.tap(find.byTooltip('Choose another file'));
    await tester.pumpAndSettle();

    expect(_nameField(tester).controller!.text, 'Red Ruby');
  });

  testWidgets('a missing name is explained and blocks the upload', (
    tester,
  ) async {
    final controller = await _pump(tester, picks: [_file('ruby.json')]);
    await _choose(tester);

    await tester.enterText(find.byKey(const Key('asset_upload_name')), '  ');
    await tester.pump();

    expect(find.text('Enter a name.'), findsOneWidget);
    expect(controller.canUpload, isFalse);
  });

  testWidgets('removing the file asks for one again', (tester) async {
    final controller = await _pump(tester, picks: [_file('ruby.json')]);
    await _choose(tester);

    await tester.tap(find.byTooltip('Remove the file'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('asset_upload_drop_zone')), findsOneWidget);
    expect(controller.file, isNull);
  });

  testWidgets('a dropped file is taken like a chosen one', (tester) async {
    final controller = await _pump(tester);

    await controller.drop(Future.value(_file('ruby.json')));
    await tester.pumpAndSettle();

    expect(find.text('ruby.json'), findsOneWidget);
    expect(_keyField(tester).controller!.text, 'item/ruby');
  });

  testWidgets('a file of another type can not be uploaded', (tester) async {
    final controller = await _pump(tester, picks: [_file('notes.txt')]);

    await _choose(tester);

    expect(
      find.text('Only .png, .json and .bbmodel files can be uploaded.'),
      findsOneWidget,
    );
    expect(controller.canUpload, isFalse);
  });

  testWidgets('an upload of models names only model files', (tester) async {
    final controller = await _pump(
      tester,
      kinds: {AssetKind.MODEL, AssetKind.BBMODEL},
      picks: [_file('ruby.png')],
    );

    expect(
      find.text('Model JSON or Blockbench models (.bbmodel)'),
      findsOneWidget,
    );
    await _choose(tester);

    expect(
      find.text('Only .json and .bbmodel files can be uploaded here.'),
      findsOneWidget,
    );
    expect(controller.canUpload, isFalse);
  });

  testWidgets('a fixed key stays and can not be edited', (tester) async {
    final controller = await _pump(
      tester,
      kinds: {AssetKind.TEXTURE},
      fixedKey: 'vulpes:item/ruby_glow',
      picks: [_file('glow.png')],
    );

    await _choose(tester);

    expect(_keyField(tester).controller!.text, 'vulpes:item/ruby_glow');
    expect(_keyField(tester).decoration!.prefixText, isNull);
    expect(_keyField(tester).readOnly, isTrue);
    expect(controller.canUpload, isTrue);
  });

  testWidgets('a file that can not be read says so', (tester) async {
    final controller = await _pump(tester, picks: [null]);

    await _choose(tester);

    expect(find.text('The file could not be read.'), findsOneWidget);
    expect(controller.file, isNull);
  });

  testWidgets('only the path is typed and goes up behind the namespace', (
    tester,
  ) async {
    RequestOptions? request;
    ApiService().assetApi.apiClient.dio.httpClientAdapter =
        FakeHttpClientAdapter((RequestOptions options) {
          request = options;
          return FakeHttpClientAdapter.response({
            'title': 'Conflict',
            'status': 409,
          }, statusCode: 409);
        });
    final controller = await _pump(tester, picks: [_file('ruby.json')]);
    await _choose(tester);

    await tester.enterText(
      find.byKey(const Key('asset_upload_key')),
      'item/red ruby',
    );
    await tester.pump();

    expect(
      find.text('The path may only contain a-z, 0-9, _, ., - and /.'),
      findsOneWidget,
    );
    expect(controller.canUpload, isFalse);

    await tester.enterText(
      find.byKey(const Key('asset_upload_key')),
      'item/red_ruby',
    );
    await tester.pump();
    expect(controller.canUpload, isTrue);

    await tester.runAsync(controller.upload);
    final fields = Map.fromEntries((request!.data as FormData).fields);
    expect(fields['key'], 'vulpes:item/red_ruby');
  });

  testWidgets('an empty path is explained and blocks the upload', (
    tester,
  ) async {
    final controller = await _pump(tester, picks: [_file('ruby.json')]);
    await _choose(tester);

    await tester.enterText(find.byKey(const Key('asset_upload_key')), ' ');
    await tester.pump();

    expect(find.text('Enter a key.'), findsOneWidget);
    expect(controller.canUpload, isFalse);
  });

  testWidgets('the reason of the backend against the key goes on an edit', (
    tester,
  ) async {
    ApiService().assetApi.apiClient.dio.httpClientAdapter =
        FakeHttpClientAdapter(
          (RequestOptions _) => FakeHttpClientAdapter.response({
            'title': 'Conflict',
            'status': 409,
            'detail': 'The key is already in use.',
          }, statusCode: 409),
        );
    final controller = await _pump(tester, picks: [_file('ruby.json')]);
    await _choose(tester);

    expect(await tester.runAsync(controller.upload), isNull);
    await tester.pump();
    expect(find.text('The key is already in use.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('asset_upload_key')),
      'item/ruby_2',
    );
    await tester.pump();

    expect(find.text('The key is already in use.'), findsNothing);
  });

  testWidgets('the name goes up with the file and the backend reason against '
      'it goes on an edit', (tester) async {
    RequestOptions? request;
    ApiService().assetApi.apiClient.dio.httpClientAdapter =
        FakeHttpClientAdapter((RequestOptions options) {
          request = options;
          return FakeHttpClientAdapter.response({
            'title': 'Validation failed',
            'status': 400,
            'errors': [
              {'field': 'displayName', 'message': 'The name is too long'},
            ],
          }, statusCode: 400);
        });
    final controller = await _pump(tester, picks: [_file('ruby.json')]);
    await _choose(tester);

    expect(await tester.runAsync(controller.upload), isNull);
    await tester.pump();
    final fields = Map.fromEntries((request!.data as FormData).fields);
    expect(fields['displayName'], 'Ruby');
    expect(find.text('The name is too long'), findsOneWidget);
    expect(controller.uploadError, isNull);

    await tester.enterText(find.byKey(const Key('asset_upload_name')), 'Rubin');
    await tester.pump();

    expect(find.text('The name is too long'), findsNothing);
  });

  test('formats file sizes in B, KB and MB', () {
    expect(formatFileSize(512), '512 B');
    expect(formatFileSize(1536), '1.5 KB');
    expect(formatFileSize(3 * 1024 * 1024), '3.0 MB');
  });
}
