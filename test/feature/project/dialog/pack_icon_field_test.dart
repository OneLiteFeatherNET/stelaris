import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/feature/project/dialog/pack_icon_field.dart';
import 'package:stelaris/l10n/app_localizations.dart';

import '../../../support/pack_icon_pngs.dart';

void main() {
  group('checkPackIcon', () {
    test('takes square PNGs with a power of two side', () {
      expect(checkPackIcon(png16), isNull);
      expect(checkPackIcon(png32), isNull);
    });

    test('names what is wrong with the others', () {
      expect(
        checkPackIcon(Uint8List.fromList(utf8.encode('{"a": 1}'))),
        PackIconProblem.notPng,
      );
      expect(checkPackIcon(png32x16), PackIconProblem.notSquare);
      expect(checkPackIcon(png24), PackIconProblem.notPowerOfTwo);
      expect(checkPackIcon(png8), PackIconProblem.tooSmall);
    });

    test('reads the size from the PNG header', () {
      expect(pngSize(png32x16), (width: 32, height: 16));
      expect(pngSize(Uint8List(4)), isNull);
    });
  });

  group('PackIconField', () {
    final preview = find.byKey(const Key('pack_icon_preview'));
    final editOverlay = find.byKey(const Key('pack_icon_edit_overlay'));

    Future<List<Uint8List?>> pump(
      WidgetTester tester, {
      Uint8List? value,
      PickedAssetFile? picked,
      Future<PickedAssetFile?> Function()? pickFile,
    }) async {
      final changes = <Uint8List?>[];
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => PackIconField(
                value: value,
                onChanged: (icon) {
                  changes.add(icon);
                  setState(() => value = icon);
                },
                pickFile: pickFile ?? () async => picked,
              ),
            ),
          ),
        ),
      );
      return changes;
    }

    testWidgets('shows that there is no icon yet', (tester) async {
      await pump(tester);

      expect(find.text('No icon'), findsOneWidget);
      expect(find.byIcon(Icons.add_photo_alternate_outlined), findsOneWidget);
      expect(find.byTooltip('Choose icon'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);
      expect(find.text('Remove'), findsNothing);
    });

    testWidgets('the preview keeps its square size with and without icon', (
      tester,
    ) async {
      await pump(tester);
      expect(tester.getSize(preview), const Size.square(packIconPreviewSize));

      await pump(tester, value: png16);
      expect(tester.getSize(preview), const Size.square(packIconPreviewSize));
    });

    testWidgets('the preview is a button named by what a tap does', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(tester, value: png16);

      expect(
        tester.getSemantics(preview),
        matchesSemantics(
          label: 'Change icon',
          tooltip: 'Change icon',
          isButton: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
          hasEnabledState: true,
          isEnabled: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('a hovered icon shows the edit mark', (tester) async {
      await pump(tester, value: png16);
      expect(editOverlay, findsNothing);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(preview));
      await tester.pumpAndSettle();

      expect(editOverlay, findsOneWidget);
      await mouse.removePointer();
    });

    testWidgets('an empty preview shows no edit mark when hovered', (
      tester,
    ) async {
      await pump(tester);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(preview));
      await tester.pumpAndSettle();

      expect(editOverlay, findsNothing);
      await mouse.removePointer();
    });

    testWidgets('shows a spinner and ignores taps while the file is read', (
      tester,
    ) async {
      final file = Completer<PickedAssetFile?>();
      var picks = 0;
      final changes = await pump(
        tester,
        pickFile: () {
          picks++;
          return file.future;
        },
      );

      await tester.tap(preview);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(preview);
      await tester.pump();
      expect(picks, 1);

      file.complete(PickedAssetFile(name: 'pack.png', bytes: png16));
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(changes, [png16]);
    });

    testWidgets('takes a valid icon and shows its size', (tester) async {
      final changes = await pump(
        tester,
        picked: PickedAssetFile(name: 'pack.png', bytes: png32),
      );

      await tester.tap(preview);
      await tester.pumpAndSettle();

      expect(changes, [png32]);
      expect(find.text('pack.png, 32 × 32'), findsOneWidget);
      expect(find.byKey(const Key('pack_icon_image')), findsOneWidget);
      expect(find.byTooltip('Change icon'), findsOneWidget);
    });

    testWidgets('turns down an icon of the wrong size', (tester) async {
      final changes = await pump(
        tester,
        picked: PickedAssetFile(name: 'pack.png', bytes: png24),
      );

      await tester.tap(preview);
      await tester.pumpAndSettle();

      expect(changes, isEmpty);
      expect(find.text('The size must be 16, 32, 64 … pixels'), findsOneWidget);
      expect(find.text('No icon'), findsOneWidget);
    });

    testWidgets('keeps the icon when the dialog is cancelled', (tester) async {
      final changes = await pump(tester, value: png16);

      await tester.tap(preview);
      await tester.pumpAndSettle();

      expect(changes, isEmpty);
      expect(find.text('pack.png, 16 × 16'), findsOneWidget);
    });

    testWidgets('removes the icon', (tester) async {
      final changes = await pump(tester, value: png16);

      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      expect(changes, [null]);
      expect(find.text('No icon'), findsOneWidget);
    });
  });
}
