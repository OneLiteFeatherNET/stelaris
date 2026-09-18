/// The field a [ModelPage] list can be sorted by.
enum SortField {
  /// The model's display name, via the caller-supplied name selector.
  name,

  /// [DataModel.creationDate] — available on every model, no selector needed.
  createdAt,
}

/// The direction a [SortField] is applied in.
enum SortDirection { ascending, descending }
