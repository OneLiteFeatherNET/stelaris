import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/feature/project/dialog/pack_icon_field.dart';
import 'package:stelaris/l10n/app_localizations.dart';

/// Red PNGs of the given size, made with Python's zlib.
final Uint8List png16 = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAG0lEQVR4nGP4z8DwnxLMMGrAaBi'
  'MpoP/wyQMADDE/hC/PRjdAAAAAElFTkSuQmCC',
);
final Uint8List png32 = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAMUlEQVR4nO3XoQ0AAAzDsPz/dHf'
  'GiEF5ZNZW+1wCCBAgQIAAAQIECBAgQIAAgT3f8wNUDfhq0ialkQAAAABJRU5ErkJggg==',
);
final Uint8List png8 = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAYAAADED76LAAAAEklEQVR4nGP4z8DwHx9mGBkKAMLX'
  'f4EvceABAAAAAElFTkSuQmCC',
);
final Uint8List png24 = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAKUlEQVR4nGP4z8Dwn5aYYdSC0SA'
  'aTUWj+WC0qBgtTUfrg9Eq8/+QyAcAxNZ7vfAo/0EAAAAASUVORK5CYII=',
);
final Uint8List png32x16 = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAACAAAAAQCAYAAAB3AH1ZAAAAJklEQVR4nGP4z8DwfyAxw6gDRkN'
  'gNARGQ2A0BEZDYDQE/g9wdQwA2QD8LgZyndQAAAAASUVORK5CYII=',
);

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
    Future<List<Uint8List?>> pump(
      WidgetTester tester, {
      Uint8List? value,
      PickedAssetFile? picked,
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
                pickFile: () async => picked,
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
      expect(find.text('Choose icon'), findsOneWidget);
      expect(find.text('Remove'), findsNothing);
    });

    testWidgets('the preview is square and as high as the column beside it', (
      tester,
    ) async {
      await pump(tester, value: png16);

      final preview = tester.getSize(
        find.byKey(const Key('pack_icon_preview')),
      );
      final column = tester.getSize(
        find.ancestor(of: find.text('Remove'), matching: find.byType(Column)),
      );
      expect(preview.width, preview.height);
      expect(preview.height, column.height);
    });

    testWidgets('takes a valid icon and shows its size', (tester) async {
      final changes = await pump(
        tester,
        picked: PickedAssetFile(name: 'pack.png', bytes: png32),
      );

      await tester.tap(find.text('Choose icon'));
      await tester.pumpAndSettle();

      expect(changes, [png32]);
      expect(find.text('pack.png, 32 × 32'), findsOneWidget);
      expect(find.byKey(const Key('pack_icon_image')), findsOneWidget);
      expect(find.text('Change'), findsOneWidget);
    });

    testWidgets('turns down an icon of the wrong size', (tester) async {
      final changes = await pump(
        tester,
        picked: PickedAssetFile(name: 'pack.png', bytes: png24),
      );

      await tester.tap(find.text('Choose icon'));
      await tester.pumpAndSettle();

      expect(changes, isEmpty);
      expect(find.text('The size must be 16, 32, 64 … pixels'), findsOneWidget);
      expect(find.text('No icon'), findsOneWidget);
    });

    testWidgets('keeps the icon when the dialog is cancelled', (tester) async {
      final changes = await pump(tester, value: png16);

      await tester.tap(find.text('Change'));
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
