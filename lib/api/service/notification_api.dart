import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris_ui/api/ApiClient.dart';

import '../model/notification_model.dart';

class NotificationAPI {

  final ApiClient apiClient;

  final StringToNotifications _formatter = const StringToNotifications();

  NotificationAPI(this.apiClient);

  Future<NotificationModel> getNotification() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/api/notifications');
    final result = await apiClient.dio.getUri(uri).then((value) => NotificationModel.fromJson(value.data!));
    return result;
  }

  Future<NotificationModel> addNotification(NotificationModel notification) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/notification/');
    final result = await apiClient.dio.postUri(uri, data: notification).then((value) => NotificationModel.fromJson(value.data!));
    return result;
  }

  Future<List<NotificationModel>> getAllNotifications() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/notification/getAll');
    final result = await apiClient.dio.getUri(uri).then((value) => _formatter.fromJson(value.data!));
    return result;
  }
}

class StringToNotifications implements JsonConverter<List<NotificationModel>, List<dynamic>> {

  const StringToNotifications();

  @override
  List<NotificationModel> fromJson(List<dynamic> json) {
    return json.map((e) => NotificationModel.fromJson(e)).toList();
  }

  @override
  List<dynamic> toJson(List<NotificationModel> object) {
    throw UnimplementedError();
  }
}
