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
}
