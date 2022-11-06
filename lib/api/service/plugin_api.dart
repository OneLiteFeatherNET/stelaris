import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris_ui/api/ApiClient.dart';
import 'package:stelaris_ui/api/model/plugin_model.dart';

class PluginAPI {

  final ApiClient apiClient;

  PluginAPI(this.apiClient);

  Future<PluginModel> getPlugin() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}api/plugin');
    final result = await apiClient.dio.getUri(uri).then((value) => PluginModel.fromJson(value.data!));
    return result;
  }

  Future<PluginModel> addPlugin(PluginModel plugin) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/plugin/');
    final result = await apiClient.dio.postUri(uri, data: plugin).then((value) => PluginModel.fromJson(value.data!));
    return result;
  }

  Future<List<PluginModel>> getAllPlugins() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/plugin/getAll');
    final result = await apiClient.dio.getUri(uri).then((value) => const StringToPlugin().fromJson(value.data!));
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
