import 'package:stelaris_ui/api/api_client.dart';
import 'package:stelaris_ui/api/client_api.dart';
import 'package:stelaris_ui/api/converter/ModeListConverter.dart';
import 'package:stelaris_ui/api/model/font_model.dart';

class FontAPI implements ClientAPI<FontModel> {

  final ApiClient _apiClient;
  final ModelListConverter<FontModel> _formatter = ModelListConverter((p0) => FontModel.fromJson(p0));

  FontAPI(this._apiClient);

  @override
  Future<FontModel> get() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/font');
    final result = await _apiClient.dio.getUri(uri).then((value) => FontModel.fromJson(value.data!));
    return result;
  }

  @override
  Future<FontModel> add(FontModel font) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/font');
    final result = await _apiClient.dio.postUri(uri, data: font.toJson()).then((value) => FontModel.fromJson(value.data!));
    return result;
  }

  @override
  Future<List<FontModel>> getAll() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/font/getAll');
    final result = await _apiClient.dio.getUri(uri).then((value) => _formatter.fromJson(value.data!));
    return result;
  }

  @override
  Future<FontModel> update(FontModel model) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/font/update');
    final result = await _apiClient.dio.postUri(uri, data: model.toJson()).then((value) => FontModel.fromJson(value.data!));
    return result;
  }

  @override
  Future<FontModel> remove(FontModel fontModel) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/font/remove/${fontModel.id}');
    final result = await _apiClient.dio.deleteUri(uri).then((value) => FontModel.fromJson(value.data!));
    return result;
  }
}
