import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/feature/dialogs/copy_model_dialog.dart';
import 'package:stelaris/feature/project/switch_to_project.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/copy_model_result.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// How a page's models are copied. Pages that pass one to [ModelPage] get a
/// "Copy" entry in each card's menu.
class ModelCopy<E extends DataModel> {
  const ModelCopy({
    required this.title,
    required this.action,
    this.relations = const [],
  });

  /// The dialog's title, e.g. "Copy item".
  final String Function(AppLocalizations l10n) title;

  /// The relations the model can bring along; none for plain models.
  final List<CopyRelation> relations;

  /// Builds the action that copies [model] as the dialog describes.
  final ReduxAction<AppState> Function(E model, CopyModelResult result) action;
}

final itemCopyRelations = [
  CopyRelation('LORE', (l10n) => l10n.copy_relation_lore),
  CopyRelation('FLAGS', (l10n) => l10n.copy_relation_flags),
  CopyRelation('ENCHANTMENTS', (l10n) => l10n.copy_relation_enchantments),
];

final soundCopyRelations = [
  CopyRelation('SOURCES', (l10n) => l10n.copy_relation_sources),
];

final fontCopyRelations = [
  CopyRelation('CHARS', (l10n) => l10n.copy_relation_chars),
];

/// Shows the copy dialog for [model] and reports how it went: a copy into
/// the open project just says so, one into another project offers to
/// switch there.
Future<void> openCopyModelDialog<E extends DataModel>(
  BuildContext context, {
  required E model,
  required ModelCopy<E> copy,
  required String name,
  required String key,
}) async {
  final state = StoreProvider.state<AppState>(context);
  final current = state.selectedProject;
  if (current?.id == null) return;
  final l10n = context.l10n;
  // The card behind [context] can be gone by the time the snackbar's button
  // is pressed; the root navigator outlives it and still sees the store.
  final appContext = Navigator.of(context, rootNavigator: true).context;

  final result = await showDialog<CopyModelResult>(
    context: context,
    builder: (dialogContext) => CopyModelDialog(
      title: copy.title(l10n),
      projects: state.projects,
      currentProject: current!,
      initialName: name,
      initialKey: key,
      relations: copy.relations,
      onSubmit: (result) async {
        // Without a wrapError on the store, a backend error is rethrown
        // rather than reported through the status.
        try {
          final status = await context.dispatchAndWait(
            copy.action(model, result),
          );
          return status.isCompletedFailed
              ? status.originalError ?? l10n.error_title
              : null;
        } catch (error) {
          return error;
        }
      },
    ),
  );
  if (result == null || !context.mounted) return;

  if (result.targetProjectId == current!.id) {
    context.showSuccessSnackBar(l10n.copy_success);
    return;
  }
  context.showSuccessSnackBar(
    l10n.copy_success_other_project(result.targetProject.displayName),
    duration: const Duration(seconds: 6),
    action: SnackBarAction(
      label: l10n.copy_switch_project,
      textColor: Colors.white,
      onPressed: () {
        if (!appContext.mounted) return;
        switchToProject(
          appContext,
          StoreProvider.state<AppState>(appContext).selectedProject,
          result.targetProject,
        );
      },
    ),
  );
}
