import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/stelaris_icons.dart';

/// The enum class contains all relevant item for the navigation widget.
enum NavigationEntry {
  attributes(
    'Attributes',
    '/attributes',
    StelarisIcons.heartOutlined,
    StelarisIcons.heart,
    projectScoped: true,
  ),
  items(
    'Items',
    '/items',
    StelarisIcons.pickaxeOutlined,
    StelarisIcons.pickaxe,
  ),
  advancements(
    'Advancements',
    '/advancements',
    StelarisIcons.advancementOutlined,
    StelarisIcons.advancement,
  ),
  font('Fonts', '/fonts', StelarisIcons.lettersOutlined, StelarisIcons.letters),
  sound(
    'Sound',
    '/sound',
    StelarisIcons.noteBlockOutlined,
    StelarisIcons.noteBlock,
  );

  final String display;
  final String route;
  final IconData data;
  final IconData selected;

  /// Whether the section lives below its project, at
  /// `/projects/<projectId>[route]`, instead of at [route] itself.
  final bool projectScoped;

  /// Creates a new enum entry with the given value
  const NavigationEntry(
    this.display,
    this.route,
    this.data,
    this.selected, {
    this.projectScoped = false,
  });
}

/// The route the projects live under, and the project list itself.
const String projectsRoute = '/projects';

/// The route parameter a project-scoped location names its project by.
const String projectIdParameter = 'projectId';

/// Where the list of [entry] lives: below [projectId] for a project-scoped
/// section, the project list when that section has no project to go to.
String sectionLocation(NavigationEntry entry, String? projectId) {
  if (!entry.projectScoped) {
    return entry.route;
  }
  if (projectId == null || projectId.isEmpty) {
    return projectsRoute;
  }
  return '$projectsRoute/$projectId${entry.route}';
}

/// [location] without the `/projects/<projectId>` a project-scoped section
/// sits below, so every section is told apart by its route alone:
/// `/projects/p/attributes/a` becomes `/attributes/a`.
String sectionPath(String location) {
  final Match? match = RegExp('^${RegExp.escape(projectsRoute)}/[^/]+(/.+)\$')
      .firstMatch(location);
  return match?.group(1) ?? location;
}

/// The section [location] belongs to — its own route or one nested below
/// it (e.g. `/items/detail`) — or null outside the sections.
NavigationEntry? entryForLocation(String location) {
  final String path = sectionPath(location);
  for (final entry in NavigationEntry.values) {
    if (path == entry.route || path.startsWith('${entry.route}/')) {
      return entry;
    }
  }
  return null;
}
