import 'package:stelaris/api/base_api.dart';
import 'package:stelaris/api/model/font/font_char_model.dart';
import 'package:stelaris/api/model/font_model.dart';

class FontAPI extends BaseApi<FontModel> {
  FontAPI({required super.apiClient})
    : super(
        endpoint: 'font',
        fromJson: (p0) => FontModel.fromJson(p0),
        toJson: (model) => model.toJson(),
      );

  /// Fetches the character set for a specific font by its ID.
  /// [id] is the unique identifier of the font.
  /// Returns a [FontCharModel] containing the character set.
  Future<FontCharModel> getChars(String id) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(path: '${baseUri.path}/$endpoint/chars/$id');
    final result = await apiClient.dio.getUri(uri);
    return FontCharModel.fromJson(result.data!);
  }
}
