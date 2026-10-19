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
}
