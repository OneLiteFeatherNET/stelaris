import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/component/component_preview.dart';
import 'package:stelaris/feature/component/minimessage_editor.dart';
import 'package:stelaris/feature/item/components/book/written_book.dart';
import 'package:stelaris/util/component_context.dart';
import 'package:stelaris/util/functions.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Edits `minecraft:written_book_content`: title, author and generation on
/// top, then the pages one at a time, each with the MiniMessage editor and
/// a preview on paper. The parts for the chat filter sit under "Advanced".
class WrittenBookEditor extends StatefulWidget {
  const WrittenBookEditor({
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// The vanilla JSON of the component.
  final Object? value;
  final ValueChanged<Object?> onChanged;

  @override
  State<WrittenBookEditor> createState() => _WrittenBookEditorState();
}

class _WrittenBookEditorState extends State<WrittenBookEditor> {
  /// Below this width the preview goes under the editor.
  static const double _sideBySide = 640;

  /// Keeps the MiniMessage of the pages, a round trip through JSON on every
  /// keystroke would rewrite it under the caret.
  late WrittenBook _book;

  /// One per page, so each page keeps its own editor while pages are added
  /// or removed around it.
  late List<int> _ids;
  int _nextId = 0;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _book = WrittenBook.fromJson(widget.value);
    _ids = [for (final _ in _book.pages) _nextId++];
  }

  void _update(WrittenBook book) {
    setState(() => _book = book);
    widget.onChanged(book.toJson());
  }

  void _updatePage(BookPage Function(BookPage page) change) {
    final pages = [..._book.pages];
    pages[_page] = change(pages[_page]);
    _update(_book.copyWith(pages: pages));
  }

  void _addPage() {
    final at = _book.pages.isEmpty ? 0 : _page + 1;
    _ids.insert(at, _nextId++);
    _page = at;
    _update(
      _book.copyWith(pages: [..._book.pages]..insert(at, const BookPage())),
    );
  }

  void _removePage() {
    _ids.removeAt(_page);
    final pages = [..._book.pages]..removeAt(_page);
    _page = _page.clamp(0, pages.isEmpty ? 0 : pages.length - 1);
    _update(_book.copyWith(pages: pages));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                key: const Key('book_title'),
                initialValue: _book.title,
                maxLength: maxBookTitleLength,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: l10n.book_title,
                ),
                validator: (value) =>
                    checkIfEmptyAndReturnErrorString(value ?? '', context),
                onChanged: (value) => _update(_book.copyWith(title: value)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                key: const Key('book_author'),
                initialValue: _book.author,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: l10n.book_author,
                ),
                validator: (value) =>
                    checkIfEmptyAndReturnErrorString(value ?? '', context),
                onChanged: (value) => _update(_book.copyWith(author: value)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<int>(
          key: const Key('book_generation'),
          initialValue: _book.generation ?? 0,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: l10n.book_generation,
          ),
          items: [
            for (final (generation, label) in [
              (0, l10n.book_generation_original),
              (1, l10n.book_generation_copy),
              (2, l10n.book_generation_copy_of_copy),
              (3, l10n.book_generation_tattered),
            ])
              DropdownMenuItem(value: generation, child: Text(label)),
          ],
          onChanged: (value) =>
              _update(_book.copyWith(generation: () => value)),
        ),
        const SizedBox(height: 16),
        if (_book.pages.isEmpty)
          _NoPages(onAdd: _addPage)
        else ...[
          _PageBar(
            page: _page,
            count: _book.pages.length,
            onPage: (page) => setState(() => _page = page),
            onAdd: _book.pages.length < maxBookPages ? _addPage : null,
            onRemove: _removePage,
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final editor = MiniMessageEditor(
                key: ValueKey(('page', _ids[_page])),
                value: _book.pages[_page].raw,
                componentContext: ComponentContext.bookPage,
                multiline: true,
                onChanged: (text) =>
                    _updatePage((page) => page.copyWith(raw: text)),
              );
              final preview = _PagePreview(text: _book.pages[_page].raw);
              if (constraints.maxWidth < _sideBySide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [editor, const SizedBox(height: 12), preview],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: editor),
                  const SizedBox(width: 16),
                  SizedBox(width: 260, child: preview),
                ],
              );
            },
          ),
        ],
        const SizedBox(height: 8),
        _Advanced(
          book: _book,
          page: _book.pages.isEmpty ? null : _page,
          pageKey: _book.pages.isEmpty ? null : _ids[_page],
          onBook: _update,
          onPage: _updatePage,
        ),
      ],
    );
  }
}

class _NoPages extends StatelessWidget {
  const _NoPages({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Text(
          l10n.book_pages_empty,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          key: const Key('book_page_first'),
          onPressed: onAdd,
          icon: const Icon(Icons.note_add_outlined),
          label: Text(l10n.book_page_first),
        ),
      ],
    );
  }
}

/// Moves between the pages, adds one after the shown page and removes it.
class _PageBar extends StatelessWidget {
  const _PageBar({
    required this.page,
    required this.count,
    required this.onPage,
    required this.onAdd,
    required this.onRemove,
  });

  final int page;
  final int count;
  final ValueChanged<int> onPage;

  /// Null once the book has the most pages the game keeps.
  final VoidCallback? onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        IconButton(
          key: const Key('book_page_previous'),
          icon: const Icon(Icons.chevron_left),
          tooltip: l10n.book_page_previous,
          onPressed: page > 0 ? () => onPage(page - 1) : null,
        ),
        Text(
          l10n.book_page_of(page + 1, count),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        IconButton(
          key: const Key('book_page_next'),
          icon: const Icon(Icons.chevron_right),
          tooltip: l10n.book_page_next,
          onPressed: page < count - 1 ? () => onPage(page + 1) : null,
        ),
        const Spacer(),
        IconButton(
          key: const Key('book_page_add'),
          icon: const Icon(Icons.note_add_outlined),
          tooltip: l10n.book_page_add,
          onPressed: onAdd,
        ),
        IconButton(
          key: const Key('book_page_remove'),
          icon: const Icon(Icons.delete_outline),
          tooltip: l10n.book_page_remove,
          onPressed: onRemove,
        ),
      ],
    );
  }
}

class _PagePreview extends StatelessWidget {
  const _PagePreview({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.book_preview,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        ComponentPreview(
          key: const Key('book_page_preview'),
          text: text,
          componentContext: ComponentContext.bookPage,
        ),
      ],
    );
  }
}

/// The parts for the chat filter and whether the text is final. Rarely
/// needed, so folded away.
class _Advanced extends StatelessWidget {
  const _Advanced({
    required this.book,
    required this.page,
    required this.pageKey,
    required this.onBook,
    required this.onPage,
  });

  final WrittenBook book;

  /// The shown page, null without pages.
  final int? page;
  final int? pageKey;
  final ValueChanged<WrittenBook> onBook;
  final void Function(BookPage Function(BookPage page) change) onPage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muted = TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    final page = this.page;
    return ExpansionTile(
      key: const Key('book_advanced'),
      title: Text(l10n.book_advanced),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      shape: const Border(),
      children: [
        Text(l10n.book_filtered_hint, style: muted),
        const SizedBox(height: 12),
        TextFormField(
          key: const Key('book_filtered_title'),
          initialValue: book.filteredTitle ?? '',
          maxLength: maxBookTitleLength,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: l10n.book_filtered_title,
          ),
          onChanged: (value) => onBook(
            book.copyWith(filteredTitle: () => value.isEmpty ? null : value),
          ),
        ),
        if (page != null) ...[
          const SizedBox(height: 4),
          MiniMessageEditor(
            key: ValueKey(('filtered', pageKey)),
            label: l10n.book_filtered_page,
            value: book.pages[page].filtered ?? '',
            componentContext: ComponentContext.bookPage,
            multiline: true,
            onChanged: (text) => onPage(
              (page) =>
                  page.copyWith(filtered: () => text.isEmpty ? null : text),
            ),
          ),
        ],
        SwitchListTile(
          key: const Key('book_resolved'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.book_resolved),
          subtitle: Text(l10n.book_resolved_hint),
          value: book.resolved ?? false,
          onChanged: (value) => onBook(book.copyWith(resolved: () => value)),
        ),
      ],
    );
  }
}
