import 'package:stelaris/api/api_client.dart';
import 'package:stelaris/api/client_api.dart';
import 'package:stelaris/api/converter/model_list_converter.dart';
import 'package:stelaris/api/model/data_model.dart';

/// A generic base class for CRUD API services.
///
/// This class assumes that the API endpoints and request/response formats follow a specific and consistent pattern across all models using this base.
///
/// For example, it expects the following endpoint structure for each model type:
///   - GET    /<endpoint>
///   - POST   /<endpoint>
///   - GET    /<endpoint>/getAll
///   - POST   /<endpoint>/update
///   - DELETE /<endpoint>/remove/<id>
///
/// Only use this base class when your API strictly adheres to this pattern for all CRUD operations. If your endpoints or data formats differ, consider implementing a custom service instead.
///
/// [T] is the model type.
/// [fromJson] is a function that converts a [dynamic] to T.
/// [toJson] is a function that converts T to [Map<String, dynamic>].
class BaseApi<T extends DataModel> implements ClientAPI<T> {
  final ApiClient apiClient;
  final String endpoint;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;
  final ModelListConverter<T> _formatter;

  BaseApi({
    required this.apiClient,
    required this.endpoint,
    required this.fromJson,
    required this.toJson,
  }) : _formatter = ModelListConverter((p0) => fromJson(p0));

  @override
  Future<T> get() async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(path: '${baseUri.path}/$endpoint');
    final result = await apiClient.dio.getUri(uri);
    return fromJson(result.data!);
  }

  @override
  Future<T> add(T model) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(path: '${baseUri.path}/$endpoint');
    final result = await apiClient.dio.postUri(uri, data: toJson(model));
    return fromJson(result.data!);
  }

  @override
  Future<List<T>> getAll([int page = 1, int items = 20]) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(path: '${baseUri.path}/$endpoint/getAll');
    final result = await apiClient.dio.getUri(uri);
    return _formatter.fromJson(result.data!);
  }

  @override
  Future<T> update(T model) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(path: '${baseUri.path}/$endpoint/update');
    final result = await apiClient.dio.postUri(uri, data: toJson(model));
    return fromJson(result.data!);
  }

  @override
  Future<T> remove(T model) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(path: '${baseUri.path}/$endpoint/delete/${model.id}');
    final result = await apiClient.dio.deleteUri(uri);
    return fromJson(result.data!);
  }
}
