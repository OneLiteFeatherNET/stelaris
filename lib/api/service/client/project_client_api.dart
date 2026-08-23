import 'package:stelaris/api/base_api.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Client API for interacting with project-related endpoints.
///
/// Extends [BaseApi] to provide standard CRUD operations for [Project] instances
/// and includes specific methods for project functionalities like fetching by key or ID,
/// and deleting all projects.
class ProjectClientApi extends BaseApi<Project> {
  /// Creates an instance of [ProjectClientApi].
  ///
  /// Requires an [apiClient] for making HTTP requests.
  /// The base endpoint for projects is set to 'project'.
  ProjectClientApi({required super.apiClient})
      : super(
          endpoint: 'project',
          fromJson: Project.fromJson,
          toJson: (p0) => p0.toJson(),
        );

  /// Retrieves a project by its unique ID.
  ///
  /// The request is made to `/project/{id}`.
  ///
  /// - [id]: The unique identifier (UUID) of the project.
  ///
  /// Returns a [Future] that completes with the retrieved [Project].
  Future<Project> getById(String id) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(
      path: '${baseUri.path}/$endpoint/$id',
    );
    final result = await apiClient.dio.getUri(uri);
    return fromJson(result.data as Map<String, dynamic>);
  }

  /// Retrieves a project by its unique key.
  ///
  /// The request is made to `/project/key/{key}`.
  ///
  /// - [key]: The unique key of the project.
  ///
  /// Returns a [Future] that completes with the retrieved [Project].
  Future<Project> getByKey(String key) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(
      path: '${baseUri.path}/$endpoint/key/$key',
    );
    final result = await apiClient.dio.getUri(uri);
    return fromJson(result.data as Map<String, dynamic>);
  }

  /// Deletes all projects from the database.
  ///
  /// The request is made to `/project/delete`.
  ///
  /// Returns a [Future] that completes with a [List<Project>] of deleted projects.
  Future<List<Project>> deleteAll() async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(
      path: '${baseUri.path}/$endpoint/delete',
    );
    final result = await apiClient.dio.deleteUri(uri);
    final rawList = result.data as List<dynamic>;
    return rawList
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
