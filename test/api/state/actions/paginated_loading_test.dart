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
}
