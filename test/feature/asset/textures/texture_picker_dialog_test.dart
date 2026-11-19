import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

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

import '../../../support/fake_http_client_adapter.dart';
import '../../../support/pack_icon_pngs.dart';
import '../../../support/pump_until.dart';

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
const _glyphs = FontModel(uiName: 'Glyphs', id: 'f2', textureAssetId: 't1');

const _resourceIcon = PackMeta(
  id: 'pm-resource',
  projectId: 'p-1',
  packType: PackType.resource,
  description: '',
  minFormatMajor: 64,
  maxFormatMajor: 69,
  iconAssetId: 't1',
);

Map<String, Object?> _json(AssetModel asset) => {
  'id': asset.id,
  'projectId': asset.projectId,
  'key': asset.key,
  'displayName': asset.displayName,
  'kind': asset.kind.name,
  'fileName': asset.fileName,
  'contentType': asset.contentType,
  'size': asset.size,
  'sha1': asset.sha1,
  'derivedAssetIds': <String>[],
  'width': asset.width,
  'height': asset.height,
};

/// Answers every upload with [answer].
void _backend(ResponseBody Function(RequestOptions options) answer) {
  ApiService().assetApi.apiClient.dio.httpClientAdapter = FakeHttpClientAdapter(
    answer,
  );
}

Future<PickedAssetFile?> _pickPng() async =>
    PickedAssetFile(name: 'ember.png', bytes: png16);

Future<void> _tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Opens the update of the selected texture and chooses a file for it.
Future<void> _startUpdate(WidgetTester tester) async {
  await _tapAndSettle(tester, find.byKey(const Key('texture_picker_update')));
  await _tapAndSettle(tester, find.byKey(const Key('asset_upload_drop_zone')));
}

Future<void> _submit(WidgetTester tester, String label, bool Function() done) =>
    pumpUntil(
      tester,
      action: () async => tester.tap(find.widgetWithText(FilledButton, label)),
      done: done,
    );

/// Answers the picker's lookups from memory, without requests.
class _Library extends AssetLibrary {
  _Library(this.assets) : super(ApiService().assetApi);

  final List<AssetModel> assets;
  int listings = 0;

  /// How long a listing takes, e.g. to answer after the next frame like the
  /// backend does.
  Duration delay = Duration.zero;

  /// The texture listings that have answered.
  int answered = 0;

  /// Whether the listings fail, as when the backend is gone.
  bool offline = false;

