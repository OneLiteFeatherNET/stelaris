import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris_ui/api/api_client.dart';
import 'package:stelaris_ui/api/model/plugin_model.dart';

class PluginAPI {

  final ApiClient _apiClient;

  final StringToPlugin _formatter = const StringToPlugin();

  PluginAPI(this._apiClient);

  Future<PluginModel> getPlugin() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/plugin');
    final result = await _apiClient.dio.getUri(uri).then((value) => PluginModel.fromJson(value.data!));
    return result;
  }

  Future<PluginModel> addPlugin(PluginModel plugin) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/plugin/');
    final result = await _apiClient.dio.postUri(uri, data: plugin.toJson()).then((value) => PluginModel.fromJson(value.data!));
    return result;
  }

  Future<List<PluginModel>> getAllPlugins() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/plugin/getAll');
    final result = await _apiClient.dio.getUri(uri).then((value) => _formatter.fromJson(value.data!));
    return result;
  }

  Future<PluginModel> update(PluginModel model) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/plugin/update');
    final result = await _apiClient.dio.postUri(uri, data: model.toJson()).then((value) => PluginModel.fromJson(value.data!));
    return result;
  }
}

class StringToPlugin implements JsonConverter<List<PluginModel>, List<dynamic>> {

  const StringToPlugin();

  @override
  List<PluginModel> fromJson(List<dynamic> json) {
    return json.map((e) => PluginModel.fromJson(e)).toList();
  }

  @override
  List<dynamic> toJson(List<PluginModel> object) {
    throw UnimplementedError();
  }
}
