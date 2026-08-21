import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/base/button/cancel_button.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  testWidgets('Cancel button shows label and triggers callback',
          (WidgetTester tester) async {
        var pressed = false;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: CancelButton(
                callback: () {
                  pressed = true;
                },
              ),
            ),
          ),
        );

        // Verify that the localized text is present
        expect(find.text('Cancel'), findsOneWidget); // Replace with actual translation in en.arb

        // Tap the button
        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();

        // Verify callback executed
        expect(pressed, isTrue);
      });
}
