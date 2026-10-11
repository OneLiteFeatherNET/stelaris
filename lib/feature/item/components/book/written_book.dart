import 'package:stelaris/util/minimessage_json.dart';

/// The key of the component a [WrittenBook] is the value of.
const String writtenBookComponent = 'minecraft:written_book_content';

/// The longest title the game accepts.
const int maxBookTitleLength = 32;

/// The most pages the game keeps.
const int maxBookPages = 100;

/// One page, as MiniMessage. [filtered] is shown instead to players with the
/// chat filter on, null for none.
class BookPage {
  const BookPage({this.raw = '', this.filtered});

  final String raw;
  final String? filtered;

  BookPage copyWith({String? raw, String? Function()? filtered}) => BookPage(
    raw: raw ?? this.raw,
    filtered: filtered == null ? this.filtered : filtered(),
  );
}

/// The value of `minecraft:written_book_content`, with its pages as
/// MiniMessage. Converts from and to the vanilla JSON the backend stores.
class WrittenBook {
  const WrittenBook({
    this.title = '',
    this.filteredTitle,
    this.author = '',
    this.generation,
    this.pages = const [],
    this.resolved,
  });

  /// Reads the vanilla JSON. A title or page can be the plain value or an
  /// object with `raw` and `filtered`, the game writes both.
  factory WrittenBook.fromJson(Object? json) {
    final map = json is Map ? json : const {};
    final (title, filteredTitle) = _filterable(map['title']);
    return WrittenBook(
      title: title is String ? title : '',
      filteredTitle: filteredTitle is String ? filteredTitle : null,
      author: map['author'] is String ? map['author'] as String : '',
      generation: map['generation'] is int ? map['generation'] as int : null,
      pages: [
        for (final page in (map['pages'] as List?) ?? const [])
          switch (_filterable(page)) {
            (final raw, final filtered) => BookPage(
              raw: MiniMessageJson.decode(raw),
              filtered: filtered == null
                  ? null
                  : MiniMessageJson.decode(filtered),
            ),
          },
      ],
      resolved: map['resolved'] is bool ? map['resolved'] as bool : null,
    );
  }

  final String title;
  final String? filteredTitle;
  final String author;

  /// 0 for the original up to 3 for tattered, null leaves it out.
  final int? generation;
  final List<BookPage> pages;
  final bool? resolved;

  static (Object?, Object?) _filterable(Object? value) => switch (value) {
    {'raw': final raw} => (raw, (value as Map)['filtered']),
    _ => (value, null),
  };

  /// The vanilla JSON, with the optional parts only when they are set.
  Map<String, Object?> toJson() => {
    'title': {'raw': title, 'filtered': ?filteredTitle},
    'author': author,
    'generation': ?generation,
    if (pages.isNotEmpty)
      'pages': [
        for (final page in pages)
          {
            'raw': MiniMessageJson.encode(page.raw),
            if (page.filtered case final filtered?)
              'filtered': MiniMessageJson.encode(filtered),
          },
      ],
    'resolved': ?resolved,
  };

  WrittenBook copyWith({
    String? title,
    String? Function()? filteredTitle,
    String? author,
    int? Function()? generation,
    List<BookPage>? pages,
    bool? Function()? resolved,
  }) => WrittenBook(
    title: title ?? this.title,
    filteredTitle: filteredTitle == null ? this.filteredTitle : filteredTitle(),
    author: author ?? this.author,
    generation: generation == null ? this.generation : generation(),
    pages: pages ?? this.pages,
    resolved: resolved == null ? this.resolved : resolved(),
  );
}
