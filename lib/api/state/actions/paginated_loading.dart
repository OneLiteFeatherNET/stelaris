import 'package:stelaris_models/stelaris_models.dart';

/// What the list actions share when loading a [PaginatedResult] page by page.
extension PaginatedLoading<T> on PaginatedResult<T> {
  /// The size to request further pages in: the size of the loaded pages, or
  /// 10 before any page was loaded.
  int get requestSize => pageSize == 0 ? 10 : pageSize;
}
