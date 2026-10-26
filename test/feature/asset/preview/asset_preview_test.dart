import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/asset/preview/asset_preview.dart';
import 'package:stelaris/feature/asset/preview/asset_preview_controller.dart';
import 'package:stelaris/l10n/app_localizations.dart';

// These tests run on the VM, so AssetPreview uses the placeholder viewport.
const _key = 'vulpes:item/ruby';
const _scene = <String, Object?>{'textures': <Object?>[], 'levels': <Object?>[]};

final _en = lookupAppLocalizations(const Locale('en'));

Future<void> _pump(
  WidgetTester tester, {
  List<String> unsupported = const [],
  AssetPreviewController? controller,
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
        ),
      ),
    ),
  );
}

SegmentedButton<AssetDetail> _detailButton(WidgetTester tester) =>
    tester.widget(find.byType(SegmentedButton<AssetDetail>));

void main() {
  testWidgets('placeholder names the asset key', (tester) async {
    await _pump(tester);

    expect(find.text(_key), findsOneWidget);
  });

  testWidgets('no unsupported line when nothing is unsupported', (tester) async {
    await _pump(tester);

    expect(find.textContaining('Not shown'), findsNothing);
  });

  testWidgets('lists the unsupported parts under the preview', (tester) async {
    await _pump(tester, unsupported: ['mesh: Sword blade', 'parent: block/cube_all']);

    expect(
      find.text(_en.asset_preview_unsupported('mesh: Sword blade, parent: block/cube_all')),
      findsOneWidget,
    );
  });

  testWidgets('detail starts on automatic', (tester) async {
    final controller = AssetPreviewController();
    addTearDown(controller.dispose);
    await _pump(tester, controller: controller);

    expect(controller.detail, AssetDetail.automatic);
    expect(_detailButton(tester).selected, {AssetDetail.automatic});
  });

  testWidgets('tapping a detail segment selects it on the controller', (tester) async {
    final controller = AssetPreviewController();
    addTearDown(controller.dispose);
    await _pump(tester, controller: controller);

    await tester.tap(find.text(_en.asset_preview_detail_reduced));
    await tester.pump();

    expect(controller.detail, AssetDetail.reduced);
    expect(_detailButton(tester).selected, {AssetDetail.reduced});
  });

  testWidgets('tapping the box segment selects the box level', (tester) async {
    final controller = AssetPreviewController();
    addTearDown(controller.dispose);
    await _pump(tester, controller: controller);

    await tester.tap(find.text(_en.asset_preview_detail_box));
    await tester.pump();

    expect(controller.detail, AssetDetail.box);
  });

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
}
