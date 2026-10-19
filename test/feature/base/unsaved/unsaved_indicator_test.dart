import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/unsaved/unsaved_indicator.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  const dot = Key('page_header_unsaved_indicator');
  const pulse = Key('unsaved_indicator_pulse');

  Widget wrap(bool visible, {bool disableAnimations = false}) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Scaffold(
        body: Center(child: UnsavedIndicator(visible: visible)),
      ),
    ),
  );

  double scaleOf(WidgetTester tester) => tester
      .widget<ScaleTransition>(
        find
            .ancestor(
              of: find.byKey(dot),
              matching: find.byType(ScaleTransition),
            )
            .first,
      )
      .scale
      .value;

  testWidgets('shows the dot at once when it is visible from the start', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(true));

    expect(scaleOf(tester), 1);
    expect(find.byKey(pulse), findsNothing);
  });

  testWidgets('pops the dot in and pulses once when it becomes visible', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(false));
    expect(find.byKey(dot), findsNothing);

    await tester.pumpWidget(wrap(true));
    expect(scaleOf(tester), lessThan(1));
    expect(find.byKey(pulse), findsOneWidget);

    // Settles, so the pulse does not repeat.
    await tester.pumpAndSettle();
    expect(scaleOf(tester), 1);
    expect(find.byKey(pulse), findsNothing);
  });

  testWidgets('fades the dot out before removing it', (tester) async {
    await tester.pumpWidget(wrap(true));

    await tester.pumpWidget(wrap(false));
    expect(find.byKey(dot), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byKey(dot), findsNothing);
  });

  testWidgets('shows and hides the dot at once when animations are '
      'disabled', (tester) async {
    await tester.pumpWidget(wrap(false, disableAnimations: true));

    await tester.pumpWidget(wrap(true, disableAnimations: true));
    expect(scaleOf(tester), 1);
    expect(find.byKey(pulse), findsNothing);

    await tester.pumpWidget(wrap(false, disableAnimations: true));
    expect(find.byKey(dot), findsNothing);
  });
}
