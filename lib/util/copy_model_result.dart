import 'package:stelaris_models/stelaris_models.dart';

/// What a copy dialog asks for: the project to copy into, the copy's name
/// and key, and the relations (by backend id, e.g. `LORE`) to copy along.
class CopyModelResult {
  const CopyModelResult({
    required this.targetProject,
    required this.name,
    required this.key,
    this.relations = const {},
  });

  /// Always a stored project, so it has an id.
  final Project targetProject;
  final String name;
  final String key;
  final Set<String> relations;

  String get targetProjectId => targetProject.id!;
}
