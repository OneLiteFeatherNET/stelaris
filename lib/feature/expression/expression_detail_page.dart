import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/expression_model.dart';
import 'package:stelaris/api/state/actions/expression/expression_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/expression/expression_general_page.dart';
import 'package:stelaris/feature/expression/expression_test_page.dart';
import 'package:stelaris/feature/expression/expression_variables_page.dart';
import 'package:stelaris/feature/model/detail_tabs.dart';
import 'package:stelaris/feature/model/model_detail_actions.dart';
import 'package:stelaris/feature/model/model_detail_shell.dart';
import 'package:stelaris/feature/model/model_detail_tab_bar.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The detail view reached by tapping an expression in [ExpressionPage].
///
/// Shows the shared [ModelDetailShell] header with its actions, and a
/// `TabBar`/`TabBarView` below it. Each tab reads the selected expression from
/// Redux itself, see [ExpressionGeneralPage], [ExpressionVariablesPage] and
/// [ExpressionTestPage].
class ExpressionDetailPage extends StatelessWidget {
  const ExpressionDetailPage({super.key});

  /// The tabs in order. Their ids are what `?tab=` and the command palette
  /// refer to.
  static final List<DetailTab> tabs = [
    DetailTab('general', (l10n) => l10n.tab_general),
    DetailTab('variables', (l10n) => l10n.tab_variables),
    DetailTab('test', (l10n) => l10n.tab_test),
  ];

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ExpressionDetailView>(
      vm: () => _ExpressionDetailFactory(),
      onDispose: (store) =>
          store.dispatch(RemoveSelectedExpression(), notify: false),
      builder: (context, vm) => ModelDetailShell(
        entry: NavigationEntry.expression,
        title: vm.title,
        actions: [
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
