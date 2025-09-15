import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/base/button/settings_button.dart';
import 'package:stelaris/feature/settings/settings_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  group('Settings button test', () {
    testWidgets('layout', (tester) async {
      final SettingsButton settingsButton = const SettingsButton();

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SettingsButton())),
      );

      // Verify the button is present
      expect(find.byType(IconButton), findsOneWidget);

      // Verify the settings icon is present
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('dialog popup', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SettingsButton()),
        ),
      );

      // Tap the settings button
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Verify that the dialog is shown
      expect(find.byType(SettingsDialog), findsOneWidget);
    });
  });
}
