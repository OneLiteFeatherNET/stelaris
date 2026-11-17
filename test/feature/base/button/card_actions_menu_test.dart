import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/button/card_actions_menu.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/l10n/app_localizations_delegates.dart';

Future<void> _show(WidgetTester tester, List<CardMenuEntry> entries) =>
    tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: CardActionsMenu(entries: entries)),
      ),
    );

void main() {
  testWidgets('lists one item per entry', (tester) async {
    await _show(tester, [
      (icon: Icons.copy, label: 'Copy', onTap: () {}),
      (icon: Icons.delete, label: 'Remove', onTap: () {}),
    ]);

    await tester.tap(find.byTooltip('More actions'));
    await tester.pumpAndSettle();

    expect(find.byType(PopupMenuItem<void>), findsNWidgets(2));
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Remove'), findsOneWidget);
  });

  testWidgets('keeps a dialog an entry opens', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => CardActionsMenu(
              entries: [
                (
                  icon: Icons.info_outline,
                  label: 'Info',
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (_) => const AlertDialog(content: Text('Opened')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('More actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Info'));
    await tester.pumpAndSettle();

    expect(find.text('Opened'), findsOneWidget);
    expect(find.byType(PopupMenuItem<void>), findsNothing);
  });
}
