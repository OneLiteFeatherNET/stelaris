import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/asset/preview/asset_preview.dart';
import 'package:stelaris/feature/asset/preview/asset_preview_controller.dart';
import 'package:stelaris/feature/asset/preview/asset_preview_placeholder.dart';
import 'package:stelaris/l10n/app_localizations.dart';

// These tests run on the VM, so AssetPreview uses the placeholder viewport.
const _key = 'vulpes:item/ruby';
const _scene = <String, Object?>{
  'textures': <Object?>[],
  'levels': <Object?>[],
};

final _en = lookupAppLocalizations(const Locale('en'));

Future<void> _pump(
  WidgetTester tester, {
  List<String> unsupported = const [],
  AssetPreviewController? controller,
  Widget Function(Widget viewport)? viewportFrame,
}) {
  return tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: AssetPreview(
          scene: _scene,
          assetKey: _key,
          unsupported: unsupported,
          controller: controller,
          viewportFrame: viewportFrame,
        ),
      ),
    ),
  );
}

IconButton _detailButton(WidgetTester tester) => tester.widget(
  find.ancestor(
    of: find.byTooltip(_en.asset_preview_reduced_detail),
    matching: find.byType(IconButton),
  ),
);

void main() {
  testWidgets('placeholder names the asset key', (tester) async {
    await _pump(tester);

    expect(find.text(_key), findsOneWidget);
  });

  testWidgets('no unsupported line when nothing is unsupported', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.textContaining('Not shown'), findsNothing);
  });

  testWidgets('lists the unsupported parts under the preview', (tester) async {
    await _pump(
      tester,
      unsupported: ['mesh: Sword blade', 'parent: block/cube_all'],
    );

    expect(
      find.text(
        _en.asset_preview_unsupported(
          'mesh: Sword blade, parent: block/cube_all',
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('detail starts on automatic', (tester) async {
    final controller = AssetPreviewController();
    addTearDown(controller.dispose);
    await _pump(tester, controller: controller);

    expect(controller.detail, AssetDetail.automatic);
    expect(_detailButton(tester).isSelected, isFalse);
  });

  testWidgets(
    'the reduced detail button toggles between reduced and automatic',
    (tester) async {
      final controller = AssetPreviewController();
      addTearDown(controller.dispose);
      await _pump(tester, controller: controller);

      await tester.tap(find.byTooltip(_en.asset_preview_reduced_detail));
      await tester.pump();
      expect(controller.detail, AssetDetail.reduced);
      expect(_detailButton(tester).isSelected, isTrue);

      await tester.tap(find.byTooltip(_en.asset_preview_reduced_detail));
      await tester.pump();
      expect(controller.detail, AssetDetail.automatic);
    },
  );

  testWidgets(
    'the controls are stacked top to bottom in the top right corner',
    (tester) async {
      await _pump(tester);

      final reset = tester.getRect(
        find.byTooltip(_en.asset_preview_reset_view),
      );
      final rotate = tester.getRect(
        find.byTooltip(_en.asset_preview_auto_rotate),
      );
      final detail = tester.getRect(
        find.byTooltip(_en.asset_preview_reduced_detail),
      );
      final viewport = tester.getRect(find.byType(AssetPreviewPlaceholder));

      expect(reset.center.dx, rotate.center.dx);
      expect(rotate.center.dx, detail.center.dx);
      expect(reset.top, lessThan(rotate.top));
      expect(rotate.top, lessThan(detail.top));
      expect(reset.top - viewport.top, lessThan(24));
      expect(viewport.right - reset.right, lessThan(24));
    },
  );

  testWidgets('tapping the auto-rotate button toggles it', (tester) async {
    final controller = AssetPreviewController();
    addTearDown(controller.dispose);
    await _pump(tester, controller: controller);

    await tester.tap(find.byTooltip(_en.asset_preview_auto_rotate));
    await tester.pump();
    expect(controller.autoRotate, isTrue);

    await tester.tap(find.byTooltip(_en.asset_preview_auto_rotate));
    await tester.pump();
    expect(controller.autoRotate, isFalse);
  });

  testWidgets('tapping the reset button requests a view reset', (tester) async {
    final controller = AssetPreviewController();
    addTearDown(controller.dispose);
    await _pump(tester, controller: controller);

    await tester.tap(find.byTooltip(_en.asset_preview_reset_view));
    await tester.pump();

    expect(controller.resetRequests, 1);
  });

  testWidgets('viewport frame wraps the viewport placeholder', (tester) async {
    await _pump(
      tester,
      viewportFrame: (viewport) =>
          Container(key: const Key('frame'), child: viewport),
    );

    expect(
      find.descendant(
        of: find.byKey(const Key('frame')),
        matching: find.byType(AssetPreviewPlaceholder),
      ),
      findsOneWidget,
    );
  });

  testWidgets('viewport frame leaves the controls outside', (tester) async {
    await _pump(
      tester,
      unsupported: ['mesh: Sword blade'],
      viewportFrame: (viewport) =>
          Container(key: const Key('frame'), child: viewport),
    );

    final frame = find.byKey(const Key('frame'));
    expect(
      find.descendant(of: frame, matching: find.byType(IconButton)),
      findsNothing,
    );
    expect(
      find.descendant(
        of: frame,
        matching: find.text(_en.asset_preview_unsupported('mesh: Sword blade')),
      ),
      findsNothing,
    );
    expect(find.byType(IconButton), findsNWidgets(3));
  });

  testWidgets('a change of the controls leaves the viewport unbuilt', (
    tester,
  ) async {
    final controller = AssetPreviewController();
    addTearDown(controller.dispose);
    var frames = 0;
    await _pump(
      tester,
      controller: controller,
      viewportFrame: (viewport) {
        frames++;
        return viewport;
      },
    );
    final built = frames;

    await tester.tap(find.byTooltip(_en.asset_preview_auto_rotate));
    await tester.pump();
    await tester.tap(find.byTooltip(_en.asset_preview_reduced_detail));
    await tester.pump();

    expect(controller.autoRotate, isTrue);
    expect(controller.detail, AssetDetail.reduced);
    expect(frames, built);
  });
}
