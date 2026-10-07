import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';

/// Loads what a tab of the item detail page shows, and tells [builder]
/// whether it is still [pending].
///
/// The request starts right after the tab's first frame, so it runs while
/// the route or tab is still sliding in. The tab stays [pending] until the
/// request finished and the transition stands still, so building the data
/// doesn't make it stutter. Each item loads once: the tab is kept alive, so
/// swiping back to it doesn't load again, and selecting another item loads
/// that one.
class ItemTabLoader extends StatelessWidget {
  const ItemTabLoader({required this.load, required this.builder, super.key});

  /// Creates the action which loads the tab's data for the selected item.
  final ReduxAction<AppState> Function() load;

  final Widget Function(BuildContext context, bool pending) builder;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, String?>(
      converter: (store) => store.state.selectedItem?.id,
      // Another item starts over, with a load of its own.
      builder: (context, itemId) =>
          _ItemTab(key: ValueKey(itemId), load: load, builder: builder),
    );
  }
}

class _ItemTab extends StatefulWidget {
  const _ItemTab({required this.load, required this.builder, super.key});

  final ReduxAction<AppState> Function() load;
  final Widget Function(BuildContext context, bool pending) builder;

  @override
  State<_ItemTab> createState() => _ItemTabState();
}

class _ItemTabState extends State<_ItemTab> with AutomaticKeepAliveClientMixin {
  ModalRoute<Object?>? _route;
  Animation<double>? _tabAnimation;
  bool _loading = true;
  bool _settled = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Not during the build, the dispatch changes the store.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.dispatchAndWait(widget.load()).whenComplete(() {
        if (mounted) setState(() => _loading = false);
      });
    });
    _checkAfterFrame();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _route = ModalRoute.of(context);
    _tabAnimation = DefaultTabController.maybeOf(context)?.animation;
  }

  /// Whether the route and the tab bar finished sliding this tab in.
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

  /// Looks again after every frame until the tab stands still. Polling
  /// instead of listening, because coming onstage notifies neither the
  /// route's animation nor the dependencies.
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.builder(context, _loading || !_settled);
  }
}
