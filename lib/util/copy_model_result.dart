/// The user's choices from a [CopyModelDialog]: where the copy should be
/// created, what it should be called, and whether related/embedded data
/// should be copied along with it.
class CopyModelResult {
  final String targetProjectId;
  final String name;
  final String key;
  final bool includeRelationships;

  const CopyModelResult({
    required this.targetProjectId,
    required this.name,
    required this.key,
    required this.includeRelationships,
  });
}
