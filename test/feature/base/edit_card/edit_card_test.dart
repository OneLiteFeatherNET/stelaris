import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/edit_card/edit_card.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  Future<void> pumpCard(
    WidgetTester tester, {
    String value = '7',
    String? footer,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: EditCard(
                icon: Icons.tag,
                label: 'Ascent',
                value: value,
                footer: footer,
                onTap: readOnly ? null : onTap ?? () {},
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('the value is the larger text', (tester) async {
    await pumpCard(tester);

    final value = tester.getSize(find.text('7')).height;
    final label = tester.getSize(find.text('Ascent')).height;
    expect(value, greaterThan(label));
  });

  testWidgets('an empty value shows a placeholder', (tester) async {
    await pumpCard(tester, value: '');

    expect(find.text('Not set'), findsOneWidget);
  });

  testWidgets('the footer shows when there is one', (tester) async {
    await pumpCard(tester, footer: 'At most the height');

    expect(find.text('At most the height'), findsOneWidget);
  });

  testWidgets('a short footer takes as much room as a long one', (
    tester,
  ) async {
    await pumpCard(tester, footer: 'Short');
    final short = tester.getSize(find.byType(EditCard)).height;

    await pumpCard(
      tester,
      footer: 'A footer long enough to need a second line in the card',
    );
    final long = tester.getSize(find.byType(EditCard)).height;

    expect(short, long);
  });

  testWidgets('an edit card is outlined, not filled like a model card', (
    tester,
  ) async {
    await pumpCard(tester);

    final material = tester.widget<Material>(
      find
          .descendant(of: find.byType(Card), matching: find.byType(Material))
          .first,
    );
    expect(
      (material.shape! as RoundedRectangleBorder).side.style,
      BorderStyle.solid,
    );
  });

  testWidgets('the pencil shows on hover', (tester) async {
    await pumpCard(tester);
    double pencil() => tester
        .widget<AnimatedOpacity>(
          find.ancestor(
            of: find.byIcon(Icons.edit_outlined),
            matching: find.byType(AnimatedOpacity),
          ),
        )
        .opacity;
    expect(pencil(), 0);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(find.byType(EditCard)));
    await tester.pumpAndSettle();

    expect(pencil(), 1);
  });

  testWidgets('a tap opens the dialog', (tester) async {
    var tapped = false;
    await pumpCard(tester, onTap: () => tapped = true);

    await tester.tap(find.byType(EditCard));

    expect(tapped, isTrue);
  });

  testWidgets('a card without a tap has no pencil and no ink', (tester) async {
    await pumpCard(tester, readOnly: true);

    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(
      find.descendant(
        of: find.byType(EditCard),
        matching: find.byType(InkWell),
      ),
      findsNothing,
    );
  });

  testWidgets('a card without a tap is as high as one with it', (
    tester,
  ) async {
    await pumpCard(tester);
    final height = tester.getSize(find.byType(EditCard)).height;

    await pumpCard(tester, readOnly: true);

    expect(tester.getSize(find.byType(EditCard)).height, height);
  });
}
