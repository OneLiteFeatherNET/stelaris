import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/asset/loading/asset_library.dart';
import 'package:stelaris/feature/asset/models/model_detail.dart';
import 'package:stelaris/feature/asset/models/model_textures.dart';
import 'package:stelaris/feature/asset/preview/asset_scene_view.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_asset_api.dart';
import '../../../support/pump_until.dart';

AssetModel _asset(String id, String key, AssetKind kind) => AssetModel(
  id: id,
  projectId: 'p-1',
  displayName: 'Name of $id',
  key: key,
  kind: kind,
  fileName: '$id.json',
  contentType: 'application/json',
  size: 2048,
  sha1: 'sha-$id',
);

final _ruby = _asset('m1', 'vulpes:item/ruby', AssetKind.MODEL);
final _sword = _asset('m2', 'vulpes:item/sword', AssetKind.MODEL);
final _gem = _asset('t1', 'vulpes:block/gem', AssetKind.TEXTURE);

Future<void> _pump(
  WidgetTester tester, {
  required ModelTextures textures,
  AssetModel? model,
  List<ItemModel> usedBy = const [],
  ValueChanged<ItemModel>? onOpenItem,
  ValueChanged<TextureSlot>? onUploadTexture,
  double width = 1000,
}) async {
  tester.view.physicalSize = Size(width, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  serveAssets(const []);
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: ModelDetail(
            projectId: 'p-1',
            model: model ?? _ruby,
            textures: textures,
            usedBy: Future.value(usedBy),
            onOpenItem: onOpenItem ?? (_) {},
            onUploadTexture: onUploadTexture,
          ),
        ),
      ),
    ),
  );
  // The 3D preview loads through the shared library on real timers.
  await pumpUntil(
    tester,
    action: () async {},
    done: () => find.byType(CircularProgressIndicator).evaluate().isEmpty,
  );
}

void main() {
  // A content cached by another test would never resolve in this one.
  setUp(AssetLibrary.shared.clearContents);

  testWidgets('shows what the model is', (tester) async {
    await _pump(tester, textures: const ModelTextures(slots: []));

    // No key row with a copy button above the cards: the info dialog of the
    // page header shows the key.
    expect(find.byIcon(Icons.copy_outlined), findsNothing);
    expect(find.text('Model'), findsOneWidget);
    expect(find.text('m1.json'), findsOneWidget);
    expect(find.text('2.0 KB'), findsOneWidget);
    expect(find.text('This model refers to no textures.'), findsOneWidget);
  });

  testWidgets('marks textures present or missing with an upload', (
    tester,
  ) async {
    final uploads = <String>[];
    await _pump(
      tester,
      textures: ModelTextures(
        slots: [
          TextureSlot(key: 'vulpes:block/gem', texture: _gem, alsoIn: [_sword]),
          const TextureSlot(key: 'vulpes:item/glow'),
        ],
      ),
      onUploadTexture: (slot) => uploads.add(slot.key),
    );

    expect(find.text('Also in: vulpes:item/sword'), findsOneWidget);
    expect(find.text('Missing'), findsOneWidget);
    expect(find.text('Click to upload it'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('model_texture_upload_vulpes:block/gem')),
      findsNothing,
    );

    await tester.tap(
      find.byKey(const ValueKey('model_texture_upload_vulpes:item/glow')),
    );

    expect(uploads, ['vulpes:item/glow']);
  });

  testWidgets('a Blockbench model lists its textures without upload', (
    tester,
  ) async {
    await _pump(
      tester,
      model: _asset('b1', 'vulpes:item/axe', AssetKind.BBMODEL),
      textures: ModelTextures(
        readOnly: true,
        slots: [TextureSlot(key: 'vulpes:item/axe_0', texture: _gem)],
      ),
      onUploadTexture: (_) {},
    );

    expect(find.text('Embedded in the Blockbench model'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('model_texture_upload_vulpes:item/axe_0')),
      findsNothing,
    );
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
  });

  testWidgets('lists the items using the model and opens one', (tester) async {
    const item = ItemModel(uiName: 'Ruby', id: 'i1');
    final opened = <ItemModel>[];
    await _pump(
      tester,
      textures: const ModelTextures(slots: []),
      usedBy: [item],
      onOpenItem: opened.add,
    );

    await tester.tap(find.byKey(const ValueKey('model_used_by_i1')));

    expect(opened, [item]);
  });

  testWidgets('says when no item uses the model', (tester) async {
    await _pump(tester, textures: const ModelTextures(slots: []));

    expect(find.text('No item uses this model yet.'), findsOneWidget);
  });

  testWidgets('a wide page shows the preview to the right of the cards', (
    tester,
  ) async {
    await _pump(tester, textures: const ModelTextures(slots: []));

    final preview = tester.getRect(find.byType(AssetSceneView));
    final info = tester.getRect(find.text('m1.json'));
    expect(preview.left, greaterThan(info.right));
    expect(preview.top, lessThan(info.bottom));
  });

  testWidgets('a narrow page shows the preview above the cards', (
    tester,
  ) async {
    await _pump(tester, textures: const ModelTextures(slots: []), width: 700);

    final preview = tester.getRect(find.byType(AssetSceneView));
    final info = tester.getRect(find.text('m1.json'));
    expect(preview.bottom, lessThan(info.top));
  });

  testWidgets('warns with the count when textures are missing', (tester) async {
    await _pump(
      tester,
      textures: ModelTextures(
        slots: [
          TextureSlot(key: 'vulpes:block/gem', texture: _gem),
          const TextureSlot(key: 'vulpes:item/glow'),
          const TextureSlot(key: 'vulpes:item/dust'),
        ],
      ),
    );

    expect(
      find.text(
        '2 textures of this model are missing. '
        'Upload them from the textures below.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('no warning when every texture is present', (tester) async {
    await _pump(
      tester,
      textures: ModelTextures(
        slots: [TextureSlot(key: 'vulpes:block/gem', texture: _gem)],
      ),
    );

    expect(find.byKey(const Key('model_missing_notice')), findsNothing);
  });
}
