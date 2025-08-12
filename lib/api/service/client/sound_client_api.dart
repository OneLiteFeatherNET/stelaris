import 'package:stelaris/api/base_api.dart';
import 'package:stelaris/api/model/sound/sound_event_model.dart';
import 'package:stelaris/api/model/sound/sound_file_source.dart';
import 'package:stelaris/api/paginated_result.dart';

/// Client API for interacting with sound event-related endpoints.
///
/// Extends [BaseApi] to provide CRUD operations for [SoundEventModel] instances
/// and includes specific methods for sound event functionalities like fetching
/// associated sound files.
class SoundClientApi extends BaseApi<SoundEventModel> {
  /// Creates an instance of [SoundClientApi].
  ///
  /// Requires an [apiClient] for making HTTP requests.
  /// The base endpoint for sound events is set to 'sound'.
  /// Serialization and deserialization for [SoundEventModel] are handled
  /// by [SoundEventModel.fromJson] and [SoundEventModel.toJson] respectively.
  SoundClientApi({required super.apiClient})
      : super(
    endpoint: 'sound',
    fromJson: SoundEventModel.fromJson,
    toJson: (p0) => p0.toJson(),
  );

  /// Fetches a paginated list of [SoundFileSource] objects associated with a specific sound event.
  ///
  /// The request is made to the `/sound/{id}/sources` endpoint.
  ///
  /// - [id]: The unique identifier of the sound event.
  /// - [page]: Optional. The page number to retrieve (defaults to 1).
  /// - [items]: Optional. The number of items per page (defaults to 20).
  ///
  /// Returns a [Future] that completes with a [PaginatedResult] containing
  /// a list of [SoundFileSource] and pagination details.
  Future<PaginatedResult<SoundFileSource>> getFiles(
      String id, [
        int page = 1,
        int items = 20,
      ]) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(
      path: '${baseUri.path}/$endpoint/$id/sources',
    );
    final result = await apiClient.dio.getUri(uri);
    return PaginatedResult.fromJson(
      result.data,
          (jsonSource) => SoundFileSource.fromJson(jsonSource as Map<String, dynamic>),
    );
  }
}
