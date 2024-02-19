import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/notification_model.dart';
import 'package:stelaris_ui/api/state/actions/notification_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/api/util/minecraft/frame_type.dart';
import 'package:stelaris_ui/feature/base/base_model_view.dart';
import 'package:stelaris_ui/feature/base/model_text.dart';
import 'package:stelaris_ui/feature/dialogs/setup_dialog.dart';
import 'package:stelaris_ui/feature/notification/notification_page_general.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';

class NotificationPage extends StatelessWidget {

  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('NotificationPage.build');
    return StoreConnector<AppState, NotificationModel?>(
      converter: (store) => store.state.selectedNotification,
      builder: (context, vm) {
        return BaseModelView<NotificationModel>(
            action: InitNotificationAction(),
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
            selectedItem: vm,
            mapToDeleteDialog: (value) {
              return [
                TextSpan(
                    text: context.l10n.delete_dialog_first_line,
                    style: whiteStyle),
                TextSpan(
                  text: value.modelName ?? unknownEntry,
                  style: redStyle,
                ),
                TextSpan(
                  text: context.l10n.delete_dialog_entry,
                  style: whiteStyle,
                ),
              ];
            },
            mapToDeleteSuccessfully: (value) {
              StoreProvider.dispatch(context, RemoveNotificationAction(value));
              return true;
            },
            converter: (store) => store.state.notifications,
            callFunction: (model) => StoreProvider.dispatch(
                context, SelectedNotificationAction(model)),
            child: _mapPageToWidget(vm));
      },
    );
  }

  Widget? _mapPageToWidget(NotificationModel? model) {
    if (model == null) return null;
    return NotificationGeneralPage(model: model);
  }
}
