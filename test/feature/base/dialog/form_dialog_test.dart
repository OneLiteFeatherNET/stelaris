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
}
