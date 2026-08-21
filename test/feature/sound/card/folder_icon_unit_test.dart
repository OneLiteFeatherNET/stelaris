import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/sound/card/folder_icon.dart';

void main() {
  testWidgets('FolderIcon builds correctly with proper layout and style', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: FolderIcon())),
    );

    // FolderIcon widget exists
    expect(find.byType(FolderIcon), findsOneWidget);

    // There should be exactly one Container
    expect(find.byType(Container), findsOneWidget);

    // There should be exactly one Icon
    final iconFinder = find.byType(Icon);
    expect(iconFinder, findsOneWidget);

    // Verify the Icon widget’s properties
    final Icon iconWidget = tester.widget<Icon>(iconFinder);
    expect(iconWidget.size, 28);
    expect(iconWidget.icon, Icons.folder);

    // Check that color is set from theme
    expect(iconWidget.color, isA<Color>());
    expect(iconWidget.color, isNotNull);
  });
}
