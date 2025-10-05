import 'package:stelaris/api/model/data_model.dart';

/// Represents a paginated result from an API request.
///
/// This class encapsulates the data returned from a paginated API call,
/// including the items for the current page, metadata about pagination,
/// and utility methods for working with paginated data.
///
/// Type parameter [T] represents the specific [DataModel] implementation
/// contained in this paginated result.
class PaginatedResult<T> {
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

  bool get hasItems => items.isNotEmpty;

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
    T Function(Object? json) fromJsonT,
  ) {
    // Accept items under common keys: items, content, data
    final dynamic rawItems = json['items'] ?? json['content'] ?? json['data'];
    final List<T> itemsList = (rawItems is List)
        ? rawItems
              .whereType<Map<String, dynamic>>()
              .map((e) => fromJsonT(e))
              .toList()
        : <T>[];

    // Page size: pageSize | size | pageable.size | default to items length
    final int pageSize =
        _asInt(
          json['pageSize'] ??
              json['size'] ??
              (json['pageable'] is Map
                  ? (json['pageable'] as Map)['size']
                  : null),
        ) ??
        itemsList.length;

    // Total items: totalItems | totalSize | totalElements | default to items length
    final int totalItems =
        _asInt(
          json['totalItems'] ?? json['totalSize'] ?? json['totalElements'],
        ) ??
        itemsList.length;

    // Current page (1-based): currentPage | page | pageable.number (0-based)
    final int currentZero =
        _asInt(
          json['page'] ??
              json['currentPage'] ??
              (json['pageable'] is Map
                  ? (json['pageable'] as Map)['number']
                  : null),
        ) ??
        0;
    final int currentPage = (json['currentPage'] is int)
        ? (json['currentPage'] as int)
        : (currentZero + 1);

    // Total pages: provided or compute from totalItems and pageSize
    final int totalPages =
        _asInt(json['totalPages']) ??
        ((pageSize > 0) ? ((totalItems + pageSize - 1) ~/ pageSize) : 1);

    return PaginatedResult<T>(
      items: itemsList,
      totalItems: totalItems,
      totalPages: totalPages,
      currentPage: currentPage,
      pageSize: pageSize,
    );
  }

  /// Converts this paginated result to a JSON map.
  ///
  /// The [toJson] parameter is a function that converts an instance
  /// of type [T] to a JSON object.
  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return {
      // Persist under a stable key
      'items': items.map(toJsonT).toList(),
      'totalItems': totalItems,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'pageSize': pageSize,
    };
  }

  // Helper to safely parse ints from dynamic values
  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Returns a string representation of this paginated result.
  @override
  String toString() {
    return 'PaginatedResult(items: ${items.length}, totalItems: $totalItems, '
        'currentPage: $currentPage of $totalPages, pageSize: $pageSize)';
  }
}
