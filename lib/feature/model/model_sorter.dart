import 'package:stelaris_models/stelaris_models.dart';

import 'model_page.dart' show ModelNameSelector;
import 'model_sort_option.dart';

/// Sorts [models] by [sortField]/[sortDirection], using [nameSelector] for
/// [SortField.name]. Sorts in place and also returns the (same) list, so
/// callers can use it either way.
List<E> sortModels<E extends DataModel>({
  required List<E> models,
  required SortField sortField,
  required SortDirection sortDirection,
  required ModelNameSelector<E> nameSelector,
}) {
  final directionMultiplier = sortDirection == SortDirection.descending
      ? -1
      : 1;

  switch (sortField) {
    case SortField.name:
      // Decorate-sort-undecorate: compute each model's lowercase sort key
      // once instead of re-lowercasing both sides on every comparison the
      // sort makes.
      final decorated = [
        for (final model in models)
          (key: nameSelector(model).toLowerCase(), model: model),
      ];
      decorated.sort((a, b) => a.key.compareTo(b.key) * directionMultiplier);
      return [for (final entry in decorated) entry.model];
    case SortField.createdAt:
      models.sort((a, b) {
        final aDate = a.creationDate;
        final bDate = b.creationDate;
        // Undated models always sort last, regardless of direction —
        // negating the comparison for "descending" must not also flip
        // which end of the list they land on.
        return switch ((aDate, bDate)) {
          (null, null) => 0,
          (null, _) => 1,
          (_, null) => -1,
          (final aDate?, final bDate?) =>
            aDate.compareTo(bDate) * directionMultiplier,
        };
      });
      return models;
  }
}
