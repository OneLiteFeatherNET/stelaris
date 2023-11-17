import 'package:stelaris_ui/api/api_client.dart';
import 'package:stelaris_ui/api/client_api.dart';
import 'package:stelaris_ui/api/converter/model_list_converter.dart';
import 'package:stelaris_ui/api/model/notification_model.dart';

class NotificationAPI implements ClientAPI<NotificationModel> {

  final ApiClient _apiClient;
  final ModelListConverter<NotificationModel> _formatter = ModelListConverter((dynamic p0) => NotificationModel.fromJson(p0));

  NotificationAPI(this._apiClient);

  @override
  Future<NotificationModel> get() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/notifications');
    final result = await _apiClient.dio.getUri(uri).then((value) => NotificationModel.fromJson(value.data!));
    return result;
  }

  @override
  Future<NotificationModel> add(NotificationModel notification) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/notification');
    final result = await _apiClient.dio.postUri(uri, data: notification.toJson()).then((value) => NotificationModel.fromJson(value.data!));
    return result;
  }

  @override
  Future<List<NotificationModel>> getAll() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/notification/getAll');
    final result = await _apiClient.dio.getUri(uri).then((value) => _formatter.fromJson(value.data!));
    return result;
  }

  @override
  Future<NotificationModel> update(NotificationModel model) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/notification/update');
    final result = await _apiClient.dio.postUri(uri, data: model.toJson()).then((value) => NotificationModel.fromJson(value.data!));
    return result;
  }

  @override
  Future<NotificationModel> remove(NotificationModel model) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/notification/remove/${model.id}');
    final result = await _apiClient.dio.deleteUri(uri).then((value) => NotificationModel.fromJson(value.data!));
    return result;
  }
}
