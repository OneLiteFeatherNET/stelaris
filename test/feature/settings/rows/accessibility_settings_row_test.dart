import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/theme/theme_settings.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/settings/rows/accessibility_settings_row.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  group('AccessibilitySettingsRow Widget Tests', () {
    Future<Store<AppState>> pumpRow(
      WidgetTester tester, {
      double fontScale = 1,
    }) async {
      final store = Store<AppState>(
        initialState: AppState(
          themeSettings: ThemeSettings.defaultSettings().copyWith(
            fontScale: fontScale,
          ),
        ),
      );

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(child: AccessibilitySettingsRow()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return store;
    }

    Finder sample() =>
        find.text('The quick brown fox jumps over the lazy dog.');

    TextScaler sampleScaler(WidgetTester tester) =>
        tester.widget<Text>(sample()).textScaler ??
        MediaQuery.textScalerOf(tester.element(sample()));

    double sliderValue(WidgetTester tester) =>
        tester.widget<Slider>(find.byType(Slider)).value;

    Finder resetButton() => find.widgetWithText(TextButton, 'Reset');

    /// Presses the slider and drags its thumb to the far end, without
    /// releasing it.
    Future<TestGesture> dragToMax(WidgetTester tester) async {
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(Slider)),
      );
      await gesture.moveBy(const Offset(40, 0));
      await gesture.moveBy(const Offset(400, 0));
      await tester.pump();
      return gesture;
    }

    testWidgets('shows the font size heading and a sample text', (
      tester,
    ) async {
      await pumpRow(tester);

      expect(find.text('Accessibility'), findsOneWidget);
      expect(find.text('Font Size'), findsOneWidget);
      expect(sample(), findsOneWidget);
    });

    testWidgets('scales the sample while dragging', (tester) async {
      await pumpRow(tester);

      final gesture = await dragToMax(tester);

      expect(sampleScaler(tester), const TextScaler.linear(1.4));
      await gesture.up();
    });

    testWidgets('keeps the stored font scale while dragging', (tester) async {
      final store = await pumpRow(tester);

      final gesture = await dragToMax(tester);

      expect(store.state.themeSettings.fontScale, 1);
      await gesture.up();
    });

    testWidgets('stores the font scale once when the drag ends', (
      tester,
    ) async {
      final store = await pumpRow(tester);
      final changes = <double>[];
      final subscription = store.onChange.listen(
        (state) => changes.add(state.themeSettings.fontScale),
      );
      addTearDown(subscription.cancel);

      final gesture = await dragToMax(tester);
      await gesture.up();
      await tester.pumpAndSettle();

      expect(changes, [1.4]);
      expect(store.state.themeSettings.fontScale, 1.4);
    });

    testWidgets('disables reset at the default font scale', (tester) async {
      await pumpRow(tester);

      expect(tester.widget<TextButton>(resetButton()).onPressed, isNull);
    });

    testWidgets('restores the font scale when reset is tapped', (tester) async {
      final store = await pumpRow(tester, fontScale: 1.4);

      await tester.tap(resetButton());
      await tester.pumpAndSettle();

      expect(store.state.themeSettings.fontScale, 1);
    });

    testWidgets('moves the slider when reset is tapped', (tester) async {
      await pumpRow(tester, fontScale: 1.4);
      expect(sliderValue(tester), 1.4);

      await tester.tap(resetButton());
      await tester.pumpAndSettle();

      expect(sliderValue(tester), 1);
    });
  });
}
