import 'package:dio/dio.dart';
import 'package:stelaris/api/api_client.dart';
import 'package:stelaris/api/client_api.dart';
import 'package:stelaris/api/converter/model_list_converter.dart';
import 'package:stelaris/api/model/sound/sound_event_model.dart';

class SoundAPI implements ClientAPI<SoundEventModel> {
  final ApiClient _apiClient;
  final ModelListConverter<SoundEventModel> _formatter = ModelListConverter(
    (p0) => SoundEventModel.fromJson(p0),
  );

  SoundAPI(this._apiClient);

  @override
  Future<SoundEventModel> add(SoundEventModel model) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(
      queryParameters: queryParams,
      path: '${baseUri.path}/sound',
    );
    final result = await _apiClient.dio
        .postUri(uri, data: model.toJson())
        .then(_parseData);
    return result;
  }

  @override
  Future<SoundEventModel> get() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(
      queryParameters: queryParams,
      path: '${baseUri.path}/sound',
    );
    final result = await _apiClient.dio
        .getUri(uri)
        .then(_parseData);
    return result;
  }

  @override
  Future<List<SoundEventModel>> getAll([int page = 1, int items = 20]) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(
      queryParameters: queryParams,
      path: '${baseUri.path}/sound/getAll',
    );
    final result = await _apiClient.dio
        .getUri(uri)
        .then((value) => _formatter.fromJson(value.data!));
    return result;
  }

  @override
  Future<SoundEventModel> remove(SoundEventModel model) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/sound/delete/${model.id}');
    final result = await _apiClient.dio.deleteUri(uri).then(_parseData);
    return result;
  }

  @override
  Future<SoundEventModel> update(SoundEventModel model) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(
      queryParameters: queryParams,
      path: '${baseUri.path}/sound/update',
    );
    final result = await _apiClient.dio
        .postUri(uri, data: model.toJson())
        .then(_parseData);
    return result;
  }

  /// Parses the response data into a [SoundEventModel].
  SoundEventModel _parseData(Response<dynamic> response) {
    return SoundEventModel.fromJson(response.data!);
  }
}
