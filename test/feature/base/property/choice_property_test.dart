import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/property/property.dart';
import 'package:stelaris/feature/base/property/property_card.dart';
import 'package:stelaris/feature/base/property/property_grid.dart';
import 'package:stelaris/l10n/app_localizations.dart';

enum Frame { task, goal, challenge }

void main() {
  Frame? changed;

  Future<void> pumpGrid(WidgetTester tester, List<Property> properties) async {
    changed = null;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: PropertyGrid(properties: properties)),
      ),
    );
  }

  ChoiceProperty<Frame> frame() => ChoiceProperty<Frame>(
    label: 'Frame',
    value: Frame.goal,
    options: Frame.values,
    display: (frame) => frame.name.toUpperCase(),
    help: 'The frame of the toast',
    onChanged: (frame) => changed = frame,
  );

  testWidgets('the grid shows one card per property', (tester) async {
    await pumpGrid(tester, [
      frame(),
      TextProperty(label: 'Title', value: 'Hi', onChanged: (_) {}),
    ]);

    expect(find.byType(PropertyCard), findsNWidgets(2));
    expect(find.text('GOAL'), findsOneWidget);
    expect(find.text('Hi'), findsOneWidget);
  });

  testWidgets('the dialog marks the current option', (tester) async {
    await pumpGrid(tester, [frame()]);

    await tester.tap(find.text('Frame'));
    await tester.pumpAndSettle();

    expect(find.byType(FormDialog), findsOneWidget);
    final current = find.ancestor(
      of: find.text('GOAL').last,
      matching: find.byType(ListTile),
    );
    expect(tester.widget<ListTile>(current).selected, isTrue);
  });

  testWidgets('the dialog explains the field under its title', (tester) async {
    await pumpGrid(tester, [frame()]);

    await tester.tap(find.text('Frame'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(FormDialog),
        matching: find.text('The frame of the toast'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('picking another option reports it', (tester) async {
    await pumpGrid(tester, [frame()]);
    await tester.tap(find.text('Frame'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('CHALLENGE'));
    await tester.pumpAndSettle();

    expect(changed, Frame.challenge);
    expect(find.byType(FormDialog), findsNothing);
  });

  testWidgets('picking the current option reports nothing', (tester) async {
    await pumpGrid(tester, [frame()]);
    await tester.tap(find.text('Frame'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('GOAL').last);
    await tester.pumpAndSettle();

    expect(changed, isNull);
  });

  testWidgets('the cards grow with larger text instead of cutting it off', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: Scaffold(
            body: PropertyGrid(
              properties: [
                frame(),
                TextProperty(label: 'Title', value: 'Hi', onChanged: (_) {}),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('GOAL'), findsOneWidget);
  });

  testWidgets('the cards are as tall as the component cards', (tester) async {
    await pumpGrid(tester, [frame()]);

    expect(tester.getSize(find.byType(PropertyCard)).height, 112);
  });

  testWidgets('the info button shows the help in a dialog', (tester) async {
    await pumpGrid(tester, [frame()]);

    await tester.tap(find.byIcon(Icons.info_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(FormDialog), findsOneWidget);
    expect(find.text('The frame of the toast'), findsOneWidget);
    // Only the help, not the options to pick from.
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('a field without help has no info button', (tester) async {
    await pumpGrid(tester, [
      TextProperty(label: 'Title', value: 'Hi', onChanged: (_) {}),
    ]);

    expect(find.byIcon(Icons.info_outline_rounded), findsNothing);
  });
}
