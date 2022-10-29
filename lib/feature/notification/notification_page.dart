import 'package:async_redux/async_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:stelaris_ui/api/model/notification_model.dart';
import 'package:stelaris_ui/api/state/actions/block_actions.dart';

import '../../api/state/app_state.dart';

class NotificationList extends StatefulWidget {

  const NotificationList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NotificationListState();
  }
}

class NotificationListState extends State<NotificationList> {

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
        var notifications = vm.isNotEmpty
            ? vm.map((e) => e.name ?? 'X').toList()
            : List<String>.generate(1, (index) => "1");
        return Container(

        );
      },
    );
  }
}