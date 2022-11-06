import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris_ui/api/ApiClient.dart';
import 'package:stelaris_ui/api/model/font_model.dart';

class FontAPI {

  final ApiClient apiClient;

  FontAPI(this.apiClient);

  Future<FontModel> getFont() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/api/font');
    final result = await apiClient.dio.getUri(uri).then((value) => FontModel.fromJson(value.data!));
    return result;
  }

  Future<FontModel> addFont(FontModel font) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/font/');
    final result = await apiClient.dio.postUri(uri, data: font).then((value) => FontModel.fromJson(value.data!));
    return result;
  }

  Future<List<FontModel>> getAllFonts() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/font/getAll');
    final result = await apiClient.dio.getUri(uri).then((value) => const StringToFont().fromJson(value.data!));
    return result;
  }
}

class StringToFont implements JsonConverter<List<FontModel>, List<dynamic>> {

  const StringToFont();

  @override
  List<FontModel> fromJson(List<dynamic> json) {
    return json.map((e) => FontModel.fromJson(e)).toList();
  }

  @override
  List<dynamic> toJson(List<FontModel> object) {
    throw UnimplementedError();
  }
}
