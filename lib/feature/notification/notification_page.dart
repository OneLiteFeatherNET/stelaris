import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/notification_model.dart';
import 'package:stelaris_ui/api/state/actions/block_actions.dart';
import 'package:stelaris_ui/api/util/minecraft/frame_type.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/feature/base/model_container_list.dart';
import 'package:stelaris_ui/util/constants.dart';

import '../../api/state/app_state.dart';
import '../../api/tabs/tab_pages.dart';

class NotificationPage extends StatefulWidget {

  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NotificationPageState();
  }
}

class NotificationPageState extends State<NotificationPage> with BaseLayout {

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<NotificationModel>>(
      onInit: (store) {
        store.dispatch(InitBlockAction());
      },
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
          items: notifications,
          page: mapPageToWidget,
          mapToDataModelItem: mapDataToModelItem,
        );
      },
    );
  }

  Widget mapDataToModelItem(NotificationModel model) {
    return Text(model.name ?? "Test");
  }

  Widget mapPageToWidget<NotificationModel>(TabPages e, ValueNotifier<NotificationModel?> test) {
    switch(e) {
      case TabPages.general:
        return ValueListenableBuilder(valueListenable: test, builder: (BuildContext context, value, Widget? child) {
          return getGeneralContent(value);
        });
      case TabPages.additional:
        return const Text("Nothing to see here");
      case TabPages.meta:
        return const Text("Nothing to see here");
    }
  }

  Widget getGeneralContent(model) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, left: 5.0),
      child: Container(
        color: Colors.lightGreen,
        child: Wrap(
          children: [
            createInputContainer("Name", model?.name),
            createInputContainer("Material", model?.material),
            createInputContainer("Title", model?.title),
            createDropDownContainer(
                String, "FrameType", model?.frameType, defaultFrameType.value, getItems()),
            createInputContainer("Description", model?.description),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> getItems() {
    List<FrameType> values = FrameType.values;
    return List.generate(values.length, (index) =>
        DropdownMenuItem(
          value: values[index].value,
          child: Text(values[index].value),
        )
    );
  }
}