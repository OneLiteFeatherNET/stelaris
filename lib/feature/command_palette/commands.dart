import 'package:async_redux/async_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/attribute_actions.dart';
import 'package:stelaris/api/state/actions/build/build_actions.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/actions/notification_actions.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/state/actions/theme_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/build/build_dialog.dart';
import 'package:stelaris/feature/command_palette/backend_command.dart';
import 'package:stelaris/feature/command_palette/command.dart';
import 'package:stelaris/feature/command_palette/delete_specs.dart';
import 'package:stelaris/feature/command_palette/palette_mode.dart';
import 'package:stelaris/feature/model/detail_tabs.dart';
import 'package:stelaris/feature/model/model_create.dart';
import 'package:stelaris/feature/settings/settings_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/routes.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The commands the palette offers.
///
/// Each one calls the same action or opens the same dialog as the control it
/// mirrors, so the palette and the buttons cannot drift apart.
List<StelarisCommand> pocCommands() => [
  for (final NavigationEntry entry in NavigationEntry.values) _goTo(entry),
  _goToProjects,
  for (final NavigationEntry entry in NavigationEntry.values) _create(entry),
  _toggleDarkMode,
  _toggleSystemTheme,
  _openSettings,
  _openBuild,
  _reloadList,
  _reloadBranches,
  _reloadRelease,
  _deleteThis(itemDelete, (l10n) => l10n.command_delete_this_item),
  _deleteThis(fontDelete, (l10n) => l10n.command_delete_this_font),
  _deleteThis(soundDelete, (l10n) => l10n.command_delete_this_sound),
  _deleteThis(
    notificationDelete,
    (l10n) => l10n.command_delete_this_notification,
  ),
];

List<String> _split(String keywords) => keywords.split(' ');

/// Commands that change or open settings: listed in the commands and in the
/// settings mode.
const Set<PaletteMode> _settings = {PaletteMode.commands, PaletteMode.settings};

/// The "Go to" commands: listed in the commands and in the navigation mode.
const Set<PaletteMode> _navigation = {
  PaletteMode.commands,
  PaletteMode.navigation,
};

/// The list page [location] shows, or null on a detail page or anywhere else.
NavigationEntry? listPageAt(String location) {
  for (final NavigationEntry entry in NavigationEntry.values) {
    if (location == entry.route) {
      return entry;
    }
  }
  return null;
}

StelarisCommand _goTo(NavigationEntry entry) {
  return StelarisCommand(
    id: 'nav.${entry.name}',
    modes: _navigation,
    title: (l10n) => l10n.command_go_to(entry.display),
    keywords: (l10n) => _split(l10n.command_go_to_keywords),
    group: CommandGroup.navigation,
    icon: entry.data,
    // Marked, not hidden: the palette shows where the user is, and from a
    // detail page (which sits under the list's route) this leads back.
    isCurrent: (context) =>
        context.location == entry.route ||
        context.location.startsWith('${entry.route}/'),
    currentIcon: entry.selected,
    run: (context) async => context.go(entry.route),
  );
}

/// "New item" and so on: the list's own create dialog, from anywhere. After
/// a create the list it went into is shown, so the new model is in view.
StelarisCommand _create(NavigationEntry entry) {
  return StelarisCommand(
    id: 'create.${entry.name}',
    title: (l10n) => switch (entry) {
      NavigationEntry.items => l10n.command_create_item,
      NavigationEntry.font => l10n.command_create_font,
      NavigationEntry.sound => l10n.command_create_sound,
      NavigationEntry.notifications => l10n.command_create_notification,
      NavigationEntry.attributes => l10n.command_create_attribute,
    },
    keywords: (l10n) => _split(l10n.command_create_keywords),
    group: CommandGroup.create,
    icon: Icons.add,
    run: (context) async {
      final String projectKey =
          StoreProvider.backdoorInheritedWidget<AppState>(context)
              .state
              .selectedProject
              ?.key ??
          '';
      final bool created = await openModelCreateDialog(
        context,
        entry,
        projectKey,
      );
      if (!created || !context.mounted) {
        return;
      }
      if (GoRouter.of(context).state.matchedLocation != entry.route) {
        context.go(entry.route);
      }
    },
  );
}

/// "Delete this item…" on an item's detail page: the page's own delete, with
/// the same confirmation and the way back to the list.
StelarisCommand _deleteThis<E extends DataModel>(
  DeleteSpec<E> spec,
  String Function(AppLocalizations l10n) title,
) {
  return StelarisCommand(
    id: 'delete.${spec.entry.name}.current',
    title: title,
    keywords: (l10n) => _split(l10n.command_delete_keywords),
    group: CommandGroup.interface,
    icon: Icons.delete_outline,
    isAvailable: (context) =>
        context.location == detailLocation(spec.entry.route) &&
        spec.selected(context.state) != null,
    run: (context) async {
      final E? model = spec.selected(
        StoreProvider.backdoorInheritedWidget<AppState>(context).state,
      );
      if (model == null) {
        return;
      }
      await spec.delete(context, model);
    },
  );
}

final StelarisCommand _goToProjects = StelarisCommand(
  id: 'nav.projects',
  modes: _navigation,
  title: (l10n) => l10n.command_go_to_projects,
  keywords: (l10n) => _split(l10n.command_go_to_projects_keywords),
  group: CommandGroup.navigation,
  icon: Icons.folder_open,
  run: (context) async => context.go(projectSelectionRoute),
);

