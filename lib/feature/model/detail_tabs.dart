import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// The query parameter a detail route reads its starting tab from, e.g.
/// `/items/detail?tab=lore`.
const String detailTabParameter = 'tab';

/// The tab a detail page should start on: the one named by the route's
/// [detailTabParameter], matched case-insensitively against [tabs], or the
/// first when the parameter is missing or names no tab.
int initialTabIndex(BuildContext context, List<String> tabs) {
  final String? requested = requestedTab(context);
  if (requested == null) {
    return 0;
  }
  final int index = tabs.indexWhere(
    (tab) => tab.toLowerCase() == requested.toLowerCase(),
  );
  return index < 0 ? 0 : index;
}

/// The raw [detailTabParameter] of the current route, if any.
String? requestedTab(BuildContext context) {
  return GoRouterState.of(context).uri.queryParameters[detailTabParameter];
}

/// Where the detail page under [listRoute] lives, optionally opened on [tab].
String detailLocation(String listRoute, [String? tab]) {
  final String path = '$listRoute/detail';
  if (tab == null) {
    return path;
  }
  return Uri(
    path: path,
    queryParameters: {detailTabParameter: tab.toLowerCase()},
  ).toString();
}
