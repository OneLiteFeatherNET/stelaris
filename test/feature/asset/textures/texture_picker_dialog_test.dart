import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/asset/loading/asset_library.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/feature/asset/textures/texture_card.dart';
import 'package:stelaris/feature/asset/textures/texture_picker_dialog.dart';
import 'package:stelaris/feature/asset/textures/texture_usage_sources.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/l10n/app_localizations_delegates.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/pack_icon_pngs.dart';

AssetModel _asset(
  String id,
  String key, {
  String? name,
  String? sourceAssetId,
  AssetKind kind = AssetKind.TEXTURE,
}) => AssetModel(
  id: id,
  projectId: 'p-1',
  displayName: name ?? 'Name of $id',
  key: key,
  kind: kind,
  fileName: '$id.png',
  contentType: 'image/png',
  size: 64,
  sha1: 'sha-$id',
  sourceAssetId: sourceAssetId,
  width: 16,
  height: 16,
);

final _gem = _asset('t1', 'vulpes:block/gem', name: 'Gem');
final _ruby = _asset('t2', 'vulpes:item/ruby', name: 'Ruby');
final _stone = _asset('t3', 'vulpes:block/stone', name: 'Stone');
final _axe = _asset(
  'b1',
  'vulpes:item/axe',
  name: 'Axe',
  kind: AssetKind.BBMODEL,
);
final _blade = _asset(
  't4',
  'vulpes:item/axe_blade',
  name: 'Blade',
  sourceAssetId: 'b1',
);

const _icons = FontModel(uiName: 'Icons', id: 'f1', textureAssetId: 't1');

/// Answers the picker's lookups from memory, without requests.
class _Library extends AssetLibrary {
  _Library(this.assets) : super(ApiService().assetApi);

  final List<AssetModel> assets;
  int listings = 0;

  @override
  Future<List<AssetModel>> assetsOf(String projectId, AssetKind kind) async {
    if (kind == AssetKind.TEXTURE) listings++;
    return [
      for (final asset in assets)
        if (asset.kind == kind) asset,
    ];
  }

  @override
  Future<Set<String>> textureKeysOf(String projectId, AssetModel asset) async =>
      const {};

  @override
  Future<List<int>> contentOf(String projectId, AssetModel asset) async =>
      png16;
}

/// The outcome of the dialog once it closed.
class _Outcome {
  bool closed = false;
  AssetModel? picked;
  final List<AssetModel> updated = [];
}

Future<_Outcome> _open(
  WidgetTester tester, {
  List<AssetModel>? assets,
  String? selectedId,
  String? currentFontId,
  Future<TextureUsageSources> Function(String projectId)? loadSources,
  Future<PickedAssetFile?> Function()? pickFile,
  Store<AppState>? store,
  _Library? library,
  bool settle = true,
}) async {
  tester.view.physicalSize = const Size(1400, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final outcome = _Outcome();
  final lib =
      library ?? _Library(assets ?? [_gem, _ruby, _stone, _axe, _blade]);
  await tester.pumpWidget(
    StoreProvider<AppState>(
      store: store ?? Store<AppState>(initialState: const AppState()),
      child: MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                outcome.picked = await showTexturePickerDialog(
                  context,
                  projectId: 'p-1',
                  namespace: 'vulpes',
                  selectedId: selectedId,
                  currentFontId: currentFontId,
                  keyFolder: 'font',
                  onUpdated: outcome.updated.add,
                  library: lib,
                  pickFile: pickFile ?? () async => null,
                  loadUsageSources:
                      loadSources ??
                      (_) async => const TextureUsageSources(fonts: [_icons]),
                );
                outcome.closed = true;
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    // A loading indicator never settles.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }
  return outcome;
}

Finder _card(AssetModel texture) =>
    find.byKey(ValueKey('texture_${texture.id}'));

TextureCard _cardOf(WidgetTester tester, AssetModel texture) =>
    tester.widget<TextureCard>(_card(texture));

FilledButton _chooseButton(WidgetTester tester) =>
    tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Choose'));

void main() {
  testWidgets('lists the uploaded textures as cards, without extracted ones', (
    tester,
  ) async {
    await _open(tester);

    expect(find.byKey(const Key('texture_picker_grid')), findsOneWidget);
    expect(_card(_gem), findsOneWidget);
    expect(_card(_ruby), findsOneWidget);
    expect(_card(_stone), findsOneWidget);
    expect(_card(_blade), findsNothing);
  }, variant: TargetPlatformVariant.desktop());

  testWidgets('preselects the given texture and shows it in the preview', (
    tester,
  ) async {
    await _open(tester, selectedId: _ruby.id);

    expect(_cardOf(tester, _ruby).selected, isTrue);
    expect(_cardOf(tester, _gem).selected, isFalse);
    final preview = find.byKey(const Key('texture_picker_preview'));
    expect(
      find.descendant(of: preview, matching: find.text(_ruby.key)),
      findsOneWidget,
    );
  });

  testWidgets('an unknown selected id selects nothing', (tester) async {
    await _open(tester, selectedId: 'gone');

    for (final texture in [_gem, _ruby, _stone]) {
      expect(_cardOf(tester, texture).selected, isFalse);
    }
    expect(_chooseButton(tester).onPressed, isNull);
  });

  testWidgets('the search filters by name and key', (tester) async {
    await _open(tester);

    await tester.enterText(
      find.byKey(const Key('texture_picker_search')),
      'ruby',
    );
    await tester.pumpAndSettle();
    expect(_card(_ruby), findsOneWidget);
    expect(_card(_gem), findsNothing);

    await tester.enterText(
      find.byKey(const Key('texture_picker_search')),
      'block/',
    );
    await tester.pumpAndSettle();
    expect(_card(_gem), findsOneWidget);
    expect(_card(_stone), findsOneWidget);
    expect(_card(_ruby), findsNothing);

    await tester.enterText(
      find.byKey(const Key('texture_picker_search')),
      'zzz',
    );
    await tester.pumpAndSettle();
    expect(find.text('Nothing matches the search.'), findsOneWidget);
  });

  testWidgets('the preview toggle hides the panel and is remembered', (
    tester,
  ) async {
    final store = Store<AppState>(initialState: const AppState());
    await _open(tester, selectedId: _gem.id, store: store);
    expect(find.byKey(const Key('texture_picker_preview')), findsOneWidget);

    await tester.tap(find.byKey(const Key('texture_picker_preview_toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('texture_picker_preview')), findsNothing);
    expect(store.state.openTexturePreview, isFalse);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('texture_picker_preview')), findsNothing);
  });

  testWidgets('choose returns the selected texture', (tester) async {
    final outcome = await _open(tester);

    await tester.tap(_card(_stone));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.widgetWithText(FilledButton, 'Choose'));
    await tester.pumpAndSettle();

    expect(outcome.closed, isTrue);
    expect(outcome.picked, _stone);
  });

  testWidgets('cancel returns null', (tester) async {
    final outcome = await _open(tester, selectedId: _gem.id);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(outcome.closed, isTrue);
    expect(outcome.picked, isNull);
  });

  testWidgets('a second tap on the selected card picks it', (tester) async {
    final outcome = await _open(tester);

    await tester.tap(_card(_ruby));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(_card(_ruby));
    await tester.pumpAndSettle();

    expect(outcome.closed, isTrue);
    expect(outcome.picked, _ruby);
  });

  testWidgets('quick taps on two cards only select', (tester) async {
    final outcome = await _open(tester);

    await tester.tap(_card(_ruby));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(_card(_gem));
    await tester.pumpAndSettle();

    expect(outcome.closed, isFalse);
    expect(_cardOf(tester, _gem).selected, isTrue);
    expect(_cardOf(tester, _ruby).selected, isFalse);
  });

  testWidgets('the uses arrive in the panel after the cards', (tester) async {
    final sources = Completer<TextureUsageSources>();
    await _open(
      tester,
      selectedId: _gem.id,
      loadSources: (_) => sources.future,
      settle: false,
    );

    expect(find.byKey(const Key('texture_usages_loading')), findsOneWidget);

    sources.complete(const TextureUsageSources(fonts: [_icons]));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('texture_usages_loading')), findsNothing);
    expect(find.byKey(const ValueKey('texture_used_font_f1')), findsOneWidget);
  });
}
