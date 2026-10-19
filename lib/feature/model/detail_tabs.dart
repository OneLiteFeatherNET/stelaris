import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/l10n/app_localizations.dart';

/// The query parameter a detail route reads its starting tab from, e.g.
/// `/items/detail?tab=lore`.
const String detailTabParameter = 'tab';

/// The route parameter a project-scoped detail page names its model by, as
/// in `/projects/<projectId>/attributes/<id>`.
const String detailIdParameter = 'id';

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

/// Where the detail page of [entry] lives, optionally opened on [tab].
///
/// A project-scoped section names the model in its path, below [projectId]
/// (`/projects/p/attributes/a`), so the location can be shared and survives
/// a reload; without both there is no model to open and its list is
/// returned instead. The other sections show whatever is selected at
/// `<route>/detail`.
String detailLocation(
  NavigationEntry entry, {
  DetailTab? tab,
  String? projectId,
  String? id,
}) {
  final String path;
  if (!entry.projectScoped) {
    path = '${entry.route}/detail';
  } else if (projectId == null ||
      projectId.isEmpty ||
      id == null ||
      id.isEmpty) {
    return sectionLocation(entry, projectId);
  } else {
    path = '${sectionLocation(entry, projectId)}/$id';
  }
  return Uri(
    path: path,
    queryParameters: tab == null ? null : {detailTabParameter: tab.id},
  ).toString();
}

/// Whether [location] is a detail page of [entry], whichever model it shows.
bool isDetailLocation(NavigationEntry entry, String location) =>
    sectionPath(location).startsWith('${entry.route}/');
