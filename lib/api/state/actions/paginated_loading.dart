import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/client_api.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Where a model list lives in the state and where its pages come from.
///
/// Each kind of model describes its list once, and its init, load-more and
/// refresh actions build on it.
class ModelList<T extends DataModel> {
  ModelList({required this.of, required this.withList, required this.api});

  /// Reads the list from the state.
  final PaginatedResult<T> Function(AppState state) of;

  /// Writes [list] into the state.
  final AppState Function(AppState state, PaginatedResult<T> list) withList;

  /// The API the pages come from, looked up when a page is requested.
  final ClientAPI<T> Function() api;

  /// Requests the first page of the open project.
  Future<PaginatedResult<T>> firstPage(AppState state) => api().getPage(
    page: 1,
    size: of(state).requestSize,
    projectId: state.selectedProject?.id,
  );
}

/// Loads the first page of [list] when none is loaded, and the next page
/// otherwise. The overview dispatches it when it opens.
abstract class InitListAction<T extends DataModel>
    extends ReduxAction<AppState> {
  InitListAction(this.list, this.loadMore);

  final ModelList<T> list;

  /// Builds the load-more action of the same list.
  final ReduxAction<AppState> Function() loadMore;

  @override
  Future<AppState?> reduce() async {
    if (list.of(state).items.isEmpty) {
      return list.withList(state, await list.firstPage(state));
    }
    await dispatchAndWait(loadMore());
    return null;
  }
}

/// Appends the next page of [list], if there is one.
///
/// While it loads, `isWaiting` is true for the concrete action type, and
/// another one of that type dispatched meanwhile is dropped.
abstract class LoadMoreListAction<T extends DataModel>
    extends ReduxAction<AppState>
    with NonReentrant {
  LoadMoreListAction(this.list);

  final ModelList<T> list;

  @override
  Future<AppState?> reduce() async {
    final current = list.of(state);
    if (!current.hasNextPage) return null;

    final next = await list.api().getPage(
      page: current.currentPage + 1,
      size: current.requestSize,
      projectId: state.selectedProject?.id,
    );

    // A project switch or refresh replaced the list while the page
    // loaded, so the page no longer continues it.
    if (!identical(list.of(state), current)) return null;

    return list.withList(state, current.append(next));
  }
}

/// Refetches the first page of [list] and replaces what was loaded,
/// however many pages that was. Used by the manual refresh of the overview.
abstract class RefreshListAction<T extends DataModel>
    extends ReduxAction<AppState> {
  RefreshListAction(this.list);

  final ModelList<T> list;

  @override
  Future<AppState?> reduce() async =>
      list.withList(state, await list.firstPage(state));
}

/// What the list actions share when loading a [PaginatedResult] page by page.
extension PaginatedLoading<T> on PaginatedResult<T> {
  /// The size to request further pages in: the size of the loaded pages, or
  /// 10 before any page was loaded.
  int get requestSize => pageSize == 0 ? 10 : pageSize;

  /// Appends [next], the page after [currentPage], to the loaded items. The
  /// counts of [next] win; where the backend left them out (0), the loaded
  /// ones or what was requested are kept.
  PaginatedResult<T> append(PaginatedResult<T> next) => copyWith(
    items: [...items, ...next.items],
    totalItems: next.totalItems != 0 ? next.totalItems : totalItems,
    totalPages: next.totalPages != 0 ? next.totalPages : totalPages,
    currentPage: next.currentPage != 0 ? next.currentPage : currentPage + 1,
    pageSize: next.pageSize != 0 ? next.pageSize : requestSize,
  );

  /// Appends [item], which was just created in the backend, and counts it.
  PaginatedResult<T> adding(T item) =>
      copyWith(items: [...items, item], totalItems: totalItems + 1);

  /// Replaces the items [test] matches with [item]. The counts stay.
  PaginatedResult<T> replacingWhere(bool Function(T item) test, T item) =>
      copyWith(
        items: [for (final T entry in items) test(entry) ? item : entry],
      );

  /// Removes the item [test] matches, which was just deleted in the backend,
  /// and counts one less, even when it wasn't loaded: the backend has one
  /// less either way.
  PaginatedResult<T> removingWhere(bool Function(T item) test) => copyWith(
    items: [
      for (final T entry in items)
        if (!test(entry)) entry,
    ],
    totalItems: totalItems - 1,
  );
}
