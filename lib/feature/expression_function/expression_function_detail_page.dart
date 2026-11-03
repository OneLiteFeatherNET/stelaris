import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/expression/expression_actions.dart';
import 'package:stelaris/api/state/actions/expression/expression_function_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/expression/expression_preview_scope.dart';
import 'package:stelaris/feature/expression_function/expression_function_general_page.dart';
import 'package:stelaris/feature/expression_function/expression_function_interface_page.dart';
import 'package:stelaris/feature/expression_function/expression_function_parameters_page.dart';
import 'package:stelaris/feature/expression_function/expression_function_preview.dart';
import 'package:stelaris/feature/model/detail_tabs.dart';
import 'package:stelaris/feature/model/model_detail_actions.dart';
import 'package:stelaris/feature/model/model_detail_shell.dart';
import 'package:stelaris/feature/model/model_detail_tab_bar.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The detail view reached by tapping a function in [ExpressionFunctionPage].
///
/// Shows the shared [ModelDetailShell] header with its actions, and a
/// `TabBar`/`TabBarView` below it. Each tab reads the selected function from
/// Redux itself. The [ExpressionFunctionPreview], where the function is tried
/// with other values, belongs to the General tab, and so does the Preview
/// toggle among the actions.
class ExpressionFunctionDetailPage extends StatefulWidget {
  const ExpressionFunctionDetailPage({super.key});

  /// The tab the preview belongs to.
  static final DetailTab generalTab = DetailTab(
    'general',
    (l10n) => l10n.tab_general,
  );

  /// The tabs in order. Their ids are what `?tab=` and the command palette
  /// refer to.
  static final List<DetailTab> tabs = [
    generalTab,
    DetailTab('parameters', (l10n) => l10n.tab_parameters),
    DetailTab('interface', (l10n) => l10n.tab_interface),
  ];

  @override
  State<ExpressionFunctionDetailPage> createState() =>
      _ExpressionFunctionDetailPageState();
}

class _ExpressionFunctionDetailPageState
    extends State<ExpressionFunctionDetailPage>
    with ExpressionPreviewHost {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ExpressionFunctionDetailView>(
      vm: () => _ExpressionFunctionDetailFactory(),
      // The catalog feeds the formula editor on the General tab, and holds
      // the project's functions the formulas may call.
      onInit: (store) => store.dispatch(LoadExpressionCatalogAction()),
      onDispose: (store) =>
          store.dispatch(RemoveSelectedExpressionFunction(), notify: false),
      onInitialBuild: (context, store, vm) => startPreviewValues(vm.id),
      onDidChange: (context, store, vm) =>
          syncPreviewValues(vm.id, vm.parameterNames),
      builder: (context, vm) => LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= expressionPreviewBreakpoint;
          final tabs = ExpressionFunctionDetailPage.tabs;
          // Above the shell, so the header knows the tab and shows the
          // Preview toggle on the General tab only.
          return DefaultTabController(
            // Keyed by the requested tab: a new ?tab= on the same route has
            // to start a new controller, or the old tab would stay selected.
            key: ValueKey(requestedTab(context)),
            initialIndex: initialTabIndex(context, tabs),
            length: tabs.length,
            child: previewScope(
              wide: wide,
              child: Builder(
                builder: (context) {
                  final controller = DefaultTabController.of(context);
                  return ListenableBuilder(
                    listenable: controller,
                    builder: (context, body) => ModelDetailShell(
                      entry: NavigationEntry.function,
                      title: vm.title,
                      actions: [
                        if (tabs[controller.index] ==
                            ExpressionFunctionDetailPage.generalTab)
                          previewToggle(
                            wide: wide,
                            preview: const ExpressionFunctionPreview(),
                          ),
                        ModelDetailActions<ExpressionFunctionModel>(
                          entry: NavigationEntry.function,
                          selectModel: (state) =>
                              state.selectedExpressionFunction,
                          nameSelector: (model) => model.uiName,
                          keySelector: (model) => model.name,
                          // No Delete here: a function is deleted from the
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
                            for (final tab in tabs)
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
                              ExpressionFunctionGeneralPage(),
                              ExpressionFunctionParametersPage(),
                              ExpressionFunctionInterfacePage(),
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

class _ExpressionFunctionDetailView extends Vm {
  _ExpressionFunctionDetailView({
    required this.title,
    required this.id,
    required this.parameterNames,
  }) : super(equals: [title, id, ...parameterNames]);

  final String? title;
  final String? id;
  final List<String> parameterNames;
}

class _ExpressionFunctionDetailFactory
    extends
        VmFactory<
          AppState,
          ExpressionFunctionDetailPage,
          _ExpressionFunctionDetailView
        > {
  @override
  _ExpressionFunctionDetailView fromStore() => _ExpressionFunctionDetailView(
    title: state.selectedExpressionFunction?.uiName,
    id: state.selectedExpressionFunction?.id,
    parameterNames: [
      for (final parameter
          in state.selectedExpressionFunction?.parameters ?? const [])
        parameter.name,
    ],
  );
}
