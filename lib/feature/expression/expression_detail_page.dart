import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/expression/expression_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/expression/expression_general_page.dart';
import 'package:stelaris/feature/expression/expression_preview.dart';
import 'package:stelaris/feature/expression/expression_preview_scope.dart';
import 'package:stelaris/feature/expression/expression_variables_page.dart';
import 'package:stelaris/feature/model/detail_tabs.dart';
import 'package:stelaris/feature/model/model_detail_actions.dart';
import 'package:stelaris/feature/model/model_detail_shell.dart';
import 'package:stelaris/feature/model/model_detail_tab_bar.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The detail view reached by tapping an expression in [ExpressionPage].
///
/// Shows the shared [ModelDetailShell] header with its actions, and a
/// `TabBar`/`TabBarView` below it. Each tab reads the selected expression from
/// Redux itself, see [ExpressionGeneralPage] and [ExpressionVariablesPage].
/// The preview, where other values are tried, belongs to the General tab, and
/// so does the Preview toggle among the actions.
class ExpressionDetailPage extends StatefulWidget {
  const ExpressionDetailPage({super.key});

  /// The tab the preview belongs to.
  static final DetailTab generalTab = DetailTab(
    'general',
    (l10n) => l10n.tab_general,
  );

  /// The tabs in order. Their ids are what `?tab=` and the command palette
  /// refer to.
  static final List<DetailTab> tabs = [
    generalTab,
    DetailTab('variables', (l10n) => l10n.tab_variables),
  ];

  @override
  State<ExpressionDetailPage> createState() => _ExpressionDetailPageState();
}

class _ExpressionDetailPageState extends State<ExpressionDetailPage> {
  /// Whether the preview is shown beside the tab pages. Not kept across app
  /// starts, the app doesn't store settings locally yet.
  final ValueNotifier<bool> _previewShown = ValueNotifier(true);

  /// The values typed into the preview, shared by every place it is shown.
  final ValueNotifier<Map<String, String>> _previewOverrides = ValueNotifier(
    const {},
  );

  /// The expression the [_previewOverrides] were typed for. Another one starts
  /// without them.
  String? _overridesFor;

  /// From this width on there is room for the preview beside the tabs.
  static const double _previewBreakpoint = 840;

  @override
  void dispose() {
    _previewShown.dispose();
    _previewOverrides.dispose();
    super.dispose();
  }

  /// Without room beside the tabs, the preview opens as a bottom sheet.
  void _openPreviewSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      // The sheet is not below the page, so it gets the scope again and with
      // it the values typed in.
      builder: (context) => ExpressionPreviewScope(
        shown: _previewShown,
        wide: false,
        overrides: _previewOverrides,
        // Above the keyboard, which the preview's inputs bring up.
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: const ExpressionPreview(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ExpressionDetailView>(
      vm: () => _ExpressionDetailFactory(),
      // The catalog feeds the formula editor on the General tab. It is loaded
      // once, so opening another expression does not request it again.
      onInit: (store) => store.dispatch(LoadExpressionCatalogAction()),
      onDispose: (store) =>
          store.dispatch(RemoveSelectedExpression(), notify: false),
      onInitialBuild: (context, store, vm) => _overridesFor = vm.id,
      onDidChange: (context, store, vm) {
        final previous = _overridesFor;
        _overridesFor = vm.id;
        // A new expression gets its id on the first save, and is still the
        // same one.
        if (vm.id != previous && previous != null) {
          _previewOverrides.value = const {};
          return;
        }
        // A value typed for a variable since renamed or removed would come
        // back with a variable of that name again.
        final typed = _previewOverrides.value;
        if (typed.keys.every(vm.variableNames.contains)) return;
        _previewOverrides.value = {
          for (final entry in typed.entries)
            if (vm.variableNames.contains(entry.key)) entry.key: entry.value,
        };
      },
      builder: (context, vm) => LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= _previewBreakpoint;
          // Above the shell, so the header knows the tab and shows the
          // Preview toggle on the General tab only.
          return DefaultTabController(
            // Keyed by the requested tab: a new ?tab= on the same route has
            // to start a new controller, or the old tab would stay selected.
            key: ValueKey(requestedTab(context)),
            initialIndex: initialTabIndex(context, ExpressionDetailPage.tabs),
            length: ExpressionDetailPage.tabs.length,
            child: ExpressionPreviewScope(
              shown: _previewShown,
              wide: wide,
              overrides: _previewOverrides,
              child: Builder(
                builder: (context) {
                  final tabs = DefaultTabController.of(context);
                  return ListenableBuilder(
                    listenable: tabs,
                    builder: (context, body) => ModelDetailShell(
                      entry: NavigationEntry.expression,
                      title: vm.title,
                      actions: [
                        if (ExpressionDetailPage.tabs[tabs.index] ==
                            ExpressionDetailPage.generalTab)
                          ValueListenableBuilder<bool>(
                            valueListenable: _previewShown,
                            builder: (context, shown, _) => _PreviewToggle(
                              wide: wide,
                              shown: shown,
                              onPressed: wide
                                  ? () => _previewShown.value = !shown
                                  : () => _openPreviewSheet(context),
                            ),
                          ),
                        ModelDetailActions<ExpressionModel>(
                          entry: NavigationEntry.expression,
                          selectModel: (state) => state.selectedExpression,
                          nameSelector: (model) => model.uiName,
                          keySelector: (model) => '',
                          // No Delete here: an expression is deleted from the
                          // overview.
                          readNotes: (model) => model.comment,
                        ),
                      ],
                      body: body!,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ModelDetailTabBar(
                          tabs: [
                            for (final tab in ExpressionDetailPage.tabs)
                              Tab(text: tab.label(context.l10n)),
                          ],
                        ),
                        // The preview is inside the General page, not beside
                        // the TabBarView: the page view keeps its width, so a
                        // tab change while the preview comes or goes does not
                        // snap to another page.
                        const Expanded(
                          child: TabBarView(
                            children: [
                              ExpressionGeneralPage(),
                              ExpressionVariablesPage(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
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

class _ExpressionDetailView extends Vm {
  _ExpressionDetailView({
    required this.title,
    required this.id,
    required this.variableNames,
  }) : super(equals: [title, id, ...variableNames]);

  final String? title;
  final String? id;
  final List<String> variableNames;
}

class _ExpressionDetailFactory
    extends VmFactory<AppState, ExpressionDetailPage, _ExpressionDetailView> {
  @override
  _ExpressionDetailView fromStore() => _ExpressionDetailView(
    title: state.selectedExpression?.uiName,
    id: state.selectedExpression?.id,
    variableNames: [
      for (final variable in state.selectedExpression?.variables ?? const [])
        variable.name,
    ],
  );
}
