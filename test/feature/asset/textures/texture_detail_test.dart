import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/asset/textures/texture_detail.dart';
import 'package:stelaris/feature/asset/textures/texture_usages.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/l10n/app_localizations_delegates.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/pack_icon_pngs.dart';

AssetModel _asset(String id, String key, AssetKind kind, String name) =>
    AssetModel(
      id: id,
      projectId: 'p-1',
      displayName: name,
      key: key,
      kind: kind,
      fileName: '$id.png',
      contentType: 'image/png',
      size: 64,
      sha1: 'sha-$id',
    );

final _gem = _asset('t1', 'vulpes:block/gem', AssetKind.TEXTURE, 'Gem');
final _gemCopy = _asset('t2', 'vulpes:block/gem', AssetKind.TEXTURE, 'Gem 2');
final _ruby = _asset('m1', 'vulpes:item/ruby', AssetKind.MODEL, 'Ruby');
const _icons = FontModel(uiName: 'Icons', id: 'f1', textureAssetId: 't1');

Future<({List<AssetModel> models, List<FontModel> fonts})> _pump(
  WidgetTester tester, {
  required AssetModel texture,
  required TextureUsages? usages,
  bool usagesFailed = false,
}) async {
  tester.view.physicalSize = const Size(1200, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final opened = (models: <AssetModel>[], fonts: <FontModel>[]);
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: TextureDetail(
            projectId: 'p-1',
            texture: texture,
            usages: usages,
            usagesFailed: usagesFailed,
            loadContent: (_, _) async => png16,
            onOpenModel: opened.models.add,
            onOpenFont: opened.fonts.add,
          ),
        ),
      ),
    ),
  );
  // A loading indicator never settles.
  if (usages == null && !usagesFailed) {
    await tester.pump();
  } else {
    await tester.pumpAndSettle();
  }
  return opened;
}

void main() {
  testWidgets('used in lists models, fonts and pack icon', (tester) async {
    final opened = await _pump(
      tester,
      texture: _gem,
      usages: TextureUsages(
        models: [_ruby],
        fonts: const [_icons],
        packIcons: const [PackType.resource],
      ),
    );

    expect(find.text('Ruby'), findsOneWidget);
    expect(find.text('Icons'), findsOneWidget);
    expect(find.text('Resource pack icon'), findsOneWidget);
    expect(find.text('Not used anywhere yet.'), findsNothing);

    await tester.tap(find.text('Ruby'));
    await tester.tap(find.text('Icons'));
    expect(opened.models, [_ruby]);
    expect(opened.fonts, [_icons]);
  });

  testWidgets('shows loading instead of unused while usages load', (
    tester,
  ) async {
    await _pump(tester, texture: _gem, usages: null);

    expect(find.byKey(const Key('texture_usages_loading')), findsOneWidget);
    expect(find.text('Not used anywhere yet.'), findsNothing);
  });

  testWidgets('says when the usages could not be loaded', (tester) async {
    await _pump(tester, texture: _gem, usages: null, usagesFailed: true);

    expect(
      find.text('Where the texture is used could not be loaded.'),
      findsOneWidget,
    );
  });

  testWidgets('font only use is not shown as unused', (tester) async {
    await _pump(
      tester,
      texture: _gem,
      usages: const TextureUsages(fonts: [_icons]),
    );

    expect(find.text('Icons'), findsOneWidget);
    expect(find.text('Not used anywhere yet.'), findsNothing);
  });

  testWidgets('unused texture says so', (tester) async {
    await _pump(tester, texture: _gem, usages: const TextureUsages());

    expect(find.text('Not used anywhere yet.'), findsOneWidget);
  });

  testWidgets('same key hint names the other texture', (tester) async {
    await _pump(
      tester,
      texture: _gemCopy,
      usages: TextureUsages(sameKeyAs: _gem),
    );

    expect(find.textContaining('Gem has the same key'), findsOneWidget);
  });
}
