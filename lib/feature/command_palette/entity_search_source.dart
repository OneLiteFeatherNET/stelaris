import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/command_palette/palette_mode.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The most entities the palette lists at once, loaded and searched together.
const int maxEntityResults = 15;

/// Something that can find entities the app has not loaded - a search
/// service. The palette asks it in entity mode and lists its hits next to
/// the loaded matches; how it finds them is up to the implementation.
///
/// ```dart
/// class BackendEntitySearch implements EntitySearchSource {
///   @override
///   Future<List<EntityHit>> search(EntitySearchRequest request) async {
///     // e.g. GET /search?q=…&kind=…&projectId=…&limit=…
///   }
/// }
///
/// CommandPaletteShortcuts(entitySearch: BackendEntitySearch(), child: …)
/// ```
abstract interface class EntitySearchSource {
  /// Up to [EntitySearchRequest.limit] entities matching the request. May
  /// throw; the palette then keeps showing the loaded matches and says the
  /// search is unavailable.
  Future<List<EntityHit>> search(EntitySearchRequest request);
}

/// What the palette asks a [EntitySearchSource] for.
@immutable
class EntitySearchRequest {
  const EntitySearchRequest({
    required this.query,
    required this.limit,
    this.kind,
    this.projectId,
  });

  /// The text typed after the mode and kind, e.g. `blade` for `#item blade`.
  final String query;

  /// Only entities of this kind, or every kind when null.
  final EntityKind? kind;

  /// The selected project's id.
  final String? projectId;

  final int limit;

  @override
  bool operator ==(Object other) =>
      other is EntitySearchRequest &&
      other.query == query &&
      other.kind == kind &&
      other.projectId == projectId &&
      other.limit == limit;

  @override
  int get hashCode => Object.hash(query, kind, projectId, limit);
}

/// One entity a source found: its kind and the model itself, so choosing it
/// can select and open it like a loaded one. The model's type has to fit the
/// kind - an [ItemModel] for [EntityKind.item] and so on - or the hit is
/// dropped.
@immutable
class EntityHit {
  const EntityHit(this.kind, this.model);

  final EntityKind kind;
  final DataModel model;
}

/// Where a source's answer for the current query stands.
enum EntitySearchStatus {
  /// No source configured: only loaded entities are searched.
  none,

  /// Asked, not answered yet.
  pending,

  /// Answered; its hits are in the list.
  done,

  /// The source threw; only loaded entities are listed.
  failed,
}
