import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/model/notification_model.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/notification/notification_page.dart';

class NotificationVmFactory
    extends VmFactory<AppState, NotificationPage, NotificationViewModel> {
  NotificationVmFactory();

  @override
  NotificationViewModel fromStore() => NotificationViewModel(
    models: state.notifications.items,
    selected: state.selectedNotification,
    hasNextPage: state.notifications.hasNextPage,
    isLoadingMore: state.isLoadingMoreNotifications,
    currentItems: state.notifications.totalItems
  );
}

class NotificationViewModel extends Vm {
  final List<NotificationModel> models;
  final NotificationModel? selected;
  final int currentItems;
  final bool hasNextPage;
  final bool isLoadingMore;

  NotificationViewModel({
    required this.models,
    required this.selected,
    required this.hasNextPage,
    required this.isLoadingMore,
    required this.currentItems,
  }) : super(
         equals: [models, selected, currentItems, hasNextPage, isLoadingMore],
       );

  bool isSelectedItem(NotificationModel model) {
    if (selected == null) return false;

    final selectedModel = selected!;

    if (selectedModel.id != null && model.id != null) {
      return selectedModel.id == model.id;
    }
    return selectedModel.hashCode == model.hashCode;
  }
}