  @override
  Future<List<AssetModel>> assetsOf(String projectId, AssetKind kind) async {
    if (kind == AssetKind.TEXTURE) listings++;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (offline) {
      throw DioException(requestOptions: RequestOptions(path: '/assets'));
    }
    if (kind == AssetKind.TEXTURE) answered++;
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

  testWidgets('shows three compact cards per row beside the preview', (
    tester,
  ) async {
    await _open(tester, selectedId: _gem.id);

    expect(_cardOf(tester, _gem).compact, isTrue);
    final top = tester.getTopLeft(_card(_gem)).dy;
    expect(tester.getTopLeft(_card(_ruby)).dy, top);
    expect(tester.getTopLeft(_card(_stone)).dy, top);
  });

  testWidgets('the grid grows with the window', (tester) async {
    await _open(tester);
    final small = tester.getSize(find.byKey(const Key('texture_picker_grid')));

    tester.view.physicalSize = const Size(1400, 1300);
    await tester.pumpAndSettle();
    final large = tester.getSize(find.byKey(const Key('texture_picker_grid')));

    expect(large.height, greaterThan(small.height + 200));
  });

  testWidgets('upload and preview toggle sit in the title row', (tester) async {
    await _open(tester);

    final title = tester.getCenter(find.text('Choose a texture'));
    final search = tester.getRect(
      find.byKey(const Key('texture_picker_search')),
    );
    for (final key in [
      'texture_picker_upload',
      'texture_picker_preview_toggle',
    ]) {
      final button = tester.getCenter(find.byKey(Key(key)));
      expect(button.dy, moreOrLessEquals(title.dy, epsilon: 1));
      expect(button.dy, lessThan(search.top));
    }
  });

  testWidgets('the clear button empties the search', (tester) async {
    await _open(tester);

    await tester.enterText(
      find.byKey(const Key('texture_picker_search')),
      'ruby',
    );
    await tester.pumpAndSettle();
    expect(_card(_gem), findsNothing);

    await tester.tap(find.byTooltip('Clear the search'));
    await tester.pumpAndSettle();

    expect(_card(_gem), findsOneWidget);
    expect(find.byTooltip('Clear the search'), findsNothing);
  });

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

  /// Enough textures that the grid scrolls, sorted before `vulpes:zz/`.
  List<AssetModel> many() => [
    for (var i = 0; i < 60; i++)
      _asset('m$i', 'vulpes:block/m${i.toString().padLeft(2, '0')}'),
  ];

  testWidgets('scrolls to the texture selected on opening', (tester) async {
    final last = _asset('t9', 'vulpes:zz/last', name: 'Last');
    await _open(tester, assets: [...many(), last], selectedId: last.id);

    expect(_card(last).hitTestable(), findsOneWidget);
  });

  group('upload', () {
    testWidgets('scrolls to the new texture', (tester) async {
      final ember = _asset('t9', 'vulpes:zz/ember', name: 'Ember');
      final library = _Library(many());
      _backend((options) {
        library.assets.add(ember);
        return FakeHttpClientAdapter.response(_json(ember));
      });
      await _open(tester, library: library, pickFile: _pickPng);
      final answered = library.answered;
      // The list comes after the grid is back, as from the backend.
      library.delay = const Duration(milliseconds: 100);

      await _tapAndSettle(
        tester,
        find.byKey(const Key('texture_picker_upload')),
      );
      await _tapAndSettle(
        tester,
        find.byKey(const Key('asset_upload_drop_zone')),
      );
      await _submit(tester, 'Upload', () => library.answered > answered);
      await tester.pumpAndSettle();

      expect(_card(ember).hitTestable(), findsOneWidget);
    });

    testWidgets('stores a texture and selects it', (tester) async {
      final ember = _asset('t9', 'vulpes:font/ember', name: 'Ember');
      final library = _Library([_gem, _ruby]);
      _backend((options) {
        library.assets.add(ember);
        return FakeHttpClientAdapter.response(_json(ember));
      });
      final outcome = await _open(tester, library: library, pickFile: _pickPng);

      await _tapAndSettle(
        tester,
        find.byKey(const Key('texture_picker_upload')),
      );
      expect(find.text('Upload a texture'), findsOneWidget);
      await _tapAndSettle(
        tester,
        find.byKey(const Key('asset_upload_drop_zone')),
      );
      await _submit(tester, 'Upload', () => _card(ember).evaluate().isNotEmpty);
      await tester.pumpAndSettle();

      expect(_cardOf(tester, ember).selected, isTrue);
      expect(outcome.closed, isFalse);
    });

    testWidgets('a failed reload afterwards shows an error', (tester) async {
      final ember = _asset('t9', 'vulpes:font/ember', name: 'Ember');
      final library = _Library([_gem, _ruby]);
      _backend((options) {
        library.offline = true;
        return FakeHttpClientAdapter.response(_json(ember));
      });
      await _open(tester, library: library, pickFile: _pickPng);
      final listings = library.listings;

      await _tapAndSettle(
        tester,
        find.byKey(const Key('texture_picker_upload')),
      );
      await _tapAndSettle(
        tester,
        find.byKey(const Key('asset_upload_drop_zone')),
      );
      await _submit(tester, 'Upload', () => library.listings > listings);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(_card(_gem), findsOneWidget);
    });

    testWidgets('the file dialog taking the focus loads nothing again', (
      tester,
    ) async {
      final library = _Library([_gem, _ruby]);
      await _open(tester, library: library);
      Future<void> resume() async {
        tester.binding
          ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
          ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await tester.pumpAndSettle();
      }

      await _tapAndSettle(
        tester,
        find.byKey(const Key('texture_picker_upload')),
      );
      final listings = library.listings;
      await resume();
      expect(library.listings, listings);

      await _tapAndSettle(tester, find.byKey(const Key('texture_picker_back')));
      await resume();
      expect(library.listings, greaterThan(listings));
    });

    testWidgets('going back while the file is read', (tester) async {
      final file = Completer<PickedAssetFile?>();
      await _open(tester, pickFile: () => file.future);

      await _tapAndSettle(
        tester,
        find.byKey(const Key('texture_picker_upload')),
      );
      await tester.tap(find.byKey(const Key('asset_upload_drop_zone')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('texture_picker_back')));
      await tester.pumpAndSettle();
      file.complete(PickedAssetFile(name: 'ember.png', bytes: png16));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('texture_picker_grid')), findsOneWidget);
    });
  });

  group('update', () {
    testWidgets('names the other uses but not the current font', (
      tester,
    ) async {
      await _open(
        tester,
        selectedId: _gem.id,
        currentFontId: _icons.id,
        pickFile: _pickPng,
        loadSources: (_) async => const TextureUsageSources(
          fonts: [_icons, _glyphs],
          packMetas: [_resourceIcon],
        ),
      );

      await _startUpdate(tester);

      final notice = find.byKey(const Key('texture_picker_also_used'));
      expect(notice, findsOneWidget);
      expect(
        find.descendant(
          of: notice,
          matching: find.textContaining('Glyphs, Resource pack icon'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: notice, matching: find.textContaining('Icons')),
        findsNothing,
      );
    });

    testWidgets('without other uses shows no notice', (tester) async {
      await _open(
        tester,
        selectedId: _gem.id,
        currentFontId: _icons.id,
        pickFile: _pickPng,
      );

      await _startUpdate(tester);

      expect(find.text('New version of Gem'), findsOneWidget);
      expect(find.byKey(const Key('texture_picker_also_used')), findsNothing);
    });

    testWidgets('works while the uses could not be loaded', (tester) async {
      await _open(
        tester,
        selectedId: _gem.id,
        pickFile: _pickPng,
        loadSources: (_) async => throw StateError('offline'),
      );

      await _startUpdate(tester);

      expect(find.text('Uses could not be loaded'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Update'))
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('stores the new version, reports it and keeps it selected', (
      tester,
    ) async {
      final newGem = _gem.copyWith(sha1: 'sha-new');
      _backend((_) => FakeHttpClientAdapter.response(_json(newGem)));
      final outcome = await _open(
        tester,
        selectedId: _gem.id,
        pickFile: _pickPng,
      );

      await _startUpdate(tester);
      await _submit(tester, 'Update', () => outcome.updated.isNotEmpty);
      await pumpUntil(
        tester,
        action: () async {},
        done: () => _card(_gem).evaluate().isNotEmpty,
      );
      await tester.pumpAndSettle();

      expect(outcome.updated.single.sha1, 'sha-new');
      expect(_cardOf(tester, _gem).selected, isTrue);
      expect(outcome.closed, isFalse);
    });

    testWidgets('a conflict shows the error and going back reloads', (
      tester,
    ) async {
      _backend(
        (_) => FakeHttpClientAdapter.response({
          'title': 'Precondition failed',
          'status': 412,
        }, statusCode: 412),
      );
      final library = _Library([_gem, _ruby]);
      await _open(
        tester,
        selectedId: _gem.id,
        pickFile: _pickPng,
        library: library,
      );
      final listings = library.listings;

      await _startUpdate(tester);
      const conflict =
          'Gem was changed meanwhile. Go back to see the stored version.';
      await _submit(
        tester,
        'Update',
        () => find.text(conflict).evaluate().isNotEmpty,
      );
      await _tapAndSettle(tester, find.byKey(const Key('texture_picker_back')));

      expect(find.byKey(const Key('texture_picker_grid')), findsOneWidget);
      expect(library.listings, greaterThan(listings));
    });

    testWidgets('escape goes back to the grid', (tester) async {
      final outcome = await _open(
        tester,
        selectedId: _gem.id,
        pickFile: _pickPng,
      );

      await _startUpdate(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('texture_picker_grid')), findsOneWidget);
      expect(outcome.closed, isFalse);
    });
  });
}
