import 'package:material_ui/material_ui.dart';

/// A page's [content] with a [panel] to its right, e.g. a preview of what the
/// page edits. The content takes the room the panel leaves.
///
/// While [shown] changes, the content gives way to the panel, which slides
/// and fades in from the right edge, and back. The panel is [panelWidth]
/// wide, given the width of the whole layout, and inset by [panelPadding].
/// Where there is no room for a panel, the page lays itself out without this
/// widget.
class SidePanelLayout extends StatelessWidget {
  const SidePanelLayout({
    required this.content,
    required this.panel,
    required this.panelWidth,
    this.panelPadding = EdgeInsets.zero,
    this.shown = true,
    super.key,
  });

  /// Builds the content for the width it has beside the panel.
  final Widget Function(BuildContext context, double width) content;
  final Widget panel;
  final double Function(double layoutWidth) panelWidth;
  final EdgeInsetsGeometry panelPadding;
  final bool shown;

  /// The key of the panel while it is shown.
  static const Key panelKey = ValueKey('side_panel');

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) =>
                  content(context, constraints.maxWidth),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => SizeTransition(
              sizeFactor: animation,
              axis: Axis.horizontal,
              // Top, the transition fills the height and would center it.
              alignment: AlignmentDirectional.topStart,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: shown
                ? Padding(
                    key: panelKey,
                    padding: panelPadding,
                    child: SizedBox(
                      width: panelWidth(constraints.maxWidth),
                      child: panel,
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('no_side_panel')),
          ),
        ],
      ),
    );
  }
}
