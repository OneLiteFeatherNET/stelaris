import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/base/side_panel_layout.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// From this width on there is room for the preview beside the tabs.
const double expressionPreviewBreakpoint = 840;

/// Shares the preview's visibility with the tab below a detail page that the
/// preview belongs to. The page owns [shown], which the header's Preview
/// toggle sets, and tells the tab whether there is room for the preview beside
/// it: [wide] is false on a narrow screen, where the preview is a bottom sheet
/// instead. The [overrides] are shared too, so the values typed in stay when
/// the preview is built again, after a tab change or in the bottom sheet.
///
/// A detail page sets it up with [ExpressionPreviewHost].
class ExpressionPreviewScope extends InheritedWidget {
  const ExpressionPreviewScope({
    required this.shown,
    required this.wide,
    required this.overrides,
    required super.child,
    super.key,
  });

  /// Whether the preview is shown beside the tab pages.
  final ValueNotifier<bool> shown;

  /// Whether there is room for the preview beside the tab pages.
  final bool wide;

  /// The values typed into the preview, by variable name, in place of the
  /// stored test values. Never stored.
  final ValueNotifier<Map<String, String>> overrides;

  /// The scope above [context], or null when no detail page is above it. The
  /// tab pages then show no preview.
  static ExpressionPreviewScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ExpressionPreviewScope>();

  @override
  bool updateShouldNotify(ExpressionPreviewScope oldWidget) =>
      wide != oldWidget.wide ||
      shown != oldWidget.shown ||
      overrides != oldWidget.overrides;
}

/// The values typed into a preview for the current [variables], handed to
/// [builder] with the callback that changes them. They are kept in the
/// [ExpressionPreviewScope] above, or here without one. A value typed for a
/// variable since renamed or removed is left out.
class ExpressionPreviewValues extends StatefulWidget {
  const ExpressionPreviewValues({
    required this.variables,
    required this.builder,
    super.key,
  });

  final List<ExpressionVariable> variables;
  final Widget Function(
    BuildContext context,
    Map<String, String> overrides,
    ValueChanged<Map<String, String>> onOverridesChanged,
  )
  builder;

  @override
  State<ExpressionPreviewValues> createState() =>
      _ExpressionPreviewValuesState();
}

class _ExpressionPreviewValuesState extends State<ExpressionPreviewValues> {
  /// The values typed in when no scope is above to keep them.
  ValueNotifier<Map<String, String>>? _ownOverrides;

  @override
  void dispose() {
    _ownOverrides?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overrides =
        ExpressionPreviewScope.maybeOf(context)?.overrides ??
        (_ownOverrides ??= ValueNotifier(const {}));
    return ValueListenableBuilder(
      valueListenable: overrides,
      builder: (context, typed, _) => widget.builder(context, {
        for (final variable in widget.variables)
          variable.name: ?typed[variable.name],
      }, (values) => overrides.value = values),
    );
  }
}

/// A tab page's content, with the [preview] to its right in a
/// [SidePanelLayout] when the scope above shows it. Without a scope, or on a
/// narrow screen, the content is shown alone.
class ExpressionPreviewBeside extends StatelessWidget {
  const ExpressionPreviewBeside({
    required this.preview,
    required this.child,
    super.key,
  });

  final Widget preview;
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
        panel: KeyedSubtree(
          key: const ValueKey('expression_preview_slot'),
          child: preview,
        ),
      ),
    );
  }
}

/// The preview's state on a detail page: whether it is shown and the values
/// typed into it, which [previewScope] shares with the tabs and the bottom
/// sheet. The page calls [startPreviewValues] on its first build and
/// [syncPreviewValues] on every change of the selected model.
mixin ExpressionPreviewHost<T extends StatefulWidget> on State<T> {
  /// Whether the preview is shown beside the tab pages. Not kept across app
  /// starts, the app doesn't store settings locally yet.
  final ValueNotifier<bool> previewShown = ValueNotifier(true);

  /// The values typed into the preview, shared by every place it is shown.
  final ValueNotifier<Map<String, String>> previewOverrides = ValueNotifier(
    const {},
  );

  /// The model the [previewOverrides] were typed for. Another one starts
  /// without them.
  String? _overridesFor;

  @override
  void dispose() {
    previewShown.dispose();
    previewOverrides.dispose();
    super.dispose();
  }

  /// Notes the model with [id] as the one the values are typed for.
  void startPreviewValues(String? id) => _overridesFor = id;

  /// Drops the values that no longer apply to the model with [id] and its
  /// [variableNames]: all of them for another model, else those of a variable
  /// since renamed or removed.
  void syncPreviewValues(String? id, List<String> variableNames) {
    final previous = _overridesFor;
    _overridesFor = id;
    // A new model gets its id on the first save, and is still the same one.
    if (id != previous && previous != null) {
      previewOverrides.value = const {};
      return;
    }
    // A value typed for a variable since renamed or removed would come back
    // with a variable of that name again.
    final typed = previewOverrides.value;
    if (typed.keys.every(variableNames.contains)) return;
    previewOverrides.value = {
      for (final entry in typed.entries)
        if (variableNames.contains(entry.key)) entry.key: entry.value,
    };
  }

  /// [child] below the scope that shares the preview's state.
  Widget previewScope({required bool wide, required Widget child}) =>
      ExpressionPreviewScope(
        shown: previewShown,
        wide: wide,
        overrides: previewOverrides,
        child: child,
      );

  /// The header's Preview toggle. Beside the tabs it shows or hides the
  /// [preview]; without room for it there it opens it as a bottom sheet.
  Widget previewToggle({required bool wide, required Widget preview}) =>
      ValueListenableBuilder<bool>(
        valueListenable: previewShown,
        builder: (context, shown, _) => _PreviewToggle(
          wide: wide,
          shown: shown,
          onPressed: wide
              ? () => previewShown.value = !shown
              : () => _openPreviewSheet(context, preview),
        ),
      );

  /// Without room beside the tabs, the preview opens as a bottom sheet.
  void _openPreviewSheet(BuildContext context, Widget preview) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      // The sheet is not below the page, so it gets the scope again and with
      // it the values typed in.
      builder: (context) => previewScope(
        wide: false,
        // Above the keyboard, which the preview's inputs bring up.
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: preview,
        ),
      ),
    );
  }
}

/// The header's Preview toggle. Beside the tabs it shows or hides the preview,
/// and it is selected while the preview is shown. On a narrow screen it opens
/// the preview as a bottom sheet instead, and is not selected.
class _PreviewToggle extends StatelessWidget {
  const _PreviewToggle({
    required this.wide,
    required this.shown,
    required this.onPressed,
  });

  final bool wide;
  final bool shown;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final visible = wide && shown;
    return PageHeaderAction.toggle(
      key: const Key('expression_preview_toggle'),
      icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
      label: context.l10n.expression_preview_title,
      selected: visible,
      onPressed: onPressed,
    );
  }
}
