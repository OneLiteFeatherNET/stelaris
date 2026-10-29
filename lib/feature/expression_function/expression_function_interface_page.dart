import 'package:async_redux/async_redux.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/expression_function/selected_expression_function_state.dart';
import 'package:stelaris/feature/base/edit_card/edit_section_heading.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The function's Interface tab: the Java source the backend generates from
/// the project's interface functions, read-only, with a button that copies it.
///
/// Only an interface has a place in that source, so a formula shows an empty
/// state instead. The source is the saved one: a change made on the General
/// tab shows here once it is saved and the tab is opened again.
class ExpressionFunctionInterfacePage extends StatelessWidget {
  const ExpressionFunctionInterfacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedExpressionFunctionView>(
      vm: () => SelectedExpressionFunctionState(),
      builder: (context, vm) {
        final l10n = context.l10n;
        if (vm.selected.kind != ExpressionFunctionKind.INTERFACE) {
          return EmptyDataWidget.full(
            header: l10n.expression_function_interface_formula_header,
            subHeader: l10n.expression_function_interface_formula_subheader,
            icon: Icons.integration_instructions_outlined,
          );
        }
        final projectId = vm.projectId;
        if (projectId == null) {
          return Center(
            child: Text(l10n.expression_function_interface_no_project),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: _InterfaceSource(projectId: projectId),
        );
      },
    );
  }
}

/// Loads the generated source of [projectId] once, when the tab opens.
class _InterfaceSource extends StatefulWidget {
  const _InterfaceSource({required this.projectId});

  final String projectId;

  @override
  State<_InterfaceSource> createState() => _InterfaceSourceState();
}

class _InterfaceSourceState extends State<_InterfaceSource> {
  late Future<ExpressionFunctionInterface> _source = _load();

  Future<ExpressionFunctionInterface> _load() =>
      ApiService().expressionFunctionApi.interface(widget.projectId);

  void _retry() => setState(() => _source = _load());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return FutureBuilder<ExpressionFunctionInterface>(
      future: _source,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final generated = snapshot.data;
        if (snapshot.hasError || generated == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.expression_function_interface_error,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _retry,
                  child: Text(l10n.expression_function_interface_retry),
                ),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: EditSectionHeading(
                    title: l10n.expression_function_interface_title,
                  ),
                ),
                IconButton(
                  tooltip: l10n.expression_function_interface_copy,
                  icon: const Icon(Icons.copy),
                  onPressed: () =>
                      Clipboard.setData(ClipboardData(text: generated.source)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Card.filled(
                clipBehavior: Clip.antiAlias,
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppShapes.medium),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SelectableText(
                      generated.source,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
