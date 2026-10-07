import 'package:material_ui/material_ui.dart';

/// Tells a [State] once what brought it into view stands still: the route
/// sliding in and the tab bar switching over to it.
///
/// Expensive building, like a large widget tree from loaded data, waits
/// for [settled], so it doesn't make the transition stutter.
mixin SettledAfterTransitions<T extends StatefulWidget> on State<T> {
  ModalRoute<Object?>? _route;
  Animation<double>? _tabAnimation;
  bool _settled = false;

  /// Whether the route and tab transitions finished. Turns true once, with a
  /// rebuild, and stays true.
  bool get settled => _settled;

  @override
  void initState() {
    super.initState();
    _checkAfterFrame();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _route = ModalRoute.of(context);
    _tabAnimation = DefaultTabController.maybeOf(context)?.animation;
  }

  bool _standsStill() {
    final route = _route;
    final tab = _tabAnimation;
    // A pushed route is built offstage for a frame first, to measure its
    // heroes, and reports its animation as complete meanwhile.
    final routeStands =
        route == null ||
        (!route.offstage && (route.animation?.isCompleted ?? true));
    final tabStands = tab == null || tab.value == tab.value.roundToDouble();
    return routeStands && tabStands;
  }

  /// Looks again after every frame. Polling instead of listening, because
  /// coming onstage notifies neither the route's animation nor the
  /// dependencies.
  void _checkAfterFrame() {
    WidgetsBinding.instance
      ..addPostFrameCallback((_) {
        if (!mounted) return;
        if (_standsStill()) {
          setState(() => _settled = true);
        } else {
          _checkAfterFrame();
        }
      })
      ..ensureVisualUpdate();
  }
}
