import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The header row at the top of every list and detail page: an optional
/// back arrow and the title on the left, the page's actions on the right.
/// Shared by list and detail pages, so every page keeps its actions in the
/// same place.
class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    this.actions = const [],
    this.onBack,
    this.showUnsavedIndicator = false,
    super.key,
  });

  /// Below this width, [PageHeaderAction]s drop their label and render as
  /// icon-only buttons, leaving the title room to breathe.
  static const double compactThreshold = 480;

  static const double _height = 48;

  final String title;
  final List<Widget> actions;
  final VoidCallback? onBack;
  final bool showUnsavedIndicator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBack = this.onBack;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < compactThreshold;
        return SizedBox(
          height: _height,
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (onBack != null) ...[
                      IconButton(
                        key: const Key('page_header_back_button'),
                        tooltip: context.l10n.button_back,
                        icon: const Icon(Icons.arrow_back),
                        onPressed: onBack,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (showUnsavedIndicator) ...[
                      const SizedBox(width: 8),
                      Tooltip(
                        message: context.l10n.unsaved_indicator_tooltip,
                        child: Container(
                          key: const Key('page_header_unsaved_indicator'),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PageHeaderScope(
                compact: compact,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      actions[i],
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Tells the [PageHeaderAction]s below a [PageHeader] whether they should
/// render icon-only.
class PageHeaderScope extends InheritedWidget {
  const PageHeaderScope({
    required this.compact,
    required super.child,
    super.key,
  });

  final bool compact;

  static bool compactOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PageHeaderScope>()?.compact ??
      false;

  @override
  bool updateShouldNotify(PageHeaderScope oldWidget) =>
      compact != oldWidget.compact;
}

/// A button in a [PageHeader]'s action row. [primary] marks the page's main
/// action (add, save) with a filled style; the rest are tonal. Collapses to
/// an icon button with [label] as its tooltip when the header is compact.
class PageHeaderAction extends StatelessWidget {
  const PageHeaderAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.primary = false,
    this.loading = false,
    super.key,
  });

  final Widget icon;
  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final effectiveIcon = loading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : icon;
    final onPressed = loading ? null : this.onPressed;

    if (PageHeaderScope.compactOf(context)) {
      return primary
          ? IconButton.filled(
              tooltip: label,
              onPressed: onPressed,
              icon: effectiveIcon,
            )
          : IconButton.filledTonal(
              tooltip: label,
              onPressed: onPressed,
              icon: effectiveIcon,
            );
    }
    return primary
        ? FilledButton.icon(
            onPressed: onPressed,
            icon: effectiveIcon,
            label: Text(label),
          )
        : FilledButton.tonalIcon(
            onPressed: onPressed,
            icon: effectiveIcon,
            label: Text(label),
          );
  }
}
