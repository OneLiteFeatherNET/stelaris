import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris_ui/api/ApiClient.dart';
import 'package:stelaris_ui/api/model/plugin_model.dart';

class PluginAPI {

  final ApiClient apiClient;

  PluginAPI(this.apiClient);

  Future<Plugin> getPlugin() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}api/plugin');
    final result = await apiClient.dio.getUri(uri).then((value) => Plugin.fromJson(value.data!));
    return result;
  }

  Future<Plugin> addPlugin(Plugin plugin) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/plugin/');
    final result = await apiClient.dio.postUri(uri, data: plugin).then((value) => Plugin.fromJson(value.data!));
    return result;
  }

  Future<List<Plugin>> getAllFonts() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/plugin/getAll');
    final result = await apiClient.dio.getUri(uri).then((value) => const StringToPlugin().fromJson(value.data!));
    return result;
  }
}

class StringToPlugin implements JsonConverter<List<Plugin>, List<dynamic>> {

  const StringToPlugin();

  @override
  List<Plugin> fromJson(List<dynamic> json) {
    return json.map((e) => Plugin.fromJson(e)).toList();
  }

  @override
  List<dynamic> toJson(List<Plugin> object) {
    throw UnimplementedError();
  }
}
