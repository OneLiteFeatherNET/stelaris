import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/settings/rows/misc_settings_row.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/constants.dart';

void main() {
  group('MiscSettingsRow Widget Tests', () {
    testWidgets('displays app version header, subtitle, and badge', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: MiscSettingsRow()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('App Version'), findsOneWidget);
      expect(
        find.text('Currently installed version of Stelaris'),
        findsOneWidget,
      );
      expect(find.text('v$appVersion'), findsOneWidget);
    });
  });
}
