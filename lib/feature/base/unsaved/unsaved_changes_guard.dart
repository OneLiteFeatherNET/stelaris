import 'package:async_redux/async_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/actions/notification_actions.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/state/actions/unsaved_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/feature/base/unsaved/detail_forms.dart';
import 'package:stelaris/util/l10n_ext.dart';

enum _UnsavedChangesChoice { save, discard, cancel }

/// The action that persists [entry]'s selected model, or null for sections
/// edited in a dialog (attributes) that never have pending edits.
ReduxAction<AppState>? saveActionFor(NavigationEntry entry) => switch (entry) {
  NavigationEntry.items => ItemDatabaseUpdate(),
  NavigationEntry.notifications => NotificationDatabaseUpdate(),
  NavigationEntry.font => FontDatabaseUpdate(),
  NavigationEntry.sound => SoundDatabaseUpdate(),
  NavigationEntry.attributes => null,
};

/// Validates the detail page's registered forms and saves [entry]'s
/// selected model. Returns true only if it was actually persisted; errors
/// are shown the same way the old floating save button showed them.
Future<bool> saveUnsavedChanges(
  BuildContext context,
  NavigationEntry entry,
) async {
  final action = saveActionFor(entry);
  if (action == null) return true;

  // The fields commit their value on blur. Unfocus and let that commit land
  // first, or the text still being typed wouldn't be part of the save.
  FocusManager.instance.primaryFocus?.unfocus();
  await WidgetsBinding.instance.endOfFrame;
  if (!context.mounted) return false;

  if (!DetailForms.validateAll()) return false;

  final status = await context.dispatchAndWait(action);
  if (!context.mounted) return false;
  if (status.isCompletedFailed) {
    final error = status.originalError;
    if (error != null) context.showErrorSnackBar(error);
    return false;
  }
  return status.isCompletedOk;
}

/// Asks what to do with unsaved edits before navigating away. Returns true
/// if navigation may proceed. Used by every exit of a detail page: the
/// header's back arrow, system back, the side bar, the AppBar search and
/// the project switch.
Future<bool> confirmLeaveIfDirty(BuildContext context) async {
  final entry = StoreProvider.state<AppState>(context).unsavedChanges;
  if (entry == null) return true;

  final choice = await showDialog<_UnsavedChangesChoice>(
    context: context,
    builder: (context) => const _UnsavedChangesDialog(),
  );
  if (!context.mounted) return false;

  switch (choice) {
    case _UnsavedChangesChoice.save:
      return saveUnsavedChanges(context, entry);
    case _UnsavedChangesChoice.discard:
      context.dispatch(DiscardUnsavedChangesAction());
      return true;
    case _UnsavedChangesChoice.cancel:
    case null:
      return false;
  }
}

/// The `onExit` of every detail route. Catches ways of leaving that no
/// widget sees — above all the browser's back button on the web, which
/// arrives as a new location and never consults [PopScope]. Exits that
/// already asked (and saved or discarded) find nothing unsaved and pass
/// straight through.
Future<bool> detailExitGuard(BuildContext context, GoRouterState state) =>
    confirmLeaveIfDirty(context);

class _UnsavedChangesDialog extends StatelessWidget {
  const _UnsavedChangesDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.unsaved_dialog_title),
      content: Text(l10n.unsaved_dialog_message),
      actions: [
        TextButton(
          key: const Key('unsaved_dialog_cancel'),
          onPressed: () =>
              Navigator.of(context).pop(_UnsavedChangesChoice.cancel),
          child: Text(l10n.button_cancel),
        ),
        TextButton(
          key: const Key('unsaved_dialog_discard'),
          onPressed: () =>
              Navigator.of(context).pop(_UnsavedChangesChoice.discard),
          child: Text(l10n.button_discard),
        ),
        FilledButton(
          key: const Key('unsaved_dialog_save'),
          onPressed: () => Navigator.of(context).pop(_UnsavedChangesChoice.save),
          child: Text(l10n.button_save),
        ),
      ],
    );
  }
}
