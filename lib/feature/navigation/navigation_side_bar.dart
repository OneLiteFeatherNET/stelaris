import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/navigation_vm_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/util/color_scheme_ext.dart';

const double maxXOffset = 208;
const List<NavigationEntry> navigationEntries = NavigationEntry.values;
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
    // Nested routes (e.g. a model's `/detail` route) share the parent
    // entry's highlight rather than falling back to the first entry.
    final currentEntry = entryForLocation(routerUri);
    final selectedIndex = currentEntry == null
        ? -1
        : navigationEntries.indexOf(currentEntry);

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
            destinations: _buildNavigationView(),
            selectedIndex: selectedIndex != -1 ? selectedIndex : 0,
          ),
        );
      },
    );
  }

  /// Handles the selection of a navigation destination. Leaving a detail
  /// page with unsaved edits is guarded by the detail route's `onExit`.
  void _onDestinationSelected(BuildContext context, int index) =>
      context.go(navigationEntries[index].route);

  /// Builds the list of navigation destinations for the [NavigationRail].
  List<NavigationRailDestination> _buildNavigationView() {
    return List.generate(navigationEntries.length, (index) {
      final navigationValue = navigationEntries[index];
      return NavigationRailDestination(
        selectedIcon: Icon(navigationValue.selected),
        icon: Icon(navigationValue.data),
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
                navigationValue.display,
                style: navigationEntryTextStyle,
                softWrap: false,
                overflow: TextOverflow.fade,
              ),
            ),
          ),
        ),
      );
    });
  }
}
