import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:nil/nil.dart';
import 'package:stelaris_ui/api/model/notification_model.dart';
import 'package:stelaris_ui/api/state/actions/notification_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/api/tabs/tab_pages.dart';
import 'package:stelaris_ui/api/util/minecraft/frame_type.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/feature/base/model_container_list.dart';
import 'package:stelaris_ui/feature/dialogs/stepper/setup_stepper.dart';
import 'package:stelaris_ui/feature/notification/notification_page_general.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NotificationPageState();
  }
}

class NotificationPageState extends State<NotificationPage> with BaseLayout {
  final ValueNotifier<NotificationModel?> selectedItem = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<NotificationModel>>(
      onInit: (store) {
        store.dispatch(InitNotificationAction());
      },
      converter: (store) {
        return store.state.notifications;
      },
      builder: (context, vm) {
        if (vm.isNotEmpty) {
          selectedItem.value ??= vm.first;
        }
        return ModelContainerList<NotificationModel>(
          mapToDeleteDialog: (value) {
            return [
              TextSpan(
                  text: context.l10n.delete_dialog_first_line,
                  style: whiteStyle),
              TextSpan(text: value.name ?? unknownEntry, style: redStyle),
              TextSpan(
                  text: context.l10n.delete_dialog_entry, style: whiteStyle),
            ];
          },
          mapToDeleteSuccessfully: (value) {
            StoreProvider.dispatch(context, RemoveNotificationAction(value));
            return true;
          },
          selectedItem: selectedItem,
          items: vm,
          page: mapPageToWidget,
          mapToDataModelItem: mapDataToModelItem,
          openFunction: () {
            showDialog(
              context: context,
              useRootNavigator: false,
              builder: (BuildContext context) {
                return Dialog(
                  child: SizedBox(
                    width: 500,
                    height: 350,
                    child: Card(
                      elevation: 0.8,
                      child: SetupStepper<NotificationModel>(
                        finishCallback: (model) {
                          StoreProvider.dispatch(
                              context, NotificationAddAction(model));

                          Navigator.pop(context);
                          selectedItem.value = model;
                        },
                        buildModel: (String name, String description) {
                          return NotificationModel(
                              modelName: name, frameType: FrameType.goal.value);
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget mapDataToModelItem(NotificationModel model) {
    return Text(
      model.modelName ?? unknownEntry,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget mapPageToWidget(TabPages e, ValueNotifier<NotificationModel?> test) {
    switch (e) {
      case TabPages.general:
        return ValueListenableBuilder<NotificationModel?>(
          valueListenable: test,
          builder: (BuildContext context, NotificationModel? value, Widget? child) {
            if (value == null) return nil;
            return NotificationGeneralPage(model: value, selectedItem: selectedItem);
          },
        );
      case TabPages.meta:
        return nil;
    }
  }
}
