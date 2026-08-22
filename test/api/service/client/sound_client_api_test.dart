import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_client.dart';
import 'package:stelaris/api/service/client/sound_client_api.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/recording_http_client_adapter.dart';

void main() {
  late ApiClient apiClient;
  late SoundClientApi soundApi;

  setUp(() {
    apiClient = ApiClient('http://backend.test/api');
    soundApi = SoundClientApi(apiClient: apiClient);
  });

  const file = SoundFileSource(
    name: 'hit.ogg',
    volume: 1,
    pitch: 1,
    attenuationDistance: 16,
    preload: false,
    type: 'sound',
    weight: 1,
    id: 'f1',
  );

  test('getFiles requests the paginated sources sub-resource', () async {
    final adapter = RecordingHttpClientAdapter({
      'items': [file.toJson()],
      'totalItems': 1,
      'totalPages': 1,
      'currentPage': 1,
      'pageSize': 20,
    });
    apiClient.dio.httpClientAdapter = adapter;

    final result = await soundApi.getFiles('sound-1');

    expect(adapter.lastRequest!.method, 'GET');
    expect(adapter.lastRequest!.uri.path, '/api/sound/sound-1/sources');
    expect(adapter.lastRequest!.uri.queryParameters, {
      'page': '0',
      'size': '20',
    });
    expect(result.items.single, file);
  });

  test('linkFile POSTs to the sources sub-resource', () async {
    final adapter = RecordingHttpClientAdapter(file.toJson());
    apiClient.dio.httpClientAdapter = adapter;

    final result = await soundApi.linkFile('sound-1', file);

    expect(adapter.lastRequest!.method, 'POST');
    expect(adapter.lastRequest!.uri.path, '/api/sound/sound-1/sources');
    expect(adapter.lastRequest!.data, file.toJson());
    expect(result, file);
  });

  test('updateFile POSTs to the sources/update sub-resource', () async {
    final adapter = RecordingHttpClientAdapter(file.toJson());
    apiClient.dio.httpClientAdapter = adapter;

    final result = await soundApi.updateFile('sound-1', file);

    expect(adapter.lastRequest!.method, 'POST');
    expect(
      adapter.lastRequest!.uri.path,
      '/api/sound/sound-1/sources/update',
    );
    expect(result, file);
  });

  test('deleteFile DELETEs by sound and file id', () async {
    final adapter = RecordingHttpClientAdapter(file.toJson());
    apiClient.dio.httpClientAdapter = adapter;

    final result = await soundApi.deleteFile('sound-1', file);

    expect(adapter.lastRequest!.method, 'DELETE');
    expect(
      adapter.lastRequest!.uri.path,
      '/api/sound/sound-1/sources/delete/f1',
    );
    expect(result, file);
  });
}
