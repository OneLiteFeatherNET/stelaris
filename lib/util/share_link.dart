/// The absolute link to the app route [location], built from the page's
/// [current] address so it carries the deployment's host and base.
///
/// The app routes in the fragment (`.../#/attributes`), the web default, so
/// only the fragment is swapped. Without one the route is the path itself.
Uri shareLink(Uri current, String location) {
  if (current.fragment.startsWith('/')) {
    return current.replace(fragment: location);
  }
  // Uri.replace keeps a part passed as null, so the current page's own
  // query could leak in; a fresh Uri takes only what the route names.
  final Uri route = Uri.parse(location);
  return Uri(
    scheme: current.scheme,
    userInfo: current.userInfo,
    host: current.host,
    port: current.hasPort ? current.port : null,
    path: route.path,
    query: route.hasQuery ? route.query : null,
  );
}
