import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:nil/nil.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/model/notification_model.dart';
import 'package:stelaris_ui/api/state/actions/notification_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/api/tabs/tab_pages.dart';
import 'package:stelaris_ui/api/util/minecraft/frame_type.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/feature/base/cards/dropdown_card.dart';
import 'package:stelaris_ui/feature/base/cards/text_input_card.dart';
import 'package:stelaris_ui/feature/base/model_container_list.dart';
import 'package:stelaris_ui/feature/dialogs/stepper/setup_stepper.dart';
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
                  text: context.l10n.delete_dialog_firstline, style: TextStyle(color: Colors.white)),
              TextSpan(
                  text: value.name ?? unknownEntry,
                  style: const TextStyle(color: Colors.red)),
              const TextSpan(
                  text: secondLine, style: TextStyle(color: Colors.white)),
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
                          ApiService().notificationAPI.addNotification(model);
                          StoreProvider.dispatch(
                              context, NotificationAddAction(model));

                          Navigator.pop(context);
                          selectedItem.value = model;
                        },
                        buildModel: (String name, String description) {
                          return NotificationModel(
                              name: name, frameType: FrameType.goal.value);
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
    return Text(model.name ?? unknownEntry);
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
            TextInputCard<String>(
                title: nameText,
                infoText: nameToolTip,
                currentValue: model.name ?? empty,
                valueUpdate: (value) {
                  if (value == model.name) return;
                  final oldModel = model;
                  final newEntry = oldModel.copyWith(name: value);
                  setState(() {
                    StoreProvider.dispatch(
                        context, UpdateNotificationAction(oldModel, newEntry));
                    selectedItem.value = newEntry;
                  });
                }),
            TextInputCard<String>(
                title: materialText,
                currentValue: model.material ?? empty,
                infoText: materialTooltip,
                valueUpdate: (value) {
                  if (value == model.material) return;
                  final oldModel = model;
                  final newEntry = oldModel.copyWith(material: value);
                  setState(() {
                    StoreProvider.dispatch(
                        context, UpdateNotificationAction(oldModel, newEntry));
                    selectedItem.value = newEntry;
                  });
                }),
            TextInputCard<String>(
                title: const Text("Title"),
                currentValue: model.title ?? empty,
                infoText: "Hier kann ich ein Mat setzen",
                valueUpdate: (value) {
                  if (value == model.title) return;
                  final oldModel = model;
                  final newEntry = oldModel.copyWith(title: value);
                  setState(() {
                    StoreProvider.dispatch(
                        context, UpdateNotificationAction(oldModel, newEntry));
                    selectedItem.value = newEntry;
                  });
                }),
            TextInputCard<String>(
                title: descriptionText,
                currentValue: model.description ?? empty,
                infoText: descriptionToolTip,
                valueUpdate: (value) {
                  if (value == model.description) return;
                  final oldModel = model;
                  final newEntry = oldModel.copyWith(description: value);
                  setState(() {
                    StoreProvider.dispatch(
                        context, UpdateNotificationAction(oldModel, newEntry));
                    selectedItem.value = newEntry;
                  });
                }),
            DropDownCard<FrameType, NotificationModel>(
              currentValue: model,
              title: const Text("FrameType", textAlign: TextAlign.center),
              items: getItems(),
              valueUpdate: (FrameType? value) {
                if (value == getDefaultValue(model)) return;
                final newEntry = model.copyWith(frameType: value?.value);
                setState(() {
                  StoreProvider.dispatch(
                      context, UpdateNotificationAction(model, newEntry));
                  selectedItem.value = newEntry;
                });
              },
              defaultValue: getDefaultValue,
            ),
          ],
        ),
        Positioned(
            bottom: 25,
            right: 25,
            child: FloatingActionButton.extended(
              heroTag: UniqueKey(),
              onPressed: () {
                ApiService().notificationAPI.update(model);
              },
              label: saveText,
              icon: saveIcon,
            ))
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
