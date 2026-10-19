import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/state/actions/paginated_loading.dart';
import 'package:stelaris_models/stelaris_models.dart';

PaginatedResult<String> page(
  List<String> items, {
  int totalItems = 0,
  int totalPages = 0,
  int currentPage = 0,
  int pageSize = 0,
}) => PaginatedResult<String>(
  items: items,
  totalItems: totalItems,
  totalPages: totalPages,
  currentPage: currentPage,
  pageSize: pageSize,
);

void main() {
  group('requestSize', () {
    test('is the size of the loaded pages', () {
      expect(page(const [], pageSize: 25).requestSize, 25);
    });

    test('falls back to 10 before any page was loaded', () {
      expect(page(const []).requestSize, 10);
    });
  });

  group('append', () {
    test('appends the items and takes the counts of the next page', () {
      final loaded = page(
        const ['a', 'b'],
        totalItems: 5,
        totalPages: 3,
        currentPage: 1,
        pageSize: 2,
      );
      final next = page(
        const ['c', 'd'],
        totalItems: 6,
        totalPages: 3,
        currentPage: 2,
        pageSize: 2,
      );

      final merged = loaded.append(next);

      expect(merged.items, ['a', 'b', 'c', 'd']);
      expect(merged.totalItems, 6);
      expect(merged.totalPages, 3);
      expect(merged.currentPage, 2);
      expect(merged.pageSize, 2);
    });

    test('keeps the loaded counts and the requested page where the next '
        'page left them out', () {
      final loaded = page(
        const ['a', 'b'],
        totalItems: 6,
        totalPages: 3,
        currentPage: 1,
        pageSize: 2,
      );

      final merged = loaded.append(page(const ['c', 'd']));

      expect(merged.items, ['a', 'b', 'c', 'd']);
      expect(merged.totalItems, 6);
      expect(merged.totalPages, 3);
      expect(merged.currentPage, 2);
      expect(merged.pageSize, 2);
    });
  });

  final loaded = page(
    const ['a', 'b', 'c'],
    totalItems: 7,
    totalPages: 3,
    currentPage: 1,
    pageSize: 3,
  );

  /// Expects [result] to keep the paging of [loaded].
  void expectSamePaging(PaginatedResult<String> result) {
    expect(result.totalPages, 3);
    expect(result.currentPage, 1);
    expect(result.pageSize, 3);
  }

  group('adding', () {
    test('appends the item and counts it', () {
      final result = loaded.adding('d');

      expect(result.items, ['a', 'b', 'c', 'd']);
      expect(result.totalItems, 8);
      expectSamePaging(result);
    });
  });

  group('replacingWhere', () {
    test('replaces the matching item and keeps the counts', () {
      final result = loaded.replacingWhere((e) => e == 'b', 'B');

      expect(result.items, ['a', 'B', 'c']);
      expect(result.totalItems, 7);
      expectSamePaging(result);
    });

    test('leaves the items alone when none matches', () {
      final result = loaded.replacingWhere((e) => e == 'x', 'X');

      expect(result.items, ['a', 'b', 'c']);
    });
  });

  group('removingWhere', () {
    test('removes the matching item and counts one less', () {
      final result = loaded.removingWhere((e) => e == 'b');

      expect(result.items, ['a', 'c']);
      expect(result.totalItems, 6);
      expectSamePaging(result);
    });

    test('counts one less even when the item was not loaded', () {
      final result = loaded.removingWhere((e) => e == 'x');

      expect(result.items, ['a', 'b', 'c']);
      expect(result.totalItems, 6);
    });
  });
}
