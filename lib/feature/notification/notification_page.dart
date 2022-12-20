import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:nil/nil.dart';
import 'package:stelaris_ui/api/model/notification_model.dart';
import 'package:stelaris_ui/api/state/actions/notification_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/api/tabs/tab_pages.dart';
import 'package:stelaris_ui/api/util/minecraft/frame_type.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/feature/base/cards/dropdown_card.dart';
import 'package:stelaris_ui/feature/base/model_container_list.dart';
import 'package:stelaris_ui/feature/dialogs/stepper/notification_stepper.dart';

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
      converter: (store) {
        return store.state.notifications;
      },
      builder: (context, vm) {
        var fallBackModel = NotificationModel(
          material: "Holz",
          generator: "NotificationGenerator",
          name: "Test",
          title: "Test Title",
          description: "Lol",
          frameType: FrameType.challenge.name
        );
        var secondModel = NotificationModel(
            material: "Stein",
            generator: "NotificationGenerator",
            name: "Second",
            title: "Test Title",
            description: "Hui",
            frameType: FrameType.goal.name
        );
        List<NotificationModel> notifications = vm.isNotEmpty ? vm : [fallBackModel, secondModel];
        return ModelContainerList<NotificationModel>(
          mapToDeleteDialog: (value) {
            return [];
          },
          mapToDeleteSuccessfully: (value) => true,
          selectedItem: selectedItem,
          items: notifications,
          page: mapPageToWidget,
          mapToDataModelItem: mapDataToModelItem,
          openFunction: () {
            showDialog(
                context: context,
                useRootNavigator: false,
                builder: (BuildContext context) {
                  return NotificationStepper(finishStepper: (model) {
                    StoreProvider.dispatch(context, InputNotificationAction());
                    Navigator.pop(context);
                  });
                });
          },
        );
      },
    );
  }

  Widget mapDataToModelItem(NotificationModel model) {
    return Text(model.name ?? "Test");
  }

  Widget mapPageToWidget(TabPages e, ValueNotifier<NotificationModel?> test) {
    switch(e) {
      case TabPages.general:
        return ValueListenableBuilder<NotificationModel?>(valueListenable: test, builder: (BuildContext context, NotificationModel? value, Widget? child) {
          return getGeneralContent(value);
        });
      case TabPages.meta:
        return nil;
    }
  }

  Widget getGeneralContent(NotificationModel? model) {
    if (model == null) {
      return nil;
    }
    return Wrap(
      children: [
        createInputContainer("Name", model.name),
        createInputContainer("Material", model.material),
        createInputContainer("Title", model.title),
        DropDownCard<FrameType, NotificationModel>(
            currentValue: model,
            title: const Text("FrameType", textAlign: TextAlign.center),
            items: getItems(),
            valueUpdate: (FrameType? value) {
            },
          defaultValue: getDefaultValue,
        ),
        createInputContainer("Description", model.description),
      ],
    );
  }

  List<DropdownMenuItem<FrameType>>? getItems() {
    List<FrameType> values = FrameType.values;
    return List.generate(values.length, (index) =>
        DropdownMenuItem(
          value: values[index],
          child: Text(values[index].value),
        )
    );
  }



  FrameType getDefaultValue(NotificationModel value) {
    return FrameType.values.firstWhere((element) => element.name == value.frameType);
  }
}