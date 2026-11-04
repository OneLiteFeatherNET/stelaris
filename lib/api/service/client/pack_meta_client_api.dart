import 'package:stelaris/api/api_client.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Client API for the `pack.mcmeta` content of a project.
///
/// A project holds at most one [PackMeta] per [PackType], so every request
/// addresses it by its pack type and not by its id.
///
/// Errors are not converted here: a rejected request throws a `DioException`
/// whose response carries the backend's problem detail, which the UI turns
/// into a `ProblemDetail` with `ProblemDetail.fromDioException`.
class PackMetaClientApi {
  final ApiClient apiClient;

  PackMetaClientApi({required this.apiClient});

  static const String _endpoint = 'pack-meta';

  /// Fetches the pack metas of [projectId], at most one per [PackType].
  Future<List<PackMeta>> getAll(String projectId) async {
    final result = await apiClient.dio.getUri(_uri(projectId, '/'));
    return (result.data as List<dynamic>)
        .map((json) => PackMeta.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetches the pack meta of [projectId] for [packType].
  ///
  /// The backend answers 404 if the project has none of that type.
  Future<PackMeta> get(String projectId, PackType packType) async {
    final result = await apiClient.dio.getUri(
      _uri(projectId, '/${packTypePath(packType)}'),
    );
    return PackMeta.fromJson(result.data as Map<String, dynamic>);
  }

  /// Creates the pack meta of [projectId] for the pack type of [meta], or
  /// replaces the existing one.
  ///
  /// Only the content is sent: the backend takes the project and the pack
  /// type from the path and keeps id and dates itself.
  Future<PackMeta> put(String projectId, PackMeta meta) async {
    final result = await apiClient.dio.putUri(
      _uri(projectId, '/${packTypePath(meta.packType)}'),
      data: {
        'description': meta.description,
        'minFormatMajor': meta.minFormatMajor,
        'minFormatMinor': meta.minFormatMinor,
        'maxFormatMajor': meta.maxFormatMajor,
        'maxFormatMinor': meta.maxFormatMinor,
        'enabledFeatures': meta.enabledFeatures,
      },
    );
    return PackMeta.fromJson(result.data as Map<String, dynamic>);
  }

  /// Removes the pack meta of [projectId] for [packType] and returns it.
  Future<PackMeta> delete(String projectId, PackType packType) async {
    final result = await apiClient.dio.deleteUri(
      _uri(projectId, '/${packTypePath(packType)}'),
    );
    return PackMeta.fromJson(result.data as Map<String, dynamic>);
  }

  /// The path segment of [packType], the same value its JSON uses.
  static String packTypePath(PackType packType) => switch (packType) {
    PackType.data => 'DATA',
    PackType.resource => 'RESOURCE',
  };

  Uri _uri(String projectId, String suffix) {
    final baseUri = Uri.parse(apiClient.baseUrl);
    return baseUri.replace(
      path: '${baseUri.path}/project/$projectId/$_endpoint$suffix',
    );
  }
}
