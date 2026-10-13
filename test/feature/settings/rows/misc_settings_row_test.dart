import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/settings/rows/misc_settings_row.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/constants.dart';

void main() {
  group('MiscSettingsRow Widget Tests', () {
    Future<void> pumpRow(WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SingleChildScrollView(child: MiscSettingsRow())),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('displays the about heading', (tester) async {
      await pumpRow(tester);

      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('displays app version header, subtitle, and badge', (
      tester,
    ) async {
      await pumpRow(tester);

      expect(find.text('App Version'), findsOneWidget);
      expect(
        find.text('Currently installed version of Stelaris'),
        findsOneWidget,
      );
      expect(find.text(appVersion), findsOneWidget);
    });

    testWidgets('displays the licenses card', (tester) async {
      await pumpRow(tester);

      expect(find.text('Third-party software licenses'), findsOneWidget);
    });

    testWidgets('opens the license page from the licenses card', (
      tester,
    ) async {
      await pumpRow(tester);

      await tester.tap(find.text('Third-party software licenses'));
      await tester.pumpAndSettle();

      expect(find.byType(LicensePage), findsOneWidget);
    });

    testWidgets('displays one issues card for bugs and suggestions', (
      tester,
    ) async {
      await pumpRow(tester);

      expect(find.text('Issues'), findsOneWidget);
      expect(find.text('Report a bug or suggest a feature'), findsOneWidget);
    });

    testWidgets('displays one help card for the wiki', (tester) async {
      await pumpRow(tester);

      expect(find.text('Help'), findsOneWidget);
      expect(find.text('Explore the wiki for assistance'), findsOneWidget);
    });
  });
}
