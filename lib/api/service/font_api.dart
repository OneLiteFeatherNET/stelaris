import 'package:stelaris/api/base_api.dart';
import 'package:stelaris/api/model/font/font_char_model.dart';
import 'package:stelaris/api/model/font/font_string_dto.dart';
import 'package:stelaris/api/model/font_model.dart';
import 'package:stelaris/api/paginated_result.dart';

/// Implementation of the [BaseApi] to handle different request for [FontModel] and [FontStringDTO] data.
class FontAPI extends BaseApi<FontModel> {
  FontAPI({required super.apiClient})
    : super(
        endpoint: 'font',
        fromJson: (p0) => FontModel.fromJson(p0),
        toJson: (model) => model.toJson(),
      );

  /// Fetches the character set for a specific font by its ID.
  /// [id] is the unique identifier of the font.
  /// [page] is the page number of the character set.
  /// [size] is the number of characters per page.
  /// Returns a [FontCharModel] containing the character set.
  Future<PaginatedResult<FontStringDTO>> getChars(
    String id, {
    int page = 1,
    int size = 10,
  }) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(
      path: '${baseUri.path}/$endpoint/chars/$id',
      queryParameters: {
        'page': (page - 1).toString(), // many backends use 0-based
        'size': size.toString(),
      },
    );
    final result = await apiClient.dio.getUri(uri);
    final data = result.data;

    return PaginatedResult.fromJson(data, (json) {
      final rawData = json as Map<String, dynamic>;
      return FontStringDTO.fromJson(rawData);
    });
  }

  /// Updates the character set for a specific font by its ID.
  /// [id] is the unique identifier of the font.
  /// [dto] is the updated character set.
  /// Returns a [FontStringDTO] containing the updated character set.
  Future<FontStringDTO> updateFontEntry(String id, FontStringDTO dto) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(path: '${baseUri.path}/$endpoint/chars/$id');
    final result = await apiClient.dio.postUri(uri, data: dto.toJson());
    return FontStringDTO.fromJson(result.data);
  }

  /// Deletes the character set for a specific font by its ID.
  /// [id] is the unique identifier of the font.
  /// [dto] is the character set to be deleted.
  /// Returns a [FontStringDTO] containing the deleted character set.
  Future<FontStringDTO> deleteFontEntry(String id, FontStringDTO dto) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(path: '${baseUri.path}/$endpoint/chars/$id');
    final result = await apiClient.dio.deleteUri(uri, data: dto.toJson());
    return FontStringDTO.fromJson(result.data);
  }
}
