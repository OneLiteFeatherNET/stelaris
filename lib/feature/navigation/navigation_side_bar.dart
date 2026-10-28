import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/navigation_vm_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/util/color_scheme_ext.dart';
import 'package:stelaris/util/l10n_ext.dart';

const double maxXOffset = 208;

/// The sections of the rail, in order: every entry that is not runtime data.
final List<NavigationEntry> sectionEntries = [
  for (final entry in NavigationEntry.values)
    if (!entry.isRuntime) entry,
];

/// The runtime entries, listed below the "Runtime" heading in this order.
final List<NavigationEntry> runtimeNavigationEntries = [
  for (final entry in NavigationEntry.values)
    if (entry.isRuntime) entry,
];
const TextStyle navigationEntryTextStyle = TextStyle(fontSize: 16);

/// A widget that represents a navigation sidebar for the application.
///
/// The [NavigationSideBar] allows users to navigate between different
/// sections of the application using a [NavigationRail].
class NavigationSideBar extends StatelessWidget {
  const NavigationSideBar({super.key});

  @override
  Widget build(BuildContext context) {
    final routerUri = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _indexForLocation(routerUri);

    return StoreConnector<AppState, NavigationViewModel>(
      vm: () => NavigationStateFactory(),
      builder: (context, vm) {
        return FocusTraversalGroup(
          child: NavigationRail(
            // Same tone as the AppBar — see BasePage.
            backgroundColor: Theme.of(context).colorScheme.appChrome,
            minExtendedWidth: maxXOffset,
            extended: MediaQuery.of(context).size.width >= 1000
                ? vm.openNavigation
                : false,
            onDestinationSelected: (index) =>
                _onDestinationSelected(context, index),
            labelType: NavigationRailLabelType.none,
            destinations: _buildNavigationView(context),
            selectedIndex: selectedIndex != -1 ? selectedIndex : 0,
          ),
        );
      },
    );
  }

  /// The rail index of the runtime entry at [runtimeIndex] in
  /// [runtimeNavigationEntries]. One slot after the sections is the
  /// "Runtime" heading.
  static int _runtimeRailIndex(int runtimeIndex) =>
      sectionEntries.length + 1 + runtimeIndex;

  /// The rail index of the destination showing [location], or -1 if none does.
  /// Nested routes (e.g. a model's `/detail` route) share the parent entry's
  /// highlight rather than falling back to the first entry.
  int _indexForLocation(String location) {
    final currentEntry = entryForLocation(location);
    if (currentEntry == null) return -1;
    if (currentEntry.isRuntime) {
      return _runtimeRailIndex(runtimeNavigationEntries.indexOf(currentEntry));
    }
    return sectionEntries.indexOf(currentEntry);
  }

  /// Handles the selection of a navigation destination. Leaving a detail
  /// page with unsaved edits is guarded by the detail route's `onExit`.
  void _onDestinationSelected(BuildContext context, int index) {
    if (index < sectionEntries.length) {
      context.go(sectionEntries[index].route);
      return;
    }
    // The heading itself is disabled and never reaches here.
    final runtimeIndex = index - _runtimeRailIndex(0);
    if (runtimeIndex >= 0 && runtimeIndex < runtimeNavigationEntries.length) {
      context.go(runtimeNavigationEntries[runtimeIndex].route);
    }
  }

  /// Builds the list of navigation destinations for the [NavigationRail]: the
  /// sections, the disabled "Runtime" heading, then the runtime entries.
  List<NavigationRailDestination> _buildNavigationView(BuildContext context) {
    return [
      for (final navigationValue in sectionEntries)
        _destination(
          display: navigationValue.display,
          icon: navigationValue.data,
          selectedIcon: navigationValue.selected,
        ),
      _groupHeading(context, context.l10n.navigation_group_runtime),
      for (final runtimeValue in runtimeNavigationEntries)
        _destination(
          display: runtimeValue.display,
          icon: runtimeValue.data,
          selectedIcon: runtimeValue.selected,
        ),
    ];
  }

  /// A destination for one page.
  NavigationRailDestination _destination({
    required String display,
    required IconData icon,
    required IconData selectedIcon,
  }) {
    return NavigationRailDestination(
      selectedIcon: Icon(selectedIcon),
      icon: Icon(icon),
      // The rail's icon column is 80 wide and adds 8 after the label, so the
      // label box makes every row exactly maxXOffset wide when extended.
      // A wider label would widen only its own row and shift the icons of
      // the other rows (NavigationRail centers the rows).
      // Labels are invisible while the rail expands from collapsed and fade
      // out in the first half of collapsing, so the mid-word clipping of the
      // rail's width animation is never shown.
      label: Builder(
        builder: (context) => FadeTransition(
          opacity: NavigationRail.extendedAnimation(context)
              .drive(CurveTween(curve: const Interval(0.5, 1))),
          child: SizedBox(
            width: maxXOffset - 88,
            child: Text(
              display,
              style: navigationEntryTextStyle,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
          ),
        ),
      ),
    );
  }

  /// A disabled heading between the sections and the runtime entries. Its
  /// icon is a short divider over the [title], so the heading stays visible
  /// when the rail is collapsed; its label is an empty box of the same width
  /// as the other labels, so the extended rows keep their width.
  NavigationRailDestination _groupHeading(BuildContext context, String title) {
    final headingStyle = Theme.of(context).textTheme.labelSmall
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
    return NavigationRailDestination(
      disabled: true,
      icon: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 32, child: Divider(height: 1)),
            const SizedBox(height: 4),
            Text(title, style: headingStyle, softWrap: false),
          ],
        ),
      ),
      label: const SizedBox(width: maxXOffset - 88),
    );
  }
}
