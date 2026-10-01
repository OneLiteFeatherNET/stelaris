import 'package:async_redux/async_redux.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/notification/notification_page.dart';

class NotificationVmFactory
    extends VmFactory<AppState, NotificationPage, NotificationViewModel> {
  NotificationVmFactory();

  @override
  NotificationViewModel fromStore() => NotificationViewModel(
    models: state.notifications.items,
    hasNextPage: state.notifications.hasNextPage,
    isLoadingMore: state.isLoadingMoreNotifications,
    currentItems: state.notifications.totalItems,
    projectKey: state.selectedProject!.key,
  );
}

class NotificationViewModel extends Vm {
  final List<NotificationModel> models;
  final int currentItems;
  final bool hasNextPage;
  final bool isLoadingMore;
  final String projectKey;

  NotificationViewModel({
    required this.models,
    required this.hasNextPage,
    required this.isLoadingMore,
    required this.currentItems,
    required this.projectKey,
  }) : super(
         equals: [
           models,
           currentItems,
           hasNextPage,
           isLoadingMore,
           projectKey,
         ],
       );
}
