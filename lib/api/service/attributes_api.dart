import 'package:stelaris_ui/api/api_client.dart';
import 'package:stelaris_ui/api/converter/model_list_converter.dart';
import 'package:stelaris_ui/api/model/attribute_model.dart';

class AttributesAPI {

  final ApiClient _apiClient;
  final ModelListConverter<AttributeModel> _formatter = ModelListConverter((p0) => AttributeModel.fromJson(p0));

  AttributesAPI(this._apiClient);

  Future<AttributeModel> getAttribute() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/attribute');
    final result = await _apiClient.dio.getUri(uri).then((value) => AttributeModel.fromJson(value.data!));
    return result;
  }

  Future<AttributeModel> addAttribute(AttributeModel model) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/attribute');
    final result = await _apiClient.dio.postUri(uri, data: model.toJson()).then((value) => AttributeModel.fromJson(value.data!));
    return result;
  }

  Future<List<AttributeModel>> getAll() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/attribute/getAll');
    final result = await _apiClient.dio.getUri(uri).then((value) => _formatter.fromJson(value.data!));
    return result;
  }

  Future<AttributeModel> update(AttributeModel model) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/attribute/update');
    final result = await _apiClient.dio.postUri(uri, data: model.toJson()).then((value) => AttributeModel.fromJson(value.data!));
    return result;
  }

  Future<AttributeModel> remove(AttributeModel attributeModel) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/attribute/remove/${attributeModel.id}');
    final result = await _apiClient.dio.deleteUri(uri).then((value) => AttributeModel.fromJson(value.data!));
    return result;
  }

}
