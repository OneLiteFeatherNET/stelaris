import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/info_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  Future<void> pumpOpened(WidgetTester tester, {Widget? footer}) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => InfoDialog(
                  title: 'Title',
                  intro: 'Intro',
                  topics: const [
                    InfoTopic(icon: Icons.abc, title: 'One', text: 'First'),
                    InfoTopic(icon: Icons.abc, title: 'Two', text: 'Second'),
                  ],
                  footer: footer,
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the title, the intro, every topic and the footer', (
    tester,
  ) async {
    await pumpOpened(tester, footer: const Text('Footer'));

    for (final text in ['Title', 'Intro', 'One', 'First', 'Two', 'Second']) {
      expect(find.text(text), findsOneWidget);
    }
    expect(find.text('Footer'), findsOneWidget);
  });

  testWidgets('the close button ends the dialog', (tester) async {
    await pumpOpened(tester);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.byType(InfoDialog), findsNothing);
  });
}
