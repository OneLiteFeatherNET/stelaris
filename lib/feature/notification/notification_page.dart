import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:nil/nil.dart';
import 'package:stelaris_ui/api/model/notification_model.dart';
import 'package:stelaris_ui/api/state/actions/notification_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/api/tabs/tab_pages.dart';
import 'package:stelaris_ui/api/util/minecraft/frame_type.dart';
import 'package:stelaris_ui/feature/base/model_container_list.dart';
import 'package:stelaris_ui/feature/base/model_text.dart';
import 'package:stelaris_ui/feature/dialogs/setup_dialog.dart';
import 'package:stelaris_ui/feature/notification/notification_page_general.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';

class NotificationPage extends StatelessWidget {

  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, NotificationModel?>(
      converter: (store) => store.state.selectedNotification,
      builder: (context, vm) {
        return ModelContainerList<NotificationModel>(
          callFunction: (model) {
            StoreProvider.dispatch(context, SelectedNotificationAction(model));
          },
          converter: (store) => store.state.notifications,
          action: InitNotificationAction(),
          tabPages: (pages) {
            List<Tab> requiredTabs = List.from(pages, growable: true);
            requiredTabs.removeWhere((element) {
              var text = element.child as Text;
              return identical(text.data, TabPage.meta.content);
            });
            return requiredTabs;
          },
          mapToDeleteDialog: (value) {
            return [
              TextSpan(
                  text: context.l10n.delete_dialog_first_line,
                  style: whiteStyle),
              TextSpan(text: value.modelName ?? unknownEntry, style: redStyle),
              TextSpan(
                  text: context.l10n.delete_dialog_entry, style: whiteStyle),
            ];
          },
          mapToDeleteSuccessfully: (value) {
            StoreProvider.dispatch(context, RemoveNotificationAction(value));
            return true;
          },
          selectedItem: vm,
          page: _mapPageToWidget,
          mapToDataModelItem: (value) =>
              ModelText(displayName: value.modelName),
          openFunction: () {
            showDialog(
              context: context,
              useRootNavigator: false,
              builder: (BuildContext context) {
                return SetUpDialog<NotificationModel>(
                  buildModel: (name, description) {
                    return NotificationModel(
                      modelName: name,
                      frameType: FrameType.goal.value,
                    );
                  },
                  finishCallback: (model) {
                    StoreProvider.dispatch(
                      context,
                      NotificationAddAction(model),
                    );
                    Navigator.pop(context);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _mapPageToWidget(TabPage page, NotificationModel? model) {
    if (page != TabPage.general) return nil;
    if (model == null) return nil;
    return NotificationGeneralPage(model: model);
  }
}
