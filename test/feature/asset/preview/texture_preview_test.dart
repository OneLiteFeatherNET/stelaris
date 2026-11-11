import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/asset/preview/texture_preview.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// A transparent PNG of one pixel.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

AssetModel _texture({int? width, int? height}) => AssetModel(
  id: 't-1',
  projectId: 'p-1',
  key: 'cygnus:font/ghost',
  kind: AssetKind.TEXTURE,
  displayName: 'Ghost',
  fileName: 'ghost.png',
  contentType: 'image/png',
  size: _png.length,
  sha1: 'aaaa',
  width: width,
  height: height,
);

Future<void> _pump(
  WidgetTester tester,
  AssetModel asset, {
  required TextureContentLoader loadContent,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            child: TexturePreview(
              projectId: 'p-1',
              asset: asset,
              loadContent: loadContent,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  Future<List<int>> loaded(String projectId, String assetId) async => _png;

  testWidgets('loads the bytes of the asset', (tester) async {
    final requested = <String>[];
    await _pump(
      tester,
      _texture(width: 8, height: 8),
      loadContent: (projectId, assetId) async {
        requested.add('$projectId/$assetId');
        return _png;
      },
    );

    expect(requested, ['p-1/t-1']);
  });

  testWidgets('scales a small texture by a whole factor, without smoothing', (
    tester,
  ) async {
    await _pump(tester, _texture(width: 8, height: 8), loadContent: loaded);

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.filterQuality, FilterQuality.none);
    // 160 px high fit 20 times 8 px.
    expect(tester.getSize(find.byType(Image)), const Size(160, 160));
  });

  testWidgets('keeps the scale whole for a wide texture', (tester) async {
    await _pump(tester, _texture(width: 182, height: 28), loadContent: loaded);

    // 400 px wide fit 2.19 times 182 px, so it is scaled twice.
    expect(tester.getSize(find.byType(Image)), const Size(364, 56));
  });

  testWidgets('shrinks a texture larger than the area', (tester) async {
    await _pump(tester, _texture(width: 800, height: 80), loadContent: loaded);

    expect(tester.getSize(find.byType(Image)), const Size(400, 40));
  });

  testWidgets('shows a spinner while loading', (tester) async {
    final pending = Completer<List<int>>();
    await _pump(
      tester,
      _texture(width: 8, height: 8),
      loadContent: (_, _) => pending.future,
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.complete(_png);
  });

  testWidgets('names a texture that could not be loaded', (tester) async {
    await _pump(
      tester,
      _texture(width: 8, height: 8),
      loadContent: (_, _) async => throw Exception('offline'),
    );

    expect(find.text('The texture could not be shown'), findsOneWidget);
  });

  testWidgets('shows bytes at hand at once, without loading them', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: TexturePreview.bytes(_png)),
      ),
    );

    // No pump for a load: the first frame already shows the texture.
    expect(find.byType(CircularProgressIndicator), findsNothing);
    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as MemoryImage).bytes, _png);
    expect(image.filterQuality, FilterQuality.none);
  });

  testWidgets('shows the bytes of another file in place of the first', (
    tester,
  ) async {
    Widget preview(Uint8List bytes) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: TexturePreview.bytes(bytes)),
    );
    final other = Uint8List.fromList(_png);
    await tester.pumpWidget(preview(_png));
    await tester.pumpWidget(preview(other));
    await tester.pump();

    final image = tester.widget<Image>(find.byType(Image));
    expect(identical((image.image as MemoryImage).bytes, other), isTrue);
  });

  group('thumbnail', () {
    Future<void> pumpThumbnail(
      WidgetTester tester,
      Future<Uint8List> bytes,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: TextureThumbnail(
                asset: _texture(width: 8, height: 8),
                bytes: bytes,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('scales the texture by a whole factor, without smoothing', (
      tester,
    ) async {
      await pumpThumbnail(tester, Future.value(Uint8List.fromList(_png)));

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.filterQuality, FilterQuality.none);
      // 40 px fit 5 times 8 px.
      expect(tester.getSize(find.byType(Image)), const Size(40, 40));
      expect(
        tester.getSize(find.byType(TextureThumbnail)),
        const Size(40, 40),
      );
    });

    testWidgets('shows an icon for a texture that could not be loaded', (
      tester,
    ) async {
      // Fails once the thumbnail listens, or the test would see the error.
      final bytes = Completer<Uint8List>();
      await pumpThumbnail(tester, bytes.future);
      bytes.completeError(Exception('offline'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });
  });
}
