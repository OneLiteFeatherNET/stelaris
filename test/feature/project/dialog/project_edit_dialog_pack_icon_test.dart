import 'dart:typed_data';

import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/feature/component/minimessage_field.dart';
import 'package:stelaris/feature/project/dialog/project_edit_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_asset_client_api.dart';
import '../../../support/fake_http_client_adapter.dart';
import '../../../support/fake_pack_meta_api.dart';
import '../../../support/pack_icon_pngs.dart';
import '../../../support/pump_until.dart';

void main() {
  const project = Project(id: 'p1', displayName: 'Project', key: 'proj');
  const existing = PackMeta(
    id: 'meta-1',
    projectId: 'p1',
    packType: PackType.resource,
    description: '"My pack"',
    minFormatMajor: 46,
    maxFormatMajor: 48,
  );
  final iconAsset = FakeAssetClientApi.texture('icon-1');
  final withIcon = existing.copyWith(iconAssetId: iconAsset.id);

  setUp(() {
    // The project save echoes the sent project.
    ApiService().projectApi.apiClient.dio.httpClientAdapter =
        FakeHttpClientAdapter(
          (options) => FakeHttpClientAdapter.response(options.data),
        );
  });

  FakeAssetClientApi storedIcon() =>
      FakeAssetClientApi(stored: {iconAsset: png16});

  Future<void> pumpDialog(
    WidgetTester tester,
    FakePackMetaApi packMetaApi,
    FakeAssetClientApi assetApi, {
    Uint8List? picked,
    void Function(Object? result)? onResult,
  }) async {
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: Store<AppState>(
          initialState: const AppState(
            projects: [project],
            selectedProject: project,
          ),
        ),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  final result = await showDialog<Object>(
                    context: context,
                    builder: (_) => EditProjectDialog(
                      project: project,
                      packMetaApi: packMetaApi,
                      assetApi: assetApi,
                      pickIcon: () async => picked == null
                          ? null
                          : PickedAssetFile(name: 'icon.png', bytes: picked),
                    ),
                  );
                  onResult?.call(result);
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(Tab, 'Pack'));
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester, bool Function() done) => pumpUntil(
    tester,
    action: () => tester.tap(find.text('Save')),
    done: done,
  );

  Future<void> tapButton(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);
  final description = find.descendant(
    of: find.byType(MiniMessageField),
    matching: find.byType(EditableText),
  );
  final iconImage = find.byKey(const Key('pack_icon_image'));

  testWidgets('shows the stored icon', (tester) async {
    await pumpDialog(tester, FakePackMetaApi(stored: withIcon), storedIcon());

    expect(iconImage, findsOneWidget);
    final image = tester.widget<Image>(iconImage).image as MemoryImage;
    expect(image.bytes, png16);
  });

  testWidgets('a chosen icon is uploaded and named by the new pack meta', (
    tester,
  ) async {
    final packMetaApi = FakePackMetaApi();
    final assetApi = FakeAssetClientApi();
    Object? result;
    await pumpDialog(
      tester,
      packMetaApi,
      assetApi,
      picked: png32,
      onResult: (value) => result = value,
    );

    await tapButton(tester, 'Choose icon');
    await tester.enterText(description, 'Pack');
    await tester.enterText(field('Min format *'), '46');
    await tester.enterText(field('Max format *'), '48');
    await save(tester, () => result != null);

    expect(assetApi.uploads, ['proj:pack/icon']);
    final uploaded = assetApi.assets.values.single;
    expect(uploaded.fileName, 'pack.png');
    expect(assetApi.contents[uploaded.id], png32);
    expect(packMetaApi.puts.single.iconAssetId, uploaded.id);
  });

  testWidgets('a changed icon replaces the content of the stored asset', (
    tester,
  ) async {
    final packMetaApi = FakePackMetaApi(stored: withIcon);
    final assetApi = storedIcon();
    Object? result;
    await pumpDialog(
      tester,
      packMetaApi,
      assetApi,
      picked: png32,
      onResult: (value) => result = value,
    );

    await tapButton(tester, 'Change');
    await save(tester, () => result != null);

    expect(assetApi.replaces, [iconAsset.id]);
    expect(assetApi.contents[iconAsset.id], png32);
    expect(assetApi.uploads, isEmpty);
    // The pack meta still names the same asset.
    expect(packMetaApi.puts, isEmpty);
  });

  testWidgets('an unchanged icon is not sent again', (tester) async {
    final packMetaApi = FakePackMetaApi(stored: withIcon);
    final assetApi = storedIcon();
    Object? result;
    await pumpDialog(
      tester,
      packMetaApi,
      assetApi,
      onResult: (value) => result = value,
    );

    await save(tester, () => result != null);

    expect(assetApi.uploads, isEmpty);
    expect(assetApi.replaces, isEmpty);
    expect(assetApi.deletes, isEmpty);
    expect(packMetaApi.puts, isEmpty);
  });

  testWidgets('a removed icon is dropped from the pack meta and deleted', (
    tester,
  ) async {
    final packMetaApi = FakePackMetaApi(stored: withIcon);
    final assetApi = storedIcon();
    Object? result;
    await pumpDialog(
      tester,
      packMetaApi,
      assetApi,
      onResult: (value) => result = value,
    );

    await tapButton(tester, 'Remove');
    await save(tester, () => result != null);

    expect(packMetaApi.puts, [existing]);
    expect(assetApi.deletes, [iconAsset.id]);
  });

  testWidgets('clearing the pack meta also deletes its icon', (tester) async {
    final packMetaApi = FakePackMetaApi(stored: withIcon);
    final assetApi = storedIcon();
    Object? result;
    await pumpDialog(
      tester,
      packMetaApi,
      assetApi,
      onResult: (value) => result = value,
    );

    await tapButton(tester, 'Remove');
    await tester.enterText(description, '');
    for (final text in ['46', '0', '48']) {
      await tester.enterText(field(text), '');
    }
    await tester.pumpAndSettle();
    await save(tester, () => result != null);

    expect(packMetaApi.deletes, [PackType.resource]);
    expect(assetApi.deletes, [iconAsset.id]);
  });

  testWidgets('an icon alone asks for the required fields', (tester) async {
    final packMetaApi = FakePackMetaApi();
    final assetApi = FakeAssetClientApi();
    await pumpDialog(tester, packMetaApi, assetApi, picked: png16);

    await tapButton(tester, 'Choose icon');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byType(EditProjectDialog), findsOneWidget);
    expect(find.text('Description is required'), findsOneWidget);
    expect(assetApi.uploads, isEmpty);
    expect(packMetaApi.puts, isEmpty);
  });

  testWidgets('a retry after a failed save does not upload the icon twice', (
    tester,
  ) async {
    final packMetaApi = FakePackMetaApi(failPuts: 1);
    final assetApi = FakeAssetClientApi();
    Object? result;
    await pumpDialog(
      tester,
      packMetaApi,
      assetApi,
      picked: png16,
      onResult: (value) => result = value,
    );

    await tapButton(tester, 'Choose icon');
    await tester.enterText(description, 'Pack');
    await tester.enterText(field('Min format *'), '46');
    await tester.enterText(field('Max format *'), '48');
    await save(tester, () => packMetaApi.failPuts == 0);
    await tester.pumpAndSettle();
    expect(find.byType(EditProjectDialog), findsOneWidget);

    await save(tester, () => result != null);

    expect(assetApi.uploads, hasLength(1));
    expect(
      packMetaApi.puts.single.iconAssetId,
      assetApi.assets.values.single.id,
    );
  });

  testWidgets('a failed icon load fails the tab and leaves the meta alone', (
    tester,
  ) async {
    final packMetaApi = FakePackMetaApi(stored: withIcon);
    final assetApi = storedIcon()..failContent = Exception('offline');
    Object? result;
    await pumpDialog(
      tester,
      packMetaApi,
      assetApi,
      onResult: (value) => result = value,
    );

    expect(find.text('The pack.mcmeta could not be loaded'), findsOneWidget);

    await save(tester, () => result != null);
    expect(packMetaApi.puts, isEmpty);
    expect(assetApi.deletes, isEmpty);
  });
}
