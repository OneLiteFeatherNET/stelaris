import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/theme/theme_settings.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/settings/rows/theme_settings_row.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  group('ThemeSettingsRow Widget Tests', () {
    Future<Store<AppState>> pumpRow(
      WidgetTester tester, {
      ThemeSettings? settings,
    }) async {
      final store = Store<AppState>(
        initialState: AppState(
          themeSettings: settings ?? ThemeSettings.defaultSettings(),
        ),
      );

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(child: ThemeSettingsRow()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return store;
    }

    Set<ThemeMode> selectedMode(WidgetTester tester) => tester
        .widget<SegmentedButton<ThemeMode>>(
          find.byType(SegmentedButton<ThemeMode>),
        )
        .selected;

    Finder resetButton() => find.widgetWithText(TextButton, 'Reset');

    testWidgets('offers system, light and dark', (tester) async {
      await pumpRow(tester);

      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('marks system for the default settings', (tester) async {
      await pumpRow(tester);

      expect(selectedMode(tester), {ThemeMode.system});
    });

    testWidgets('marks light for a manual light choice', (tester) async {
      await pumpRow(
        tester,
        settings: ThemeSettings.defaultSettings().copyWith(
          useSystemTheme: false,
          isDarkMode: false,
        ),
      );

      expect(selectedMode(tester), {ThemeMode.light});
    });

    testWidgets('turns system off and dark on when dark is tapped', (
      tester,
    ) async {
      final store = await pumpRow(tester);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(store.state.themeSettings.useSystemTheme, isFalse);
      expect(store.state.themeSettings.isDarkMode, isTrue);
      expect(selectedMode(tester), {ThemeMode.dark});
    });

    testWidgets('turns system on when system is tapped', (tester) async {
      final store = await pumpRow(
        tester,
        settings: ThemeSettings.defaultSettings().copyWith(
          useSystemTheme: false,
          isDarkMode: true,
        ),
      );

      await tester.tap(find.text('System'));
      await tester.pumpAndSettle();

      expect(store.state.themeSettings.useSystemTheme, isTrue);
    });

    testWidgets('sets the primary color when a swatch is tapped', (
      tester,
    ) async {
      final store = await pumpRow(tester);

      await tester.tap(find.byTooltip('Red'));
      await tester.pumpAndSettle();

      expect(store.state.themeSettings.primaryColor, Colors.red);
    });

    testWidgets('marks the swatch of the current color', (tester) async {
      await pumpRow(
        tester,
        settings: ThemeSettings.defaultSettings().copyWith(
          primaryColor: Colors.red,
        ),
      );

      expect(
        find.descendant(
          of: find.byTooltip('Red'),
          matching: find.byIcon(Icons.check),
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('marks no swatch for a color outside the list', (tester) async {
      await pumpRow(
        tester,
        settings: ThemeSettings.defaultSettings().copyWith(
          primaryColor: const Color(0xFF123456),
        ),
      );

      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('disables reset at the defaults', (tester) async {
      await pumpRow(tester);

      expect(tester.widget<TextButton>(resetButton()).onPressed, isNull);
    });

    testWidgets('restores the defaults when reset is tapped', (tester) async {
      final store = await pumpRow(
        tester,
        settings: ThemeSettings.defaultSettings().copyWith(
          useSystemTheme: false,
          isDarkMode: true,
          primaryColor: Colors.red,
          fontScale: 1.4,
        ),
      );

      await tester.tap(resetButton());
      await tester.pumpAndSettle();

      expect(store.state.themeSettings.themeMode, ThemeMode.system);
      expect(store.state.themeSettings.primaryColor, Colors.blue);
      expect(tester.widget<TextButton>(resetButton()).onPressed, isNull);
    });

    testWidgets('keeps the font scale when reset is tapped', (tester) async {
      final store = await pumpRow(
        tester,
        settings: ThemeSettings.defaultSettings().copyWith(
          primaryColor: Colors.red,
          fontScale: 1.4,
        ),
      );

      await tester.tap(resetButton());
      await tester.pumpAndSettle();

      expect(store.state.themeSettings.fontScale, 1.4);
    });
  });
}
