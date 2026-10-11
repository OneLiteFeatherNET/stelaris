import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/component/component_preview.dart';
import 'package:stelaris/feature/component/minimessage_editor.dart';
import 'package:stelaris/feature/item/components/book/written_book_editor.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/component_context.dart';

void main() {
  Future<List<Object?>> pumpEditor(WidgetTester tester, Object? value) async {
    tester.view.physicalSize = const Size(1200, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final changes = <Object?>[];
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: Form(
              child: WrittenBookEditor(value: value, onChanged: changes.add),
            ),
          ),
        ),
      ),
    );
    return changes;
  }

  /// The field of the shown page, the first MiniMessage field.
  Finder pageField() => find
      .descendant(
        of: find.byType(MiniMessageEditor).first,
        matching: find.byType(TextField),
      )
      .first;

  String pageText(WidgetTester tester) =>
      tester.widget<TextField>(pageField()).controller!.text;

  final twoPages = {
    'title': {'raw': 'Diary'},
    'author': 'Steve',
    'pages': [
      {
        'raw': {'text': 'one', 'color': 'gold'},
      },
      {'raw': 'two'},
    ],
  };

  testWidgets('shows the first page as minimessage', (tester) async {
    await pumpEditor(tester, twoPages);

    expect(find.text('Page 1 of 2'), findsOneWidget);
    expect(pageText(tester), '<gold>one');
  });

  testWidgets('moves between the pages', (tester) async {
    await pumpEditor(tester, twoPages);

    await tester.tap(find.byKey(const Key('book_page_next')));
    await tester.pump();

    expect(find.text('Page 2 of 2'), findsOneWidget);
    expect(pageText(tester), 'two');
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('book_page_next')))
          .onPressed,
      isNull,
    );
  });

  testWidgets('typing on a page stores it as a text component', (tester) async {
    final changes = await pumpEditor(tester, twoPages);

    await tester.enterText(pageField(), '<red>first\nline');
    await tester.pump();

    final pages = (changes.last! as Map)['pages'] as List;
    expect(pages.first, {
      'raw': {'text': 'first\nline', 'color': 'red'},
    });
    expect(pages.last, {'raw': 'two'});
  });

  testWidgets('adds a page after the shown one', (tester) async {
    final changes = await pumpEditor(tester, twoPages);

    await tester.tap(find.byKey(const Key('book_page_add')));
    await tester.pump();

    expect(find.text('Page 2 of 3'), findsOneWidget);
    expect(pageText(tester), '');
    final pages = (changes.last! as Map)['pages'] as List;
    expect(pages.map((page) => (page as Map)['raw']), [
      {'text': 'one', 'color': 'gold'},
      '',
      'two',
    ]);
  });

  testWidgets('removes the shown page', (tester) async {
    final changes = await pumpEditor(tester, twoPages);

    await tester.tap(find.byKey(const Key('book_page_remove')));
    await tester.pump();

    expect(find.text('Page 1 of 1'), findsOneWidget);
    expect(pageText(tester), 'two');
    expect((changes.last! as Map)['pages'], [
      {'raw': 'two'},
    ]);
  });

  testWidgets('a book without pages offers the first one', (tester) async {
    final changes = await pumpEditor(tester, {
      'title': {'raw': ''},
      'author': '',
    });

    expect(find.text('The book has no pages yet.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('book_page_first')));
    await tester.pump();

    expect(find.text('Page 1 of 1'), findsOneWidget);
    expect((changes.last! as Map)['pages'], [
      {'raw': ''},
    ]);
  });

  testWidgets('the page is shown on paper, black and without shadow', (
    tester,
  ) async {
    await pumpEditor(tester, twoPages);

    final preview = tester.widget<ComponentPreview>(
      find.byKey(const Key('book_page_preview')),
    );
    expect(preview.componentContext, ComponentContext.bookPage);
    expect(preview.text, '<gold>one');

    final field = tester.widget<TextField>(pageField());
    expect(field.decoration!.fillColor, bookPaper);
  });

  testWidgets('title, author and generation go into the value', (tester) async {
    final changes = await pumpEditor(tester, twoPages);

    await tester.enterText(find.byKey(const Key('book_author')), 'Alex');
    await tester.tap(find.byKey(const Key('book_generation')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tattered').last);
    await tester.pumpAndSettle();

    final value = changes.last! as Map;
    expect(value['author'], 'Alex');
    expect(value['generation'], 3);
  });

  testWidgets('the filtered page and resolved sit under advanced', (
    tester,
  ) async {
    final changes = await pumpEditor(tester, twoPages);
    expect(find.byKey(const Key('book_resolved')), findsNothing);

    await tester.tap(find.text('Advanced'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('book_resolved')));
    await tester.pump();

    expect((changes.last! as Map)['resolved'], isTrue);
  });
}
