import 'package:async_redux/async_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/unsaved_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/feature/base/unsaved/unsaved_changes_guard.dart';
import 'package:stelaris/feature/dialogs/model_delete_dialog.dart';
import 'package:stelaris/feature/dialogs/model_info_dialog.dart';
import 'package:stelaris/feature/model/model_page.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The Info / Delete / Save actions of a detail page's [PageHeader]. Opens
/// the same dialogs as a grid card's menu, so both places stay in sync.
///
/// The model is read from the store when an action is pressed (via
/// [selectModel]) rather than passed in, so the header doesn't rebuild on
/// every keystroke in the form below it.
class ModelDetailActions<E extends DataModel> extends StatelessWidget {
  const ModelDetailActions({
    required this.entry,
    required this.selectModel,
    required this.nameSelector,
    required this.keySelector,
    required this.deleteTitle,
    required this.removeAction,
    this.deleteWarning,
    super.key,
  });

  final NavigationEntry entry;
  final E? Function(AppState state) selectModel;
  final ModelNameSelector<E> nameSelector;
  final ModelKeySelector<E> keySelector;
  final String deleteTitle;
  final String? deleteWarning;
  final ReduxAction<AppState> Function(E model) removeAction;

  String _namespacedKey(AppState state, E model) =>
      '${state.selectedProject?.key ?? ''}:${keySelector(model)}';

  void _openInfo(BuildContext context) {
    final state = StoreProvider.state<AppState>(context);
    final model = selectModel(state);
    if (model == null) return;
    showDialog(
      context: context,
      builder: (context) => ModelInfoDialog(
        name: nameSelector(model),
        namespacedKey: _namespacedKey(state, model),
        id: model.id,
        creationDate: model.creationDate,
        modificationDate: model.modificationDate,
      ),
    );
  }

  Future<void> _openDelete(BuildContext context) async {
    final state = StoreProvider.state<AppState>(context);
    final model = selectModel(state);
    if (model == null) return;
    final deleted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => ModelDeleteDialog<E>(
        title: deleteTitle,
        name: nameSelector(model),
        value: model,
        namespacedKey: _namespacedKey(state, model),
        warning: deleteWarning,
        successfully: (value) {
          // Pending edits of a deleted model are moot — drop them so
          // leaving doesn't ask about them.
          context.dispatch(DiscardUnsavedChangesAction());
          context.dispatch(removeAction(value));
          return true;
        },
      ),
    );
    if (deleted == true && context.mounted) context.go(entry.route);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PageHeaderAction(
          icon: const Icon(Icons.info_outline),
          label: l10n.menu_item_info,
          onPressed: () => _openInfo(context),
        ),
        const SizedBox(width: 8),
        PageHeaderAction(
          icon: deleteIcon,
          label: l10n.button_delete,
          onPressed: () => _openDelete(context),
        ),
        const SizedBox(width: 8),
        DetailSaveAction(entry: entry),
      ],
    );
  }
}

/// Saves the selected model of [entry]; enabled only while it has unsaved
/// edits. Replaces the floating save button the detail tabs used to carry.
class DetailSaveAction extends StatefulWidget {
  const DetailSaveAction({required this.entry, super.key});

  final NavigationEntry entry;

  @override
  State<DetailSaveAction> createState() => _DetailSaveActionState();
}

class _DetailSaveActionState extends State<DetailSaveAction> {
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    final saved = await saveUnsavedChanges(context, widget.entry);
    if (!mounted) return;
    setState(() => _saving = false);
    if (saved) context.showSuccessSnackBar(context.l10n.feedback_save_success);
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, bool>(
      converter: (store) => store.state.unsavedChanges == widget.entry,
      builder: (context, hasUnsavedChanges) => PageHeaderAction(
        icon: saveIcon,
        label: context.l10n.button_save,
        primary: true,
        loading: _saving,
        onPressed: hasUnsavedChanges ? _save : null,
      ),
    );
  }
}
