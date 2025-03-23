import 'package:stelaris/api/model/data_model.dart';

/// Represents a paginated result from an API request.
///
/// This class encapsulates the data returned from a paginated API call,
/// including the items for the current page, metadata about pagination,
/// and utility methods for working with paginated data.
///
/// Type parameter [T] represents the specific [DataModel] implementation
/// contained in this paginated result.
class PaginatedResult<T extends DataModel> {
  /// The list of items for the current page.
  final List<T> items;

  /// The total number of items across all pages.
  final int totalItems;

  /// The total number of pages available.
  final int totalPages;

  /// The current page number (1-based indexing).
  final int currentPage;

  /// The number of items per page requested.
  final int pageSize;

  /// Creates a new paginated result.
  ///
  /// All parameters are required:
  /// - [items]: The list of items for the current page
  /// - [totalItems]: The total number of items across all pages
  /// - [totalPages]: The total number of pages available
  /// - [currentPage]: The current page number (1-based)
  /// - [pageSize]: The number of items per page
  const PaginatedResult({
    required this.items,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
  });

  /// Whether there are more pages available after the current page.
  bool get hasNextPage => currentPage < totalPages;

  /// Whether there are pages available before the current page.
  bool get hasPreviousPage => currentPage > 1;

  /// The starting index of the first item on the current page.
  int get startIndex => (currentPage - 1) * pageSize + 1;

  /// The ending index of the last item on the current page.
  int get endIndex => startIndex + items.length - 1;

  /// Creates a copy of this result with the given fields replaced with new values.
  PaginatedResult<T> copyWith({
    List<T>? items,
    int? totalItems,
    int? totalPages,
    int? currentPage,
    int? pageSize,
  }) {
    return PaginatedResult<T>(
      items: items ?? this.items,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  /// Creates an empty paginated result.
  ///
  /// Useful for initializing state before data is loaded.
  factory PaginatedResult.empty() {
    return PaginatedResult<T>(
      items: [],
      totalItems: 0,
      totalPages: 0,
      currentPage: 1,
      pageSize: 0,
    );
  }

  /// Creates a paginated result from a JSON map.
  ///
  /// The [fromJson] parameter is a function that converts a JSON object
  /// to an instance of type [T].
  ///
  /// The expected JSON structure is:
  /// ```json
  /// {
  ///   "items": [...],
  ///   "totalItems": 100,
  ///   "totalPages": 5,
  ///   "currentPage": 1,
  ///   "pageSize": 20
  /// }
  /// ```
  factory PaginatedResult.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJson,
      ) {
    final itemsList = (json['items'] as List?)
        ?.map((item) => fromJson(item as Map<String, dynamic>))
        .toList() ?? [];

    return PaginatedResult<T>(
      items: itemsList,
      totalItems: json['totalItems'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? itemsList.length,
    );
  }

  /// Converts this paginated result to a JSON map.
  ///
  /// The [toJson] parameter is a function that converts an instance
  /// of type [T] to a JSON object.
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJson) {
    return {
      'items': items.map(toJson).toList(),
      'totalItems': totalItems,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'pageSize': pageSize,
    };
  }

  /// Returns a string representation of this paginated result.
  @override
  String toString() {
    return 'PaginatedResult(items: ${items.length}, totalItems: $totalItems, '
        'currentPage: $currentPage of $totalPages, pageSize: $pageSize)';
  }
}