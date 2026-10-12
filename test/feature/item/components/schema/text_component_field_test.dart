import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/component/component_toolbar.dart';
import 'package:stelaris/feature/item/components/schema/schema_field.dart';
import 'package:stelaris/feature/item/components/schema/schema_value.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/l10n/app_localizations_en.dart';
import 'package:vulpes_data/component.dart';

void main() {
  Future<void> pumpField(
    WidgetTester tester, {
    required Object? value,
    required List<Object?> changes,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SchemaField(
            schema: const TextSchema(),
            label: 'Name',
            value: value,
            onChanged: changes.add,
          ),
        ),
      ),
    );
  }

  String fieldText(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).controller!.text;

  testWidgets('a text component gets the formatting toolbar', (tester) async {
    await pumpField(tester, value: '', changes: []);
    // Built a frame after the field.
    await tester.pump();

    expect(find.byType(ComponentToolbar), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
  });

  testWidgets('shows the stored json as minimessage', (tester) async {
    await pumpField(
      tester,
      value: {'text': 'Epic', 'color': 'gold', 'bold': true},
      changes: [],
    );

    expect(fieldText(tester), '<gold><b>Epic');
  });

  testWidgets('hands out what is typed as json', (tester) async {
    final changes = <Object?>[];
    await pumpField(tester, value: '', changes: changes);

    await tester.enterText(find.byType(TextField), '<gold>Epic');
    await tester.pump();

    expect(changes.last, {'text': 'Epic', 'color': 'gold'});
  });

  testWidgets('keeps the typed text, json would rewrite it', (tester) async {
    final changes = <Object?>[];
    Object? value = '';
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SchemaField(
              schema: const TextSchema(),
              value: value,
              onChanged: (next) => setState(() {
                changes.add(next);
                value = next;
              }),
            ),
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextField),
      '<gradient:red:blue>Fire</gradient>',
    );
    await tester.pump();

    expect(fieldText(tester), '<gradient:red:blue>Fire</gradient>');
    expect((changes.last! as Map)['extra'], hasLength(4));
  });

  testWidgets('a new value from outside replaces the text', (tester) async {
    await pumpField(tester, value: 'old', changes: []);
    await pumpField(
      tester,
      value: {'text': 'new', 'color': 'red'},
      changes: [],
    );

    expect(fieldText(tester), '<red>new');
  });

  testWidgets('keeps line breaks, book pages need them', (tester) async {
    final changes = <Object?>[];
    await pumpField(tester, value: '', changes: changes);

    await tester.enterText(find.byType(TextField), '<gold>one\ntwo');
    await tester.pump();

    expect(fieldText(tester), '<gold>one\ntwo');
    expect(changes.last, {'text': 'one\ntwo', 'color': 'gold'});
  });

  test('the card shows only the text', () {
    expect(
      summarize(AppLocalizationsEn(), const TextSchema(), {
        'text': '',
        'extra': [
          {'text': 'Epic ', 'color': 'gold'},
          {'text': 'Sword', 'bold': true},
        ],
      }),
      'Epic Sword',
    );
  });
}
