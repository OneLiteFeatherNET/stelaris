import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/command_palette/entity_search_source.dart';

/// Where the palette's entity search stands in the store: the question last
/// asked, what the source found for it, and whether it has answered.
///
/// A plain immutable class rather than a generated one: it is transient,
/// never persisted, and only ever replaced whole.
@immutable
class EntitySearchState {
  const EntitySearchState({
    this.request,
    this.hits = const [],
    this.status = EntitySearchStatus.none,
  });

  /// The current question, or null when there is none.
  final EntitySearchRequest? request;

  /// The source's hits for [request].
  final List<EntityHit> hits;

  final EntitySearchStatus status;

  @override
  bool operator ==(Object other) =>
      other is EntitySearchState &&
      other.request == request &&
      identical(other.hits, hits) &&
      other.status == status;

  @override
  int get hashCode => Object.hash(request, hits, status);
}
