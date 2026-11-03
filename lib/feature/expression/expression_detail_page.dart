import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/expression/expression_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
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

class _ExpressionDetailPageState extends State<ExpressionDetailPage>
    with ExpressionPreviewHost {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ExpressionDetailView>(
      vm: () => _ExpressionDetailFactory(),
      // The catalog feeds the formula editor on the General tab. It is loaded
      // once, so opening another expression does not request it again.
      onInit: (store) => store.dispatch(LoadExpressionCatalogAction()),
      onDispose: (store) =>
          store.dispatch(RemoveSelectedExpression(), notify: false),
      onInitialBuild: (context, store, vm) => startPreviewValues(vm.id),
      onDidChange: (context, store, vm) =>
          syncPreviewValues(vm.id, vm.variableNames),
      builder: (context, vm) => LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= expressionPreviewBreakpoint;
          // Above the shell, so the header knows the tab and shows the
          // Preview toggle on the General tab only.
          return DefaultTabController(
            // Keyed by the requested tab: a new ?tab= on the same route has
            // to start a new controller, or the old tab would stay selected.
            key: ValueKey(requestedTab(context)),
            initialIndex: initialTabIndex(context, ExpressionDetailPage.tabs),
            length: ExpressionDetailPage.tabs.length,
            child: previewScope(
              wide: wide,
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
                          previewToggle(
                            wide: wide,
                            preview: const ExpressionPreview(),
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
