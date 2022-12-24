import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris_ui/api/api_client.dart';
import 'package:stelaris_ui/api/model/font_model.dart';

class FontAPI {

  final ApiClient _apiClient;

  final StringToFont _formatter = const StringToFont();

  FontAPI(this._apiClient);

  Future<FontModel> getFont() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/api/font');
    final result = await _apiClient.dio.getUri(uri).then((value) => FontModel.fromJson(value.data!));
    return result;
  }

  Future<FontModel> addFont(FontModel font) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/font/');
    final result = await _apiClient.dio.postUri(uri, data: font).then((value) => FontModel.fromJson(value.data!));
    return result;
  }

  Future<List<FontModel>> getAllFonts() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/font/getAll');
    final result = await _apiClient.dio.getUri(uri).then((value) => _formatter.fromJson(value.data!));
    return result;
  }

  Future<FontModel> update(FontModel model) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/font/update');
    final result = await _apiClient.dio.postUri(uri, data: model.toJson()).then((value) => FontModel.fromJson(value.data!));
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
