import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/attribute_actions.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/actions/notification_actions.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/dialogs/model_create_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Opens the create dialog for [entry]'s kind of model - the one its list's
/// Add button shows - and adds what is submitted to [projectKey]'s project.
///
/// Resolves to whether a model was submitted, so a caller elsewhere in the
/// app can follow up, e.g. by showing the list it went into.
Future<bool> openModelCreateDialog(
  BuildContext context,
  NavigationEntry entry,
  String projectKey,
) async {
  final bool? created = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      final AppLocalizations l10n = context.l10n;
      return ModelCreateDialog(
        title: switch (entry) {
          NavigationEntry.items => l10n.dialog_item_create,
          NavigationEntry.font => l10n.dialog_font_create_title,
          NavigationEntry.sound => l10n.dialog_sound_create,
          NavigationEntry.notifications => l10n.dialog_notification_create,
          NavigationEntry.attributes => l10n.dialog_attribute_create,
        },
        projectNamespace: projectKey,
        onSubmit: (name, key) {
          switch (entry) {
            case NavigationEntry.items:
              context.dispatch(
                ItemAddAction(ItemModel(uiName: name, key: key)),
              );
            case NavigationEntry.font:
              context.dispatch(
                FontAddAction(FontModel(uiName: name, key: key)),
              );
            case NavigationEntry.sound:
              context.dispatch(
                SoundAddAction(SoundEventModel(uiName: name, key: key)),
              );
            case NavigationEntry.notifications:
              context.dispatchAndWait(
                NotificationAddAction(
                  NotificationModel(uiName: name, key: key),
                ),
              );
            case NavigationEntry.attributes:
              context.dispatchAndWait(
                AttributeAddAction(AttributeModel(uiName: name, key: key)),
              );
          }
          Navigator.pop(context, true);
        },
      );
    },
  );
  return created ?? false;
}
