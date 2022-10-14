import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris_ui/api/ApiClient.dart';

import '../model/notification_model.dart';

class NotificationAPI {

  final ApiClient apiClient;

  NotificationAPI(this.apiClient);

  Future<Notification> getNotification() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/api/notifications');
    final result = await apiClient.dio.getUri(uri).then((value) => Notification.fromJson(value.data!));
    return result;
  }

  Future<Notification> addNotification(Notification notification) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/notification/');
    final result = await apiClient.dio.postUri(uri, data: notification).then((value) => Notification.fromJson(value.data!));
    return result;
  }

  Future<List<Notification>> getAllNotifications() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/notification/getAll');
    final result = await apiClient.dio.getUri(uri).then((value) => const StringToNotifications().fromJson(value.data!));
    return result;
  }
}

class StringToNotifications implements JsonConverter<List<Notification>, List<dynamic>> {

  const StringToNotifications();

  @override
  List<Notification> fromJson(List<dynamic> json) {
    return json.map((e) => Notification.fromJson(e)).toList();
  }

  @override
  List<dynamic> toJson(List<Notification> object) {
    throw UnimplementedError();
  }
}
