import 'package:material_ui/material_ui.dart';
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

/// A tab page's content, with the [ExpressionPreview] to its right when the
/// scope above shows it. The page gives way to the preview, which slides and
/// fades in from the right edge. Without a scope, or on a narrow screen, the
/// content is shown alone.
class ExpressionPreviewBeside extends StatelessWidget {
  const ExpressionPreviewBeside({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scope = ExpressionPreviewScope.maybeOf(context);
    if (scope == null || !scope.wide) return child;
    return ValueListenableBuilder<bool>(
      valueListenable: scope.shown,
      builder: (context, shown, _) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: child),
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
                ? LayoutBuilder(
                    key: const ValueKey('expression_preview_slot'),
                    builder: (context, constraints) => Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                      child: SizedBox(
                        width: (constraints.maxWidth * 0.35).clamp(280, 420),
                        child: const ExpressionPreview(),
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('no_expression_preview')),
          ),
        ],
      ),
    );
  }
}
