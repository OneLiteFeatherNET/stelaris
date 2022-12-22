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
import 'package:stelaris_ui/feature/dialogs/stepper/setup_stepper.dart';

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
        if (store.state.notifications.isEmpty) {
          store.dispatch(InitNotificationAction());
        }
      },
      converter: (store) {
        return store.state.notifications;
      },
      builder: (context, vm) {
        selectedItem.value ??= vm.first;
        return ModelContainerList<NotificationModel>(
          mapToDeleteDialog: (value) {
            return [
              const TextSpan(
                  text: "Will you delete ",
                  style: TextStyle(color: Colors.white)),
              TextSpan(
                  text: value.name ?? "Unknown",
                  style: const TextStyle(color: Colors.red))
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
                    child: Card(
                      child: SetupStepper<NotificationModel>(
                        finishCallback: (model) {
                          StoreProvider.dispatch(
                              context, InputNotificationAction(model));
                          Navigator.pop(context);
                          selectedItem.value = model;
                        },
                        buildModel: (String name, String description) {
                          return NotificationModel(name: name, frameType: FrameType.goal.value);
                        },
                      ),
                    ),
                  );
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
    switch (e) {
      case TabPages.general:
        return ValueListenableBuilder<NotificationModel?>(
            valueListenable: test,
            builder: (BuildContext context, NotificationModel? value,
                Widget? child) {
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
    return Stack(
      children: [
        Wrap(
          children: [
            createInputContainer("Name", model.name),
            createInputContainer("Material", model.material),
            createInputContainer("Title", model.title),
            DropDownCard<FrameType, NotificationModel>(
              currentValue: model,
              title: const Text("FrameType", textAlign: TextAlign.center),
              items: getItems(),
              valueUpdate: (FrameType? value) {},
              defaultValue: getDefaultValue,
            ),
            createInputContainer("Description", model.description),
          ],
        ),
        Positioned(
            bottom: 25,
            right: 25,
            child: FloatingActionButton.extended(
              heroTag: UniqueKey(),
              onPressed: () {},
              label: const Text("Save"),
              icon: const Icon(Icons.save),
            )
        )
      ],
    );
  }

  List<DropdownMenuItem<FrameType>>? getItems() {
    List<FrameType> values = FrameType.values;
    return List.generate(
        values.length,
        (index) => DropdownMenuItem(
              value: values[index],
              child: Text(values[index].value),
            ));
  }

  FrameType getDefaultValue(NotificationModel value) {
    return FrameType.values
        .firstWhere((element) => element.name == value.frameType);
  }
}
