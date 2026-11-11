import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/asset/preview/texture_preview.dart';
import 'package:stelaris/feature/project/parts/project_pack_icon.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/pack_icon_pngs.dart';

final _asset = AssetModel(
  id: 'icon-1',
  projectId: 'p-1',
  displayName: 'pack.png',
  key: 'vulpes:pack',
  kind: AssetKind.TEXTURE,
  fileName: 'pack.png',
  contentType: 'image/png',
  size: png16.length,
  sha1: 'sha-icon',
  width: 16,
  height: 16,
);

Future<void> _pump(
  WidgetTester tester,
  Future<ProjectPackIcon?>? icon, {
  bool isSelected = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: ProjectLeading(icon: icon, isSelected: isSelected),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('shows the pack icon as a thumbnail', (tester) async {
    await _pump(
      tester,
      Future.value(
        ProjectPackIcon(asset: _asset, bytes: Future<Uint8List>.value(png16)),
      ),
    );
    await tester.pump();

    final thumbnail = tester.widget<TextureThumbnail>(
      find.byType(TextureThumbnail),
    );
    expect(thumbnail.asset, _asset);
    expect(find.byIcon(Icons.folder_outlined), findsNothing);
    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as MemoryImage).bytes, png16);
    expect(image.filterQuality, FilterQuality.none);
  });

  testWidgets('shows a folder while the icon loads', (tester) async {
    final pending = Completer<ProjectPackIcon?>();
    await _pump(tester, pending.future);

    expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
    expect(find.byType(TextureThumbnail), findsNothing);
  });

  testWidgets('shows a folder for a project without a pack icon', (
    tester,
  ) async {
    await _pump(tester, Future.value());

    expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
    expect(find.byType(TextureThumbnail), findsNothing);
  });

  testWidgets('fills the folder of the selected project', (tester) async {
    await _pump(tester, null, isSelected: true);

    expect(find.byIcon(Icons.folder), findsOneWidget);
  });

  testWidgets('takes the same room with and without an icon', (tester) async {
    await _pump(tester, null);
    final folder = tester.getSize(find.byType(ProjectLeading));

    await _pump(
      tester,
      Future.value(
        ProjectPackIcon(asset: _asset, bytes: Future<Uint8List>.value(png16)),
      ),
    );
    await tester.pump();

    expect(tester.getSize(find.byType(ProjectLeading)), folder);
  });
}
