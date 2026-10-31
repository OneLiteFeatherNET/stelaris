import 'package:dio/dio.dart';
import 'package:stelaris/api/api_client.dart';
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

  /// Uploads [bytes] as a new asset of [projectId] under [key], shown as
  /// [displayName].
  ///
  /// The backend derives the kind from [fileName]'s extension and the content.
  Future<AssetModel> upload(
    String projectId, {
    required String key,
    required String displayName,
    required String fileName,
    required List<int> bytes,
  }) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(
      path: '${baseUri.path}/project/$projectId/$_endpoint',
    );
    final form = FormData.fromMap({
      'key': key,
      'displayName': displayName,
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });
    final result = await apiClient.dio.postUri(uri, data: form);
    return AssetModel.fromJson(result.data as Map<String, dynamic>);
  }

  /// Replaces the stored file of [asset] by [bytes]; its key and name stay.
  ///
  /// The backend refuses a file of another kind than the asset's, and with
  /// 412 if the stored file is no longer the one of [asset]: the request
  /// sends its sha1 as If-Match, so a change by someone else is not
  /// overwritten unseen.
  Future<AssetModel> replaceContent(
    AssetModel asset, {
    required String fileName,
    required List<int> bytes,
  }) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(
      path:
          '${baseUri.path}/project/${asset.projectId}/$_endpoint/${asset.id}/content',
    );
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });
    final result = await apiClient.dio.postUri(
      uri,
      data: form,
      options: Options(headers: {'If-Match': '"${asset.sha1}"'}),
    );
    return AssetModel.fromJson(result.data as Map<String, dynamic>);
  }

  /// Fetches one page of the revisions of [asset], the newest first.
  ///
  /// [page] is zero-based, as the backend expects.
  Future<PaginatedResult<AssetRevisionModel>> revisions(
    AssetModel asset, {
    int page = 0,
    int size = 50,
  }) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(
      path:
          '${baseUri.path}/project/${asset.projectId}/$_endpoint/${asset.id}/revision',
      queryParameters: {'page': page.toString(), 'size': size.toString()},
    );
    final result = await apiClient.dio.getUri(uri);
    return PaginatedResult.fromJson(
      result.data!,
      (json) => AssetRevisionModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Downloads the stored bytes of the revision [revisionId] of [asset].
  Future<List<int>> revisionContent(AssetModel asset, String revisionId) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(
      path:
          '${baseUri.path}/project/${asset.projectId}/$_endpoint/${asset.id}/revision/$revisionId/content',
    );
    final result = await apiClient.dio.getUri(
      uri,
      options: Options(responseType: ResponseType.bytes),
    );
    return result.data! as List<int>;
  }

  /// Makes the revision [revisionId] the current file of [asset], as a new
  /// revision. Like [replaceContent] it sends the sha1 of [asset] as
  /// If-Match, so the backend answers 412 if the file changed meanwhile.
  Future<AssetModel> restoreRevision(
    AssetModel asset,
    String revisionId,
  ) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(
      path:
          '${baseUri.path}/project/${asset.projectId}/$_endpoint/${asset.id}/revision/$revisionId/restore',
    );
    final result = await apiClient.dio.postUri(
      uri,
      options: Options(headers: {'If-Match': '"${asset.sha1}"'}),
    );
    return AssetModel.fromJson(result.data as Map<String, dynamic>);
  }

  /// Stores [comment] as the internal notes of [asset], `null` clears them.
  Future<AssetModel> updateComment(AssetModel asset, String? comment) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(
      path: '${baseUri.path}/project/${asset.projectId}/$_endpoint/${asset.id}',
    );
    final result = await apiClient.dio.patchUri(
      uri,
      data: {'comment': comment},
    );
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
