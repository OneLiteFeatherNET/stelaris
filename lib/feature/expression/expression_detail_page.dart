import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/expression_model.dart';
import 'package:stelaris/api/state/actions/expression/expression_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/expression/expression_general_page.dart';
import 'package:stelaris/feature/expression/expression_preview.dart';
import 'package:stelaris/feature/expression/expression_preview_scope.dart';
import 'package:stelaris/feature/expression/expression_test_page.dart';
import 'package:stelaris/feature/expression/expression_variables_page.dart';
import 'package:stelaris/feature/model/detail_tabs.dart';
import 'package:stelaris/feature/model/model_detail_actions.dart';
import 'package:stelaris/feature/model/model_detail_shell.dart';
import 'package:stelaris/feature/model/model_detail_tab_bar.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The detail view reached by tapping an expression in [ExpressionPage].
///
/// Shows the shared [ModelDetailShell] header with its actions, the Preview
/// toggle among them, and a `TabBar`/`TabBarView` below it. Each tab reads the
/// selected expression from Redux itself, see [ExpressionGeneralPage],
/// [ExpressionVariablesPage] and [ExpressionTestPage].
class ExpressionDetailPage extends StatefulWidget {
  const ExpressionDetailPage({super.key});

  /// The tabs in order. Their ids are what `?tab=` and the command palette
  /// refer to.
  static final List<DetailTab> tabs = [
    DetailTab('general', (l10n) => l10n.tab_general),
    DetailTab('variables', (l10n) => l10n.tab_variables),
    DetailTab('test', (l10n) => l10n.tab_test),
  ];

  @override
  State<ExpressionDetailPage> createState() => _ExpressionDetailPageState();
}

class _ExpressionDetailPageState extends State<ExpressionDetailPage> {
  /// Whether the preview is shown beside the tab pages. Not kept across app
  /// starts, the app doesn't store settings locally yet.
  final ValueNotifier<bool> _previewShown = ValueNotifier(true);

  /// From this width on there is room for the preview beside the tabs.
  static const double _previewBreakpoint = 840;

  @override
  void dispose() {
    _previewShown.dispose();
    super.dispose();
  }

  /// Without room beside the tabs, the preview opens as a bottom sheet.
  void _openPreviewSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: ExpressionPreview(),
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
      builder: (context, vm) => LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= _previewBreakpoint;
          return ExpressionPreviewScope(
            shown: _previewShown,
            wide: wide,
            child: ModelDetailShell(
              entry: NavigationEntry.expression,
              title: vm.title,
              actions: [
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
                  deleteTitle: context.l10n.dialog_expression_delete_title,
                  removeAction: ExpressionRemoveAction.new,
                  readNotes: (model) => model.comment,
                ),
              ],
              body: DefaultTabController(
                // Keyed by the requested tab: a new ?tab= on the same route has
                // to start a new controller, or the old tab would stay selected.
                key: ValueKey(requestedTab(context)),
                initialIndex: initialTabIndex(
                  context,
                  ExpressionDetailPage.tabs,
                ),
                length: ExpressionDetailPage.tabs.length,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ModelDetailTabBar(
                      tabs: [
                        for (final tab in ExpressionDetailPage.tabs)
                          Tab(text: tab.label(context.l10n)),
                      ],
                    ),
                    // The preview is inside the General and Variables pages,
                    // not beside the TabBarView: the page view keeps its
                    // width, so a tab change while the preview comes or goes
                    // does not snap to another page.
                    const Expanded(
                      child: TabBarView(
                        children: [
                          ExpressionGeneralPage(),
                          ExpressionVariablesPage(),
                          ExpressionTestPage(),
                        ],
                      ),
                    ),
                  ],
                ),
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
    return PageHeaderAction(
      key: const Key('expression_preview_toggle'),
      icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
      label: context.l10n.expression_preview_title,
      selected: visible,
      onPressed: onPressed,
    );
  }
}

class _ExpressionDetailView extends Vm {
  _ExpressionDetailView({required this.title}) : super(equals: [title]);

  final String? title;
}

class _ExpressionDetailFactory
    extends VmFactory<AppState, ExpressionDetailPage, _ExpressionDetailView> {
  @override
  _ExpressionDetailView fromStore() =>
      _ExpressionDetailView(title: state.selectedExpression?.uiName);
}
