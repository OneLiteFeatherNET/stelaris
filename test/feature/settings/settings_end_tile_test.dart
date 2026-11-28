import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/settings/settings_end_tile.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/l10n/app_localizations_delegates.dart';
import 'package:stelaris/util/stelaris_icons.dart';

void main() {
  group('SettingsEndTile Widget Tests', () {
    Future<void> pumpTile(WidgetTester tester, Clock clock) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SettingsEndTile(clock: clock)),
        ),
      );
    }

    testWidgets('shows the year of the clock', (tester) async {
      await pumpTile(tester, Clock.fixed(DateTime(2042, 6, 15)));

      expect(find.textContaining('© 2042 Onelitefeather'), findsOneWidget);
    });

    testWidgets('credits the team', (tester) async {
      await pumpTile(tester, Clock.fixed(DateTime(2031)));

      expect(find.textContaining('Made with'), findsOneWidget);
      expect(find.textContaining('by the team'), findsOneWidget);
    });

    testWidgets('draws the heart as an icon, not as a text glyph', (
      tester,
    ) async {
      await pumpTile(tester, Clock.fixed(DateTime(2031)));

      final heart = tester.widget<Icon>(
        find.byKey(const Key('settings_end_tile_heart')),
      );
      expect(heart.icon, StelarisIcons.heart);
      expect(find.textContaining('❤'), findsNothing);
      expect(find.textContaining('\u0000'), findsNothing);
    });
  });
}
