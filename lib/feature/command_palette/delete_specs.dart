import 'package:async_redux/async_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/attribute_actions.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/actions/notification_actions.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/model/detail_tabs.dart';
import 'package:stelaris/feature/model/model_delete.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// How the palette deletes one kind of model: the same title, warning and
/// remove action the kind's pages pass to their delete dialog.
@immutable
class DeleteSpec<E extends DataModel> {
  const DeleteSpec({
    required this.entry,
    required this.title,
    required this.removeAction,
    required this.selected,
    required this.key,
    required this.name,
    this.warning,
  });

  final NavigationEntry entry;
  final String Function(AppLocalizations l10n) title;
  final String Function(AppLocalizations l10n)? warning;
  final ReduxAction<AppState> Function(E model) removeAction;

  /// The kind's selection, i.e. what its detail page shows.
  final E? Function(AppState state) selected;

  final String? Function(E model) key;

  /// What the confirmation asks the user to type.
  final String Function(E model) name;

  /// Confirms and deletes [model] through the shared flow. On [model]'s own
  /// detail page the flow ends on the list, as the page's button does.
  Future<bool> delete(BuildContext context, E model) {
    final AppState state = StoreProvider.backdoorInheritedWidget<AppState>(
      context,
    ).state;
    final AppLocalizations l10n = context.l10n;
    final bool onOwnDetail =
        GoRouter.of(context).state.matchedLocation ==
            detailLocation(entry.route) &&
        selected(state)?.id == model.id;
    return confirmAndDeleteModel<E>(
      context,
      entry: entry,
      title: title(l10n),
      warning: warning?.call(l10n),
      name: name(model),
      namespacedKey: '${state.selectedProject?.key ?? ''}:${key(model) ?? ''}',
      model: model,
      removeAction: removeAction,
      returnToList: onOwnDetail,
    );
  }
}

final DeleteSpec<ItemModel> itemDelete = DeleteSpec<ItemModel>(
  entry: NavigationEntry.items,
  title: (l10n) => l10n.dialog_item_delete_title,
  warning: (l10n) => l10n.delete_dialog_related_item,
  removeAction: ItemRemoveAction.new,
  selected: (state) => state.selectedItem,
  key: (model) => model.key,
  name: (model) => model.uiName,
);

final DeleteSpec<FontModel> fontDelete = DeleteSpec<FontModel>(
  entry: NavigationEntry.font,
  title: (l10n) => l10n.dialog_font_delete_title,
  warning: (l10n) => l10n.delete_dialog_related_font,
  removeAction: FontRemoveAction.new,
  selected: (state) => state.selectedFont,
  key: (model) => model.key,
  name: (model) => model.uiName,
);

final DeleteSpec<SoundEventModel> soundDelete = DeleteSpec<SoundEventModel>(
  entry: NavigationEntry.sound,
  title: (l10n) => l10n.dialog_sound_delete_title,
  warning: (l10n) => l10n.delete_dialog_related_sound,
  removeAction: SoundRemoveAction.new,
  selected: (state) => state.selectedSoundEvent,
  key: (model) => model.key,
  name: (model) => model.uiName,
);

final DeleteSpec<NotificationModel> notificationDelete =
    DeleteSpec<NotificationModel>(
      entry: NavigationEntry.notifications,
      title: (l10n) => l10n.dialog_notification_delete_title,
      removeAction: NotificationRemoveAction.new,
      selected: (state) => state.selectedNotification,
      key: (model) => model.key,
      name: (model) => model.uiName,
    );

final DeleteSpec<AttributeModel> attributeDelete = DeleteSpec<AttributeModel>(
  entry: NavigationEntry.attributes,
  title: (l10n) => l10n.dialog_attribute_delete_title,
  removeAction: AttributeRemoveAction.new,
  selected: (state) => state.selectedAttribute,
  key: (model) => model.key,
  name: (model) => model.uiName,
);
