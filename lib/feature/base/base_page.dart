import 'package:async_redux/async_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/base/button/build_button.dart';
import 'package:stelaris/feature/base/button/settings_button.dart';
import 'package:stelaris/feature/base/button/toggle_navigation_button.dart';
import 'package:stelaris/feature/base/search/app_bar_search.dart';
import 'package:stelaris/feature/command_palette/command_palette.dart';
import 'package:stelaris/feature/navigation/navigation_side_bar.dart';
import 'package:stelaris/feature/project/badge/project_app_bar_badge.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/color_scheme_ext.dart';

/// A base page layout that provides a consistent structure across the application.
///
/// This widget implements the main layout structure including:
/// - An app bar with navigation toggle, title, and action buttons
/// - A side navigation bar
/// - A main content area
/// - An end drawer for build-related functionality
/// - The command palette's `Ctrl+K` / `Cmd+K` shortcut
class BasePage extends StatelessWidget {
  const BasePage({required this.child, super.key});

  final Widget child;

  static const double _contentCornerRadius = 16;

  @override
  Widget build(BuildContext context) {
    // Outside the StoreConnector: a project switch rebuilds the page, not the
    // shortcut around it.
    return CommandPaletteShortcuts(
      child: StoreConnector<AppState, String?>(
        converter: (store) => store.state.selectedProject?.id,
        builder: (context, selectedProjectId) {
          final colorScheme = Theme.of(context).colorScheme;
          return Scaffold(
            // The app chrome (AppBar + NavigationSideBar) sits one tone off the
            // content area, so the rounded content corner below reads as an
            // inset panel rather than just a bending line.
            backgroundColor: colorScheme.appChrome,
            appBar: AppBar(
              backgroundColor: colorScheme.appChrome,
              scrolledUnderElevation: 0,
              // Matches NavigationRail's default width, so the toggle button
              // sits on the same vertical axis as the rail's icons below it.
              leadingWidth: 80,
              leading: const ToggleNavigationBar(),
              elevation: 0,
              // Keyed by section: switching sections starts with a fresh field
              // and drops a query still waiting in the debounce.
              title: AppBarSearch(
                key: ValueKey(
                  entryForLocation(GoRouterState.of(context).matchedLocation),
                ),
              ),
              centerTitle: true,
              actions: const [
                ProjectAppBarBadge(),
                horizontalSpacing10,
                BuildButton(),
                SettingsButton(),
              ],
            ),
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const NavigationSideBar(),
                Expanded(
                  // The content panel's rounded top-left corner, set against
                  // the chrome's appChrome tone, is what separates it
                  // from the AppBar and NavigationSideBar — no border needed.
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(_contentCornerRadius),
                    ),
                    child: ColoredBox(
                      color: colorScheme.surface,
                      child: KeyedSubtree(
                        key: ValueKey(selectedProjectId),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
