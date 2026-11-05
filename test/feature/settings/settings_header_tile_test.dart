import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/settings/settings_header_tile.dart';

Future<void> _pumpTile(WidgetTester tester, SettingsHeaderTile tile) {
  return tester.pumpWidget(MaterialApp(home: Scaffold(body: tile)));
}

void main() {
  testWidgets('a dialog header shows a close button', (tester) async {
    await _pumpTile(tester, const SettingsHeaderTile(text: 'Settings'));

    expect(
      find.byIcon(Icons.close),
      findsOneWidget,
      reason: 'a dialog needs a way to close it from its header',
    );
  });

  testWidgets('a page header shows no close button', (tester) async {
    await _pumpTile(
      tester,
      const SettingsHeaderTile(text: 'Generator', closable: false),
    );

    expect(
      find.byIcon(Icons.close),
      findsNothing,
      reason: 'a page has no route of its own to pop from its header',
    );
    expect(find.text('Generator'), findsOneWidget);
  });
}
