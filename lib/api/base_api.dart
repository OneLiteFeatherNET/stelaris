import 'package:stelaris/api/api_client.dart';
import 'package:stelaris/api/client_api.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// A generic base class for CRUD API services.
///
/// This class assumes that the API endpoints and request/response formats follow a specific and consistent pattern across all models using this base.
///
/// For example, it expects the following endpoint structure for each model type:
///   - GET    `/endpoint`
///   - POST   `/endpoint`
///   - GET    `/endpoint/all`
///   - POST   `/endpoint/update`
///   - DELETE `/endpoint/delete/{id}`
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

  BaseApi({
    required this.apiClient,
    required this.endpoint,
    required this.fromJson,
    required this.toJson,
  });

  String _buildPath({String? projectId, String? suffix}) {
    final base = projectId != null && projectId.isNotEmpty
        ? 'project/$projectId/$endpoint'
        : endpoint;
    return suffix != null ? '$base/$suffix' : base;
  }

  String? _extractProjectId(T model) {
    try {
      final dynamic m = model;
      final dynamic pid = m.projectId;
      if (pid is String && pid.isNotEmpty) {
        return pid;
      }
    } catch (_) {}
    return null;
  }

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
    final projectId = _extractProjectId(model);
    final path = _buildPath(projectId: projectId);
    final uri = baseUri.replace(path: '${baseUri.path}/$path');
    final result = await apiClient.dio.postUri(uri, data: toJson(model));
    return fromJson(result.data!);
  }

  @override
  Future<T> update(T model) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final projectId = _extractProjectId(model);
    final path = _buildPath(projectId: projectId, suffix: 'update');
    final uri = baseUri.replace(path: '${baseUri.path}/$path');
    final result = await apiClient.dio.postUri(uri, data: toJson(model));
    return fromJson(result.data!);
  }

  @override
  Future<T> remove(T model) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final projectId = _extractProjectId(model);
    final path = _buildPath(projectId: projectId, suffix: 'delete/${model.id}');
    final uri = baseUri.replace(
      path: '${baseUri.path}/$path',
    );
    final result = await apiClient.dio.deleteUri(uri);
    return fromJson(result.data!);
  }

  @override
  Future<PaginatedResult<T>> getPage({
    int page = 1,
    int size = 10,
    String? projectId,
  }) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final path = _buildPath(projectId: projectId);
    final uri = baseUri.replace(
      path: '${baseUri.path}/$path',
      queryParameters: {
        'page': (page - 1).toString(), // many backends use 0-based
        'size': size.toString(),
      },
    );
    final result = await apiClient.dio.getUri(uri);
    final data = result.data;
    return PaginatedResult.fromJson(
      data,
      (json) => fromJson(json as Map<String, dynamic>),
    );
  }
}
