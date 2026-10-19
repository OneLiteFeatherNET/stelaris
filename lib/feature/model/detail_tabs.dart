import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/l10n/app_localizations.dart';

/// The query parameter a detail route reads its starting tab from, e.g.
/// `/items/detail?tab=lore`.
const String detailTabParameter = 'tab';

/// The query parameter a shared detail link names its model's project by.
const String detailProjectParameter = 'project';

/// The query parameter a shared detail link names its model by.
const String detailIdParameter = 'id';

/// The model a shared detail link points to.
typedef SharedModelRef = ({String projectId, String id});

/// One tab of a detail page.
///
/// The [id] is what `?tab=` links and the command palette refer to, so it
/// stays stable; the visible [label] comes from the localizations and can
/// change freely.
class DetailTab {
  const DetailTab(this.id, this.label, {this.formerIds = const []});

  /// Lowercase, stable name of the tab, e.g. `lore`.
  final String id;

  /// The tab's visible name.
  final String Function(AppLocalizations l10n) label;

  /// Ids this tab was known by before, still accepted in `?tab=` so older
  /// links keep working (e.g. `meta` after it was merged into `general`).
  final List<String> formerIds;

  /// Whether [requested] names this tab, by its id or a former one.
  bool matches(String requested) {
    final String name = requested.toLowerCase();
    return name == id || formerIds.contains(name);
  }
}

/// The tab a detail page should start on: the one named by the route's
/// [detailTabParameter] (see [DetailTab.matches]), or the first when the
/// parameter is missing or names no tab.
int initialTabIndex(BuildContext context, List<DetailTab> tabs) {
  final String? requested = requestedTab(context);
  if (requested == null) {
    return 0;
  }
  final int index = tabs.indexWhere((tab) => tab.matches(requested));
  return index < 0 ? 0 : index;
}

/// The raw [detailTabParameter] of the current route, if any.
String? requestedTab(BuildContext context) {
  return GoRouterState.of(context).uri.queryParameters[detailTabParameter];
}

/// Where the detail page under [listRoute] lives, optionally opened on [tab].
///
/// With [projectId] and [id] the location names its model, so it can be
/// shared and survives a reload (see [sharedModelRef]).
String detailLocation(
  String listRoute, {
  DetailTab? tab,
  String? projectId,
  String? id,
}) {
  final Map<String, String> query = {
    detailProjectParameter: ?projectId,
    detailIdParameter: ?id,
    detailTabParameter: ?tab?.id,
  };
  return Uri(
    path: '$listRoute/detail',
    queryParameters: query.isEmpty ? null : query,
  ).toString();
}

/// The model a shared detail link at [uri] points to, or null when the link
/// does not name both its project and its id.
SharedModelRef? sharedModelRef(Uri uri) {
  final String? projectId = uri.queryParameters[detailProjectParameter];
  final String? id = uri.queryParameters[detailIdParameter];
  if (projectId == null || projectId.isEmpty || id == null || id.isEmpty) {
    return null;
  }
  return (projectId: projectId, id: id);
}
