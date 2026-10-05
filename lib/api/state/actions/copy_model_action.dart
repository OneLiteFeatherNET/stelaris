import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/util/copy_model_result.dart';

/// What the per-model copy actions share: which project the source is
/// addressed through, and whether the copy belongs in the open lists.
mixin CopyModelAction on ReduxAction<AppState> {
  CopyModelResult get result;

  /// [projectId] of the source, or the open project's when it has none. An
  /// empty id counts as none, as in `BaseApi`, which would otherwise send
  /// the request to a route without the `project/…` prefix.
  String? sourceProjectId(String? projectId) =>
      projectId != null && projectId.isNotEmpty
      ? projectId
      : state.selectedProject?.id;

  /// Whether the copy landed in the open project. Judged by the requested
  /// target, since the response may lack a `projectId`.
  bool get copiesIntoOpenProject =>
      result.targetProjectId == state.selectedProject?.id;
}
