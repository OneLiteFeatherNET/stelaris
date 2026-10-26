import 'package:dio/dio.dart';
import 'package:stelaris/api/api_client.dart';
import 'package:stelaris/api/model/asset_model.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Client API for the files a project stores as assets.
///
/// Errors are not converted here: a rejected upload throws a [DioException]
/// whose response carries the backend's problem detail, which the UI turns
/// into a `ProblemDetail` with `ProblemDetail.fromDioException`.
class AssetClientApi {
  final ApiClient apiClient;

  AssetClientApi({required this.apiClient});

  static const String _endpoint = 'asset';

  /// Fetches one page of the project's assets, optionally only of [kind].
  ///
  /// [page] is zero-based, as the backend expects.
  Future<PaginatedResult<AssetModel>> getPage(
    String projectId, {
    AssetKind? kind,
    int page = 0,
    int size = 50,
  }) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(
      path: '${baseUri.path}/project/$projectId/$_endpoint/',
      queryParameters: {
        if (kind != null) 'kind': kind.name,
        'page': page.toString(),
        'size': size.toString(),
      },
    );
    final result = await apiClient.dio.getUri(uri);
    return PaginatedResult.fromJson(
      result.data!,
      (json) => AssetModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Uploads [bytes] as a new asset of [projectId] under [key].
  ///
  /// The backend derives the kind from [fileName]'s extension and the content.
  Future<AssetModel> upload(
    String projectId, {
    required String key,
    required String fileName,
    required List<int> bytes,
  }) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(
      path: '${baseUri.path}/project/$projectId/$_endpoint',
    );
    final form = FormData.fromMap({
      'key': key,
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });
    final result = await apiClient.dio.postUri(uri, data: form);
    return AssetModel.fromJson(result.data as Map<String, dynamic>);
  }

  /// Downloads the stored bytes of the asset [assetId].
  Future<List<int>> content(String projectId, String assetId) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(
      path: '${baseUri.path}/project/$projectId/$_endpoint/$assetId/content',
    );
    final result = await apiClient.dio.getUri(
      uri,
      options: Options(responseType: ResponseType.bytes),
    );
    return result.data! as List<int>;
  }
}
