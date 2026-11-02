import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  Widget wrap(Widget child, {double width = 800}) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(child: SizedBox(width: width, child: child)),
    ),
  );

  testWidgets('shows the back arrow only with onBack', (tester) async {
    await tester.pumpWidget(wrap(const PageHeader(title: 'Items')));
    expect(find.byKey(const Key('page_header_back_button')), findsNothing);

    var tapped = false;
    await tester.pumpWidget(
      wrap(PageHeader(title: 'Items', onBack: () => tapped = true)),
    );
    await tester.tap(find.byKey(const Key('page_header_back_button')));
    expect(tapped, isTrue);
  });

  testWidgets('shows the unsaved indicator only when asked', (tester) async {
    await tester.pumpWidget(wrap(const PageHeader(title: 'Sword')));
    expect(find.byKey(const Key('page_header_unsaved_indicator')), findsNothing);

    await tester.pumpWidget(
      wrap(const PageHeader(title: 'Sword', showUnsavedIndicator: true)),
    );
    expect(
      find.byKey(const Key('page_header_unsaved_indicator')),
      findsOneWidget,
    );
  });

  testWidgets('a small header has a smaller title than a page header', (
    tester,
  ) async {
    double fontSize() =>
        tester.widget<Text>(find.text('Lore')).style!.fontSize!;

    await tester.pumpWidget(wrap(const PageHeader(title: 'Lore')));
    final page = fontSize();
    await tester.pumpWidget(
      wrap(const PageHeader.small(title: 'Lore')),
    );

    expect(fontSize(), lessThan(page));
  });

  testWidgets('actions show their label when wide', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      wrap(
        PageHeader(
          title: 'Items',
          actions: [
            PageHeaderAction(
              icon: const Icon(Icons.add),
              label: 'Add',
              primary: true,
              onPressed: () => pressed = true,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Add'), findsOneWidget);
    await tester.tap(find.text('Add'));
    expect(pressed, isTrue);
  });

  testWidgets('actions collapse to icon buttons below 480px', (tester) async {
    await tester.pumpWidget(
      wrap(
        width: 400,
        PageHeader(
          title: 'Items',
          actions: [
            PageHeaderAction(
              icon: const Icon(Icons.add),
              label: 'Add',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );

    expect(find.text('Add'), findsNothing);
    expect(find.byTooltip('Add'), findsOneWidget);
  });

  testWidgets('a header can collapse its actions earlier', (tester) async {
    await tester.pumpWidget(
      wrap(
        width: 700,
        PageHeader(
          title: 'Sword',
          compactBelow: 960,
          actions: [
            PageHeaderAction(
              icon: const Icon(Icons.save),
              label: 'Save',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );

    expect(find.text('Save'), findsNothing);
    expect(find.byTooltip('Save'), findsOneWidget);
  });

  testWidgets('a loading action shows a spinner and is disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const PageHeader(
          title: 'Items',
          actions: [
            PageHeaderAction(
              icon: Icon(Icons.refresh),
              label: 'Refresh',
              loading: true,
              onPressed: null,
            ),
          ],
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsNothing);
  });

  testWidgets('a long title does not overflow next to its actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        width: 360,
        PageHeader(
          title: 'A very long model name that will never fit on one line',
          onBack: () {},
          showUnsavedIndicator: true,
          actions: [
            PageHeaderAction(
              icon: const Icon(Icons.save),
              label: 'Save',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  /// The [Semantics] a toggle action wraps its button in, by its state.
  Finder toggled(bool? value) => find.byWidgetPredicate(
    (widget) => widget is Semantics && widget.properties.toggled == value,
  );

  group('a toggle action', () {
    Widget toggle({required bool selected, double width = 800}) => wrap(
      width: width,
      PageHeader(
        title: 'Expression',
        actions: [
          PageHeaderAction.toggle(
            icon: const Icon(Icons.preview),
            label: 'Preview',
            selected: selected,
            onPressed: () {},
          ),
        ],
      ),
    );

    testWidgets('is tonal and reported on while on', (tester) async {
      await tester.pumpWidget(toggle(selected: true));

      expect(find.byType(OutlinedButton), findsNothing);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(toggled(true), findsOneWidget);
    });

    testWidgets('is outlined and reported off while off', (tester) async {
      await tester.pumpWidget(toggle(selected: false));

      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
      expect(toggled(false), findsOneWidget);
    });

    testWidgets('collapses to an icon button with its label as tooltip', (
      tester,
    ) async {
      await tester.pumpWidget(toggle(selected: false, width: 400));

      expect(find.text('Preview'), findsNothing);
      expect(tester.widget<IconButton>(find.byType(IconButton)).tooltip, 'Preview');
      expect(toggled(false), findsOneWidget);
    });
  });

  testWidgets('a plain action reports no toggled state', (tester) async {
    await tester.pumpWidget(
      wrap(
        PageHeader(
          title: 'Items',
          actions: [
            PageHeaderAction(
              icon: const Icon(Icons.refresh),
              label: 'Refresh',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );

    expect(toggled(true), findsNothing);
    expect(toggled(false), findsNothing);
  });
}
