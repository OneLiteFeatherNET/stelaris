import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/command_palette/entity_search_source.dart';
import 'package:stelaris/feature/command_palette/entity_search_state.dart';

/// A new entity question: recorded at once, so the palette says
/// "Searching…" while [EntitySearchAction] waits out its debounce.
class EntitySearchStartedAction extends ReduxAction<AppState> {
  EntitySearchStartedAction(this.request);

  final EntitySearchRequest request;

  @override
  AppState? reduce() {
    if (state.entitySearch.request == request) return null;
    return state.copyWith(
      entitySearch: EntitySearchState(
        request: request,
        status: EntitySearchStatus.pending,
      ),
    );
  }
}

/// Asks [source] about [request] once typing has paused.
///
/// [Debounce] drops every dispatch a newer one supersedes within the pause.
/// That alone doesn't cover a newer question arriving while an older one is
/// already waiting on the source, so the reducer checks before and after the
/// wait that its request is still the current one, and otherwise changes
/// nothing.
class EntitySearchAction extends ReduxAction<AppState> with Debounce {
  EntitySearchAction(this.source, this.request);

  final EntitySearchSource source;
  final EntitySearchRequest request;

  @override
  int get debounce => 250;

  // One lock for every entity search, whatever its request.
  @override
  Object? lockBuilder() => EntitySearchAction;

  bool get _current => state.entitySearch.request == request;

  @override
  Future<AppState?> reduce() async {
    if (!_current) return null;
    List<EntityHit> hits;
    EntitySearchStatus status;
    try {
      hits = await source.search(request);
      status = EntitySearchStatus.done;
    } catch (_) {
      hits = const [];
      status = EntitySearchStatus.failed;
    }
    if (!_current) return null;
    return state.copyWith(
      entitySearch: EntitySearchState(
        request: request,
        hits: hits,
        status: status,
      ),
    );
  }
}

/// No question any more - out of entity mode, or nothing typed.
class ClearEntitySearchAction extends ReduxAction<AppState> {
  @override
  AppState? reduce() {
    if (state.entitySearch == const EntitySearchState()) return null;
    return state.copyWith(entitySearch: const EntitySearchState());
  }
}
