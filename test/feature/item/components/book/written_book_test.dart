import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/item/components/book/written_book.dart';

void main() {
  test('reads titles and pages as objects with raw and filtered', () {
    final book = WrittenBook.fromJson({
      'title': {'raw': 'Diary', 'filtered': 'D***y'},
      'author': 'Steve',
      'generation': 2,
      'pages': [
        {
          'raw': {'text': 'Hi', 'color': 'gold'},
          'filtered': 'H*',
        },
      ],
      'resolved': true,
    });

    expect(book.title, 'Diary');
    expect(book.filteredTitle, 'D***y');
    expect(book.author, 'Steve');
    expect(book.generation, 2);
    expect(book.pages.single.raw, '<gold>Hi');
    expect(book.pages.single.filtered, 'H*');
    expect(book.resolved, isTrue);
  });

  test('reads plain titles and pages too, the game writes both', () {
    final book = WrittenBook.fromJson({
      'title': 'Diary',
      'author': 'Steve',
      'pages': [
        'one',
        {'text': 'two', 'bold': true},
      ],
    });

    expect(book.title, 'Diary');
    expect(book.filteredTitle, isNull);
    expect(book.pages.map((page) => page.raw), ['one', '<b>two']);
    expect(book.pages.map((page) => page.filtered), [null, null]);
  });

  test('a new component starts empty', () {
    final book = WrittenBook.fromJson({
      'title': {'raw': ''},
      'author': '',
    });

    expect(book.title, '');
    expect(book.pages, isEmpty);
    expect(book.generation, isNull);
  });

  test('writes only the parts that are set', () {
    const book = WrittenBook(title: 'Diary', author: 'Steve');

    expect(book.toJson(), {
      'title': {'raw': 'Diary'},
      'author': 'Steve',
    });
  });

  test('writes the pages as text components', () {
    const book = WrittenBook(
      title: 'Diary',
      filteredTitle: 'D***y',
      author: 'Steve',
      generation: 1,
      pages: [
        BookPage(raw: '<gold>Hi'),
        BookPage(raw: 'one\ntwo', filtered: 'o**'),
      ],
      resolved: false,
    );

    expect(book.toJson(), {
      'title': {'raw': 'Diary', 'filtered': 'D***y'},
      'author': 'Steve',
      'generation': 1,
      'pages': [
        {
          'raw': {'text': 'Hi', 'color': 'gold'},
        },
        {'raw': 'one\ntwo', 'filtered': 'o**'},
      ],
      'resolved': false,
    });
  });

  test('a round trip keeps the book', () {
    const book = WrittenBook(
      title: 'Diary',
      author: 'Steve',
      generation: 3,
      pages: [
        BookPage(raw: '<red>Day <b>one'),
        BookPage(raw: 'end'),
      ],
    );

    final again = WrittenBook.fromJson(book.toJson());
    expect(again.toJson(), book.toJson());
    expect(again.pages.first.raw, '<red>Day <b>one');
  });
}
