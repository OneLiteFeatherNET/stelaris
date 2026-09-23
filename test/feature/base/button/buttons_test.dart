import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/button/add_button.dart';
import 'package:stelaris/feature/base/button/cancel_button.dart';
import 'package:stelaris/feature/base/button/settings_button.dart';
import 'package:stelaris/l10n/app_localizations.dart';

Future<void> _pumpButton(WidgetTester tester, Widget button) {
  return tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: button),
    ),
  );
}

void main() {
  testWidgets('AddButton shows label and icon and triggers callback', (
    tester,
  ) async {
    var pressed = false;
    await _pumpButton(tester, AddButton(openFunction: () => pressed = true));

    expect(find.text('Add'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(pressed, isTrue);
  });

  testWidgets('CancelButton shows label and triggers callback', (tester) async {
    var pressed = false;
    await _pumpButton(tester, CancelButton(callback: () => pressed = true));

    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(pressed, isTrue);
  });

  testWidgets('SettingsButton renders an icon button with the settings icon', (
    tester,
  ) async {
    await _pumpButton(tester, const SettingsButton());

    expect(find.byType(IconButton), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });
}
