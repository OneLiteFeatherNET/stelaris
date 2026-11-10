import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  testWidgets('the scrollbar runs beside the content, not over it', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: FormDialog(
            title: 'Long',
            actionLabel: 'Save',
            onSubmit: () {},
            content: const SizedBox(
              key: Key('content'),
              width: double.infinity,
              height: 2000,
            ),
          ),
        ),
      ),
    );

    final viewport = tester.getRect(find.byType(SingleChildScrollView));
    final content = tester.getRect(find.byKey(const Key('content')));
    final title = tester.getRect(find.text('Long'));

    // The content keeps the dialog padding to the edge of the scroll view,
    // where the scrollbar is drawn.
    expect(viewport.right - content.right, 24);
    // And lines up with the parts outside of it.
    expect(content.left, title.left);
    expect(
      tester.getRect(find.widgetWithIcon(IconButton, Icons.close)).right,
      content.right,
    );
  });

  /// Opens a dialog with [dialog] behind a button, so it can close.
  Future<void> open(WidgetTester tester, FormDialog dialog) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  showDialog<void>(context: context, builder: (_) => dialog),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('the leading widget sits before the title', (tester) async {
    await open(
      tester,
      FormDialog(
        title: 'Step',
        actionLabel: 'Save',
        onSubmit: () {},
        leading: const Icon(Icons.arrow_back),
        content: const SizedBox(),
      ),
    );

    expect(
      tester.getRect(find.byIcon(Icons.arrow_back)).right,
      lessThan(tester.getRect(find.text('Step')).left),
    );
  });

  testWidgets('cancel closes the dialog', (tester) async {
    await open(
      tester,
      FormDialog(
        title: 'Step',
        actionLabel: 'Save',
        onSubmit: () {},
        content: const SizedBox(),
      ),
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(FormDialog), findsNothing);
  });

  testWidgets('a custom cancel replaces closing, the close icon still closes', (
    tester,
  ) async {
    var cancelled = 0;
    await open(
      tester,
      FormDialog(
        title: 'Step',
        actionLabel: 'Save',
        onSubmit: () {},
        onCancel: () => cancelled++,
        content: const SizedBox(),
      ),
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(cancelled, 1);
    expect(find.byType(FormDialog), findsOneWidget);

    await tester.tap(find.widgetWithIcon(IconButton, Icons.close));
    await tester.pumpAndSettle();

    expect(cancelled, 1);
    expect(find.byType(FormDialog), findsNothing);
  });
}
