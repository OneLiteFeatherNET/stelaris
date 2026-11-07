import 'dart:ui' show lerpDouble;

import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/navigation_vm_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/settings/settings_dialog.dart';
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
            extended: MediaQuery.sizeOf(context).width >= 1000
                ? vm.openNavigation
                : false,
            onDestinationSelected: (index) =>
                _onDestinationSelected(context, index),
            labelType: NavigationRailLabelType.none,
            destinations: _buildNavigationView(context),
            selectedIndex: selectedIndex != -1 ? selectedIndex : 0,
            // Settings are app-wide rather than a page, so they sit apart
            // from the destinations at the bottom of the rail.
            trailingAtBottom: true,
            trailing: const _RailSettingsEntry(),
            // The destinations scroll on short windows, so the groups below
            // the sections never push the rail past its height.
            scrollable: true,
          ),
        );
      },
    );
  }

  /// The rail index of the asset entry at [assetIndex] in
  /// [AssetNavigationEntry.values]. One slot after the sections is the
  /// "Assets" heading.
  static int _assetRailIndex(int assetIndex) =>
      sectionEntries.length + 1 + assetIndex;

  /// The rail index of the runtime entry at [runtimeIndex] in
  /// [runtimeNavigationEntries]. After the asset pages is the "Runtime"
  /// heading.
  static int _runtimeRailIndex(int runtimeIndex) =>
      _assetRailIndex(AssetNavigationEntry.values.length) + 1 + runtimeIndex;

  /// The rail index of the build entry at [buildIndex] in
  /// [BuildNavigationEntry.values]. After the runtime entries is the "Build"
  /// heading.
  static int _buildRailIndex(int buildIndex) =>
      _runtimeRailIndex(runtimeNavigationEntries.length) + 1 + buildIndex;

  /// The rail index of the destination showing [location], or -1 if none does.
  /// Nested routes (e.g. a model's `/detail` route) share the parent entry's
  /// highlight rather than falling back to the first entry.
  int _indexForLocation(String location) {
    final currentEntry = entryForLocation(location);
    if (currentEntry != null) {
      if (currentEntry.isRuntime) {
        return _runtimeRailIndex(
          runtimeNavigationEntries.indexOf(currentEntry),
        );
      }
      return sectionEntries.indexOf(currentEntry);
    }
    final currentAssetEntry = assetEntryForLocation(location);
    if (currentAssetEntry != null) {
      return _assetRailIndex(currentAssetEntry.index);
    }
    final currentBuildEntry = buildEntryForLocation(location);
    if (currentBuildEntry != null) {
      return _buildRailIndex(currentBuildEntry.index);
    }
    return -1;
  }

  /// Handles the selection of a navigation destination. Leaving a detail
  /// page with unsaved edits is guarded by the detail route's `onExit`.
  void _onDestinationSelected(BuildContext context, int index) {
    if (index < sectionEntries.length) {
      context.go(sectionEntries[index].route);
      return;
    }
    // The headings themselves are disabled and never reach here.
    final assetIndex = index - _assetRailIndex(0);
    if (assetIndex >= 0 && assetIndex < AssetNavigationEntry.values.length) {
      context.go(AssetNavigationEntry.values[assetIndex].route);
      return;
    }
    final runtimeIndex = index - _runtimeRailIndex(0);
    if (runtimeIndex >= 0 && runtimeIndex < runtimeNavigationEntries.length) {
      context.go(runtimeNavigationEntries[runtimeIndex].route);
      return;
    }
    final buildIndex = index - _buildRailIndex(0);
    if (buildIndex >= 0 && buildIndex < BuildNavigationEntry.values.length) {
      context.go(BuildNavigationEntry.values[buildIndex].route);
    }
  }

  /// Builds the list of navigation destinations for the [NavigationRail]: the
  /// sections, the disabled "Assets" heading, the asset pages, the disabled
  /// "Runtime" heading, the runtime entries, the disabled "Build" heading,
  /// then the build pages.
  List<NavigationRailDestination> _buildNavigationView(BuildContext context) {
    return [
      for (final navigationValue in sectionEntries)
        _destination(
          display: navigationValue.display,
          icon: navigationValue.data,
          selectedIcon: navigationValue.selected,
        ),
      _groupHeading(context, context.l10n.navigation_group_assets),
      for (final assetValue in AssetNavigationEntry.values)
        _destination(
          display: assetValue.display,
          icon: assetValue.data,
          selectedIcon: assetValue.selected,
        ),
      _groupHeading(context, context.l10n.navigation_group_runtime),
      for (final runtimeValue in runtimeNavigationEntries)
        _destination(
          display: runtimeValue.display,
          icon: runtimeValue.data,
          selectedIcon: runtimeValue.selected,
        ),
      _groupHeading(context, context.l10n.navigation_group_build),
      for (final buildValue in BuildNavigationEntry.values)
        _destination(
          display: buildValue.display,
          icon: buildValue.data,
          selectedIcon: buildValue.selected,
        ),
    ];
  }

  /// A destination for one page. Its label is hidden until the rail is
  /// extended.
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

  /// A disabled heading above a group of pages, such as the asset pages or the
  /// runtime entries. Its icon is a short divider over the [title], so the
  /// heading stays visible when the rail is collapsed; its label is an empty
  /// box of the same width as the other labels, so the extended rows keep
  /// their width.
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

