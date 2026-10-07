import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/util/settled_after_transitions.dart';

/// Loads what a tab of the item detail page shows.
///
/// The request starts right after the tab's first frame, so it runs while
/// the route or tab is still sliding in; the tab shows the data only once
/// it stands still (see [SettledAfterTransitions]), so building it doesn't
/// make the transition stutter. Each item loads once: the tab is kept
/// alive, so swiping back to it doesn't load again.
///
/// Pass [selectedItemChanged] to the tab's `StoreConnector.onDidChange`, so
/// selecting another item while the tab is kept alive loads that item.
mixin ItemTabLoading<T extends StatefulWidget>
    on State<T>, AutomaticKeepAliveClientMixin<T>, SettledAfterTransitions<T> {
  /// The item the tab requested its data for.
  String? _loadedFor;

  /// The action which loads the tab's data for the selected item.
  ReduxAction<AppState> createLoadAction();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Not during the build, the dispatch changes the store.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _load(
        StoreProvider.state<AppState>(context, notify: false).selectedItem?.id,
      );
    });
  }

  /// Loads the data of [itemId], unless the tab already did.
  void selectedItemChanged(String? itemId) => _load(itemId);

  void _load(String? itemId) {
    if (itemId == _loadedFor) return;
    _loadedFor = itemId;
    context.dispatch(createLoadAction());
  }
}
