import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/expression/expression_actions.dart';
import 'package:stelaris/api/state/actions/expression/expression_function_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/expression_function/expression_function_general_page.dart';
import 'package:stelaris/feature/expression_function/expression_function_interface_page.dart';
import 'package:stelaris/feature/expression_function/expression_function_parameters_page.dart';
import 'package:stelaris/feature/expression_function/expression_function_test_page.dart';
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
/// Redux itself.
class ExpressionFunctionDetailPage extends StatelessWidget {
  const ExpressionFunctionDetailPage({super.key});

  /// The tabs in order. Their ids are what `?tab=` and the command palette
  /// refer to.
  static final List<DetailTab> tabs = [
    DetailTab('general', (l10n) => l10n.tab_general),
    DetailTab('parameters', (l10n) => l10n.tab_parameters),
    DetailTab('test', (l10n) => l10n.tab_test),
    DetailTab('interface', (l10n) => l10n.tab_interface),
  ];

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ExpressionFunctionDetailView>(
      vm: () => _ExpressionFunctionDetailFactory(),
      // The catalog feeds the formula editor on the General tab, and holds
      // the project's functions the formulas may call.
      onInit: (store) => store.dispatch(LoadExpressionCatalogAction()),
      onDispose: (store) =>
          store.dispatch(RemoveSelectedExpressionFunction(), notify: false),
      builder: (context, vm) => ModelDetailShell(
        entry: NavigationEntry.function,
        title: vm.title,
        actions: [
          ModelDetailActions<ExpressionFunctionModel>(
            entry: NavigationEntry.function,
            selectModel: (state) => state.selectedExpressionFunction,
            nameSelector: (model) => model.uiName,
            keySelector: (model) => model.name,
            deleteTitle: context.l10n.dialog_expression_function_delete_title,
            removeAction: ExpressionFunctionRemoveAction.new,
            readNotes: (model) => model.comment,
          ),
        ],
        body: DefaultTabController(
          // Keyed by the requested tab: a new ?tab= on the same route has to
          // start a new controller, or the old tab would stay selected.
          key: ValueKey(requestedTab(context)),
          initialIndex: initialTabIndex(context, tabs),
          length: tabs.length,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ModelDetailTabBar(
                tabs: [
                  for (final tab in tabs) Tab(text: tab.label(context.l10n)),
                ],
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    ExpressionFunctionGeneralPage(),
                    ExpressionFunctionParametersPage(),
                    ExpressionFunctionTestPage(),
                    ExpressionFunctionInterfacePage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpressionFunctionDetailView extends Vm {
  _ExpressionFunctionDetailView({required this.title}) : super(equals: [title]);

  final String? title;
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
  );
}