/// The settings entry at the bottom of the rail. It is built like a rail
/// destination with the default Material 3 rail style, so it behaves like
/// one: the whole row is the tap target, and the hover and splash ink stay
/// on the indicator pill around the icon. It is never selected, because the
/// settings open as a dialog rather than a page.
///
/// The rail centers its trailing widget, so the row takes the width of a
/// destination row to keep the icon under the destination icons while the
/// rail extends and collapses.
class _RailSettingsEntry extends StatelessWidget {
  const _RailSettingsEntry();

  static const double _iconColumnWidth = 80;

  /// The rail's spacing above and below a destination icon.
  static const double _verticalSpacing = 6;

  /// The size of the rail's indicator pill behind a destination icon.
  static const Size _pillSize = Size(56, 32);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final animation = NavigationRail.extendedAnimation(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) => SizedBox(
          width: lerpDouble(_iconColumnWidth, maxXOffset, animation.value),
          child: child,
        ),
        child: Semantics(
          button: true,
          child: Material(
            type: MaterialType.transparency,
            child: _PillInkResponse(
              pillCenterX: _iconColumnWidth / 2,
              pillTop: _verticalSpacing,
              pillSize: _pillSize,
              textDirection: Directionality.of(context),
              hoverColor: colors.primary.withValues(alpha: 0.04),
              splashColor: colors.primary.withValues(alpha: 0.12),
              onTap: () => showDialog(
                context: context,
                builder: (context) => const SettingsDialog(),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: _verticalSpacing),
                child: Row(
                  children: [
                    SizedBox(
                      width: _iconColumnWidth,
                      height: _pillSize.height,
                      child: Icon(
                        Icons.settings_outlined,
                        size: 24,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    Flexible(
                      child: FadeTransition(
                        alwaysIncludeSemantics: true,
                        opacity: animation.drive(
                          CurveTween(curve: const Interval(0.5, 1)),
                        ),
                        child: Text(
                          context.l10n.settings_title,
                          style: theme.textTheme.labelMedium
                              ?.copyWith(color: colors.onSurface)
                              .merge(navigationEntryTextStyle),
                          softWrap: false,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// An ink response over a whole rail row whose hover and splash ink is
/// confined to the indicator pill around the icon, as on a rail destination.
class _PillInkResponse extends InkResponse {
  const _PillInkResponse({
    required this.pillCenterX,
    required this.pillTop,
    required this.pillSize,
    required this.textDirection,
    super.child,
    super.onTap,
    super.hoverColor,
    super.splashColor,
  }) : super(
         containedInkWell: true,
         highlightShape: BoxShape.rectangle,
         customBorder: const StadiumBorder(),
       );

  /// The horizontal center of the pill, from the start of the row.
  final double pillCenterX;

  /// The top of the pill, from the top of the row.
  final double pillTop;

  final Size pillSize;

  /// Mirrors the pill's position in right-to-left layouts.
  final TextDirection textDirection;

  @override
  RectCallback? getRectCallback(RenderBox referenceBox) {
    return () {
      final centerX = textDirection == TextDirection.rtl
          ? referenceBox.size.width - pillCenterX
          : pillCenterX;
      return Rect.fromLTWH(
        centerX - pillSize.width / 2,
        pillTop,
        pillSize.width,
        pillSize.height,
      );
    };
  }
}
