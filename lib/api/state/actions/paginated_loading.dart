import 'package:stelaris_models/stelaris_models.dart';

/// What the list actions share when loading a [PaginatedResult] page by page.
extension PaginatedLoading<T> on PaginatedResult<T> {
  /// The size to request further pages in: the size of the loaded pages, or
  /// 10 before any page was loaded.
  int get requestSize => pageSize == 0 ? 10 : pageSize;

  /// Appends [next], the page after [currentPage], to the loaded items. The
  /// counts of [next] win; where the backend left them out (0), the loaded
  /// ones or what was requested are kept.
  PaginatedResult<T> append(PaginatedResult<T> next) => copyWith(
    items: [...items, ...next.items],
    totalItems: next.totalItems != 0 ? next.totalItems : totalItems,
    totalPages: next.totalPages != 0 ? next.totalPages : totalPages,
    currentPage: next.currentPage != 0 ? next.currentPage : currentPage + 1,
    pageSize: next.pageSize != 0 ? next.pageSize : requestSize,
  );
}
