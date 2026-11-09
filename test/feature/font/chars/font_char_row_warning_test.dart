import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/font/chars/font_char_row_warning.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  Future<void> pumpWarning(WidgetTester tester, List<String> lines) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: FontCharRowWarning(lines: lines)),
      ),
    );
  }

  testWidgets('warns about lines of different lengths', (tester) async {
    await pumpWarning(tester, ['', '']);

    expect(find.text(l10n.font_char_rows_differ('1, 3')), findsOneWidget);
  });

  testWidgets('stays hidden for lines of the same length', (tester) async {
    await pumpWarning(tester, ['', '', '']);

    expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
  });
}
