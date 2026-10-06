import 'dart:async';

import 'package:material_ui/material_ui.dart';

/// Turns off the tooltips in [child] while it scrolls.
///
/// A tooltip shows as soon as the pointer is over its target, also when the
/// target is moved under a resting pointer by scrolling. Its overlay doesn't
/// scroll along, so it popped up and was left behind outside the list.
///
/// A wheel ends its scroll after every notch, so the tooltips only come back
/// once nothing scrolled for [settle].
class HideTooltipsWhileScrolling extends StatefulWidget {
  const HideTooltipsWhileScrolling({
    required this.child,
    this.settle = const Duration(milliseconds: 300),
    super.key,
  });

  final Widget child;
  final Duration settle;

  @override
  State<HideTooltipsWhileScrolling> createState() =>
      _HideTooltipsWhileScrollingState();
}

class _HideTooltipsWhileScrollingState
    extends State<HideTooltipsWhileScrolling> {
  bool _scrolling = false;
  Timer? _settle;

  @override
  void dispose() {
    _settle?.cancel();
    super.dispose();
  }

  bool _onScroll(ScrollUpdateNotification notification) {
    _settle?.cancel();
    _settle = Timer(widget.settle, () => setState(() => _scrolling = false));
    if (!_scrolling) setState(() => _scrolling = true);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollUpdateNotification>(
      onNotification: _onScroll,
      // Hidden tooltips leave the tree, which also drops a pending or open
      // one.
      child: TooltipVisibility(visible: !_scrolling, child: widget.child),
    );
  }
}
