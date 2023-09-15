import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:nil/nil.dart';
import 'package:stelaris_ui/api/model/notification_model.dart';
import 'package:stelaris_ui/api/state/actions/notification_actions.dart';
import 'package:stelaris_ui/api/tabs/tab_pages.dart';
import 'package:stelaris_ui/api/util/minecraft/frame_type.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/feature/base/model_container_list.dart';
import 'package:stelaris_ui/feature/base/model_text.dart';
import 'package:stelaris_ui/feature/dialogs/setup_dialog.dart';
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
    return ModelContainerList<NotificationModel>(
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
              text: context.l10n.delete_dialog_first_line, style: whiteStyle),
          TextSpan(text: value.modelName ?? unknownEntry, style: redStyle),
          TextSpan(text: context.l10n.delete_dialog_entry, style: whiteStyle),
        ];
      },
      mapToDeleteSuccessfully: (value) {
        StoreProvider.dispatch(context, RemoveNotificationAction(value));
        return true;
      },
      selectedItem: selectedItem,
      page: mapPageToWidget,
      mapToDataModelItem: (value) => ModelText(displayName: value.modelName),
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
                selectedItem.value = model;
              },
            );
          },
        );
      },
    );
  }

  Widget mapPageToWidget(TabPage page, ValueNotifier<NotificationModel?> test) {
    if (page == TabPage.general) {
      return ValueListenableBuilder<NotificationModel?>(
        valueListenable: test,
        builder:
            (BuildContext context, NotificationModel? value, Widget? child) {
          if (value == null) return nil;
          return NotificationGeneralPage(
              model: value, selectedItem: selectedItem);
        },
      );
    }
    return nil;
  }
}
