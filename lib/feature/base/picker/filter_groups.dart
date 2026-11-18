/// The entries of [groups] matching [search], as the grouped pickers list
/// them.
///
/// [search] is trimmed and lowercased first and handed to [matches] in that
/// form. A group whose label contains it keeps all its entries, so typing
/// e.g. `stairs` lists every stair. [only] limits the result to one group.
/// Groups left without entries are dropped, the order of [groups] is kept.
Map<G, List<T>> filterGroups<G extends Object, T>(
  Map<G, List<T>> groups, {
  required String search,
  required String Function(G group) groupLabel,
  required bool Function(T entry, String search) matches,
  G? only,
}) {
  final text = search.trim().toLowerCase();
  return {
    for (final MapEntry(key: group, value: entries) in groups.entries)
      if (only == null || group == only)
        if (text.isEmpty || groupLabel(group).toLowerCase().contains(text))
          group: entries
        else if (entries.where((entry) => matches(entry, text)).toList()
            case final matching when matching.isNotEmpty)
          group: matching,
  };
}
