import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/edit_card/edit_card_grid.dart';
import 'package:stelaris/feature/base/edit_card/edit_field.dart';
import 'package:stelaris/feature/base/edit_card/edit_section_card.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  Future<void> pumpGrid(WidgetTester tester, {Widget? trailing}) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 800,
            child: EditCardGrid(
              sections: [
                EditSection(
                  title: 'Signature',
                  fields: [
                    TextEdit(
                      label: 'Name',
                      icon: Icons.functions,
                      value: 'damage',
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ],
              trailing: trailing,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('the trailing widget sits below the sections', (tester) async {
    await pumpGrid(
      tester,
      trailing: const SizedBox(height: 40, key: Key('trailing')),
    );

    final trailing = tester.getRect(find.byKey(const Key('trailing')));
    final heading = tester.getRect(find.text('Signature'));
    final card = tester.getRect(find.text('damage'));
    expect(trailing.top, greaterThan(card.bottom));
    expect(trailing.left, heading.left);
  });

  testWidgets('the trailing widget takes the full width of the sections', (
    tester,
  ) async {
    await pumpGrid(
      tester,
      trailing: const SizedBox(height: 40, key: Key('trailing')),
    );

    final grid = tester.getRect(find.byType(EditCardGrid));
    final trailing = tester.getRect(find.byKey(const Key('trailing')));
    expect(grid.right - trailing.right, trailing.left - grid.left);
  });

  testWidgets('without a trailing widget only the sections show', (
    tester,
  ) async {
    await pumpGrid(tester);

    expect(find.text('damage'), findsOneWidget);
    expect(find.byKey(const Key('trailing')), findsNothing);
  });

  testWidgets('a section card is filled, flat and insets its child', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => const EditSectionCard(
              child: SizedBox(height: 20, key: Key('child')),
            ),
          ),
        ),
      ),
    );

    final card = tester.widget<Card>(find.byType(Card));
    final context = tester.element(find.byType(EditSectionCard));
    expect(card.color, Theme.of(context).colorScheme.surfaceContainerLow);
    expect(card.margin, EdgeInsets.zero);
    final outer = tester.getRect(find.byType(Card));
    final inner = tester.getRect(find.byKey(const Key('child')));
    expect(inner.left - outer.left, 16);
    expect(inner.top - outer.top, 16);
  });
}
