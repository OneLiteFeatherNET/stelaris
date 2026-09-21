import 'package:stelaris_models/stelaris_models.dart';

import 'filter_option.dart';
import 'model_page.dart' show ModelFilterMatcher, ModelSearchMatcher;

/// Filters [models] by [query] and [activeFilters], using [matchesSearch]/
/// [matchesFilter] to decide per-model matches. [query] must already be
/// normalized (e.g. lowercased) by the caller, since this only checks it
/// for emptiness.
List<E> filterModels<E extends DataModel>({
  required List<E> models,
  required String query,
  required Set<FilterOption> activeFilters,
  required ModelSearchMatcher<E> matchesSearch,
  required ModelFilterMatcher<E> matchesFilter,
}) {
  if (query.isEmpty && activeFilters.isEmpty) return models.toList();

  return models.where((model) {
    final matchesQuery = query.isEmpty || matchesSearch(model, query);
    final matchesFilters =
        activeFilters.isEmpty ||
        activeFilters.every((filter) => matchesFilter(model, filter));
    return matchesQuery && matchesFilters;
  }).toList();
}
