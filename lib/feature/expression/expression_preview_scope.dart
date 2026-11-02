import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/side_panel_layout.dart';
import 'package:stelaris/feature/expression/expression_preview.dart';

/// Shares the preview's visibility with the tab pages below a detail page.
/// The page owns [shown], which the header's Preview toggle sets, and tells
/// the pages whether there is room for the preview beside them: [wide] is
/// false on a narrow screen, where the preview is a bottom sheet instead.
class ExpressionPreviewScope extends InheritedWidget {
  const ExpressionPreviewScope({
    required this.shown,
    required this.wide,
    required super.child,
    super.key,
  });

  /// Whether the preview is shown beside the tab pages.
  final ValueNotifier<bool> shown;

  /// Whether there is room for the preview beside the tab pages.
  final bool wide;

  /// The scope above [context], or null when no detail page is above it. The
  /// tab pages then show no preview.
  static ExpressionPreviewScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ExpressionPreviewScope>();

  @override
  bool updateShouldNotify(ExpressionPreviewScope oldWidget) =>
      wide != oldWidget.wide || shown != oldWidget.shown;
}

/// A tab page's content, with the [ExpressionPreview] to its right in a
/// [SidePanelLayout] when the scope above shows it. Without a scope, or on a
/// narrow screen, the content is shown alone.
class ExpressionPreviewBeside extends StatelessWidget {
  const ExpressionPreviewBeside({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scope = ExpressionPreviewScope.maybeOf(context);
    if (scope == null || !scope.wide) return child;
    return ValueListenableBuilder<bool>(
      valueListenable: scope.shown,
      builder: (context, shown, _) => SidePanelLayout(
        shown: shown,
        content: (context, _) => child,
        panelWidth: (width) => (width * 0.35).clamp(280, 420),
        // The tab pages pad their content by 16, which is the gap.
        panelPadding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
        panel: const KeyedSubtree(
          key: ValueKey('expression_preview_slot'),
          child: ExpressionPreview(),
        ),
      ),
    );
  }
}
