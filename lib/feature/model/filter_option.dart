/// A single, user-facing toggle-able filter criterion for a [ModelPage]
/// list (e.g. "has default value"). Equality/hashing is by [id] only, so a
/// freshly-constructed option with the same [id] still compares equal to
/// one already held in an active-filters set.
class FilterOption {
  final String id;
  final String label;

  const FilterOption(this.id, this.label);

  @override
  bool operator ==(Object other) => other is FilterOption && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