final StelarisCommand _toggleDarkMode = StelarisCommand(
  id: 'ui.toggle-dark-mode',
  modes: _settings,
  title: (l10n) => l10n.command_toggle_dark_mode,
  keywords: (l10n) => _split(l10n.command_toggle_dark_mode_keywords),
  group: CommandGroup.interface,
  icon: Icons.dark_mode_outlined,
  run: (context) async => context.dispatch(ToggleDarkModeAction()),
);

final StelarisCommand _toggleSystemTheme = StelarisCommand(
  id: 'ui.toggle-system-theme',
  modes: _settings,
  title: (l10n) => l10n.command_toggle_system_theme,
  keywords: (l10n) => _split(l10n.command_toggle_system_theme_keywords),
  group: CommandGroup.interface,
  icon: Icons.brightness_auto_outlined,
  run: (context) async => context.dispatch(
    // Same seed as the settings switch, so turning "follow system" off keeps
    // the brightness that is showing right now.
    ToggleSystemThemeAction(
      MediaQuery.platformBrightnessOf(context) == Brightness.dark,
    ),
  ),
);

final StelarisCommand _openSettings = StelarisCommand(
  id: 'ui.open-settings',
  modes: _settings,
  title: (l10n) => l10n.command_open_settings,
  keywords: (l10n) => _split(l10n.command_open_settings_keywords),
  group: CommandGroup.interface,
  icon: Icons.settings_outlined,
  run: (context) => showDialog<void>(
    context: context,
    builder: (_) => const SettingsDialog(),
  ),
);

final StelarisCommand _openBuild = StelarisCommand(
  id: 'ui.open-build',
  title: (l10n) => l10n.command_open_build,
  keywords: (l10n) => _split(l10n.command_open_build_keywords),
  group: CommandGroup.interface,
  icon: Icons.build_outlined,
  run: (context) =>
      showDialog<void>(context: context, builder: (_) => const BuildDialog()),
);

/// The action each list page's refresh button dispatches.
ReduxAction<AppState> refreshActionFor(NavigationEntry entry) {
  return switch (entry) {
    NavigationEntry.attributes => RefreshAttributeAction(),
    NavigationEntry.items => RefreshItemAction(),
    NavigationEntry.notifications => RefreshNotificationAction(),
    NavigationEntry.font => RefreshFontAction(),
    NavigationEntry.sound => RefreshSoundAction(),
  };
}

final StelarisCommand _reloadList = StelarisCommand(
  id: 'backend.reload-list',
  title: (l10n) => l10n.command_reload_list,
  keywords: (l10n) => _split(l10n.command_reload_list_keywords),
  group: CommandGroup.backend,
  icon: Icons.refresh,
  isAvailable: (context) => listPageAt(context.location) != null,
  run: (context) {
    final AppLocalizations l10n = context.l10n;
    final String location = GoRouter.of(context).state.matchedLocation;
    final NavigationEntry? entry = listPageAt(location);
    if (entry == null) {
      return Future<void>.value();
    }
    return runBackendCommand(
      context,
      refreshActionFor(entry),
      success: l10n.command_reload_list_success,
      failure: l10n.command_reload_list_failure,
    );
  },
);

/// `BranchFetchAction` swallows its errors and leaves `branches` null instead.
BackendOutcome branchReloadOutcome(AppState before, AppState after) =>
    after.branches == null ? BackendOutcome.failure : BackendOutcome.success;

final StelarisCommand _reloadBranches = StelarisCommand(
  id: 'backend.reload-branches',
  title: (l10n) => l10n.command_reload_branches,
  keywords: (l10n) => _split(l10n.command_reload_branches_keywords),
  group: CommandGroup.backend,
  icon: Icons.account_tree_outlined,
  run: (context) {
    final AppLocalizations l10n = context.l10n;
    return runBackendCommand(
      context,
      BranchFetchAction(),
      success: l10n.command_reload_branches_success,
      failure: l10n.command_reload_branches_failure,
      outcome: branchReloadOutcome,
    );
  },
);

/// `ReleaseFetchAction` swallows its errors and leaves the state untouched,
/// which a successful fetch of unchanged data also does. The two cannot be
/// told apart, so an unchanged model reads as neutral rather than as a success.
BackendOutcome releaseReloadOutcome(AppState before, AppState after) =>
    before.releaseModel == after.releaseModel
    ? BackendOutcome.neutral
    : BackendOutcome.success;

final StelarisCommand _reloadRelease = StelarisCommand(
  id: 'backend.reload-release',
  title: (l10n) => l10n.command_reload_release,
  keywords: (l10n) => _split(l10n.command_reload_release_keywords),
  group: CommandGroup.backend,
  icon: Icons.new_releases_outlined,
  run: (context) {
    final AppLocalizations l10n = context.l10n;
    return runBackendCommand(
      context,
      ReleaseFetchAction(),
      success: l10n.command_reload_release_success,
      // Never shown: the action cannot fail visibly, see releaseReloadOutcome.
      failure: l10n.command_reload_release_unchanged,
      neutral: l10n.command_reload_release_unchanged,
      outcome: releaseReloadOutcome,
    );
  },
);
