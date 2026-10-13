import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/theme/theme_settings.dart';
import 'package:stelaris/api/state/actions/theme_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/settings/rows/accessibility_settings_row.dart';
import 'package:stelaris/l10n/app_localizations.dart';

/// Keeps the actions a store is asked to run.
class _Recorder implements ActionObserver<AppState> {
  final List<ReduxAction<AppState>> dispatched = [];

  @override
  void observe(
    ReduxAction<AppState> action,
    int dispatchCount, {
    required bool ini,
  }) {
    if (ini) dispatched.add(action);
  }

  int get fontScaleUpdates =>
      dispatched.whereType<UpdateFontScaleAction>().length;
}

void main() {
  group('AccessibilitySettingsRow Widget Tests', () {
    Future<Store<AppState>> pumpRow(
      WidgetTester tester,
      _Recorder recorder, {
      double fontScale = 1,
    }) async {
      final store = Store<AppState>(
        initialState: AppState(
          themeSettings: ThemeSettings.defaultSettings().copyWith(
            fontScale: fontScale,
          ),
        ),
        actionObservers: [recorder],
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
        tester.widget<Text>(sample()).textScaler!;

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
      await pumpRow(tester, _Recorder());

      expect(find.text('Accessibility'), findsOneWidget);
      expect(find.text('Font Size'), findsOneWidget);
      expect(sample(), findsOneWidget);
    });

    testWidgets('scales the sample while dragging', (tester) async {
      await pumpRow(tester, _Recorder());
      final heightBefore = tester.getSize(sample()).height;

      final gesture = await dragToMax(tester);

      expect(sampleScaler(tester), const TextScaler.linear(1.4));
      expect(tester.getSize(sample()).height, greaterThan(heightBefore));
      await gesture.up();
    });

    testWidgets('keeps the stored font scale while dragging', (tester) async {
      final recorder = _Recorder();
      final store = await pumpRow(tester, recorder);

      final gesture = await dragToMax(tester);

      expect(store.state.themeSettings.fontScale, 1);
      expect(recorder.fontScaleUpdates, 0);
      await gesture.up();
    });

    testWidgets('stores the font scale once when the drag ends', (
      tester,
    ) async {
      final recorder = _Recorder();
      final store = await pumpRow(tester, recorder);

      final gesture = await dragToMax(tester);
      await gesture.up();
      await tester.pumpAndSettle();

      expect(recorder.fontScaleUpdates, 1);
      expect(store.state.themeSettings.fontScale, 1.4);
    });

    testWidgets('disables reset at the default font scale', (tester) async {
      await pumpRow(tester, _Recorder());

      expect(tester.widget<TextButton>(resetButton()).onPressed, isNull);
    });

    testWidgets('restores the font scale when reset is tapped', (tester) async {
      final store = await pumpRow(tester, _Recorder(), fontScale: 1.4);

      await tester.tap(resetButton());
      await tester.pumpAndSettle();

      expect(store.state.themeSettings.fontScale, 1);
    });

    testWidgets('moves the slider when reset is tapped', (tester) async {
      await pumpRow(tester, _Recorder(), fontScale: 1.4);
      expect(sliderValue(tester), 1.4);

      await tester.tap(resetButton());
      await tester.pumpAndSettle();

      expect(sliderValue(tester), 1);
    });
  });
}
