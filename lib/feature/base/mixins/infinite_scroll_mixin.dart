import 'dart:async';

import 'package:material_ui/material_ui.dart';

/// Generalized class which contains the scroll loading in a paginated context
mixin InfiniteScrollMixin<T extends StatefulWidget> on State<T> {
  /// Allow using an external controller if needed, otherwise create one.
  ScrollController? _internalController;

  ScrollController get scrollController {
    _internalController ??= ScrollController();
    return _internalController!;
  }

  Timer? _debounce;

  /// Threshold in pixels from the bottom to trigger loading.
  /// Defaults to 500 pixels (approx 1-2 screen heights).
  double get loadMoreThreshold => 500;

  /// Debounce duration to prevent spamming API calls.
  Duration get debounceDuration => const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _onScroll();
      }
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    _internalController?.dispose(); // Only dispose if we created it
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (!scrollController.hasClients || isLoadingMore() || !canLoadMore()) {
      return;
    }

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;

    // Calculate distance from bottom
    final distanceFromBottom = maxScroll - currentScroll;

    // Trigger if within threshold OR if the list is too short to scroll (maxScroll ~ 0)
    // but we still have more data to load.
    if (distanceFromBottom <= loadMoreThreshold) {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(debounceDuration, () {
        if (mounted) {
          onLoadMore();
        }
      });
    }
  }

  /// Whether the view is currently loading more data.
  bool isLoadingMore();

  /// Whether there is more data to load.
  bool canLoadMore();

  /// The action to perform when more data should be loaded.
  void onLoadMore();
}
