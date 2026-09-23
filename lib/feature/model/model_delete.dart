import 'package:async_redux/async_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/unsaved_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/dialogs/model_delete_dialog.dart';

/// Asks to confirm deleting [model] by typing its [name], then deletes it.
///
/// The one delete flow for a whole model, shared by the detail page's header
/// and the command palette so the two cannot drift apart. With
/// [returnToList], a confirmed delete ends on [entry]'s list - for callers on
/// the deleted model's own detail page. Resolves to whether it was deleted.
Future<bool> confirmAndDeleteModel<E>(
  BuildContext context, {
  required NavigationEntry entry,
  required String title,
  required String name,
  required String namespacedKey,
  required E model,
  required ReduxAction<AppState> Function(E model) removeAction,
  String? warning,
  bool returnToList = false,
}) async {
  final bool? deleted = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => ModelDeleteDialog<E>(
      title: title,
      name: name,
      value: model,
      namespacedKey: namespacedKey,
      warning: warning,
      successfully: (value) {
        // Pending edits of a deleted model are moot - drop them so leaving
        // doesn't ask about them.
        context.dispatch(DiscardUnsavedChangesAction());
        context.dispatch(removeAction(value));
        return true;
      },
    ),
  );
  if (deleted == true && returnToList && context.mounted) {
    context.go(entry.route);
  }
  return deleted == true;
}
