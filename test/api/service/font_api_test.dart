import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_client.dart';
import 'package:stelaris/api/service/font_api.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/recording_http_client_adapter.dart';

void main() {
  late ApiClient apiClient;
  late FontAPI fontApi;

  setUp(() {
    apiClient = ApiClient('http://backend.test/api');
    fontApi = FontAPI(apiClient: apiClient);
  });

  test('getChars requests the paginated chars sub-resource', () async {
    const dto = FontStringDTO(line: 'Hello', id: 'c1');
    final adapter = RecordingHttpClientAdapter({
      'items': [dto.toJson()],
      'totalItems': 1,
      'totalPages': 1,
      'currentPage': 1,
      'pageSize': 10,
    });
    apiClient.dio.httpClientAdapter = adapter;

    final result = await fontApi.getChars('font-1');

    expect(adapter.lastRequest!.method, 'GET');
    expect(adapter.lastRequest!.uri.path, '/api/font/chars/font-1');
    expect(adapter.lastRequest!.uri.queryParameters, {
      'page': '0',
      'size': '10',
    });
    expect(result.items.single, dto);
  });

  test('addFontEntry PUTs to the chars sub-resource', () async {
    const dto = FontStringDTO(line: 'New line');
    final adapter = RecordingHttpClientAdapter(dto.toJson());
    apiClient.dio.httpClientAdapter = adapter;

    final result = await fontApi.addFontEntry('font-1', dto);

    expect(adapter.lastRequest!.method, 'PUT');
    expect(adapter.lastRequest!.uri.path, '/api/font/chars/font-1');
    expect(adapter.lastRequest!.data, dto.toJson());
    expect(result, dto);
  });

  test('updateFontEntry POSTs to the chars sub-resource', () async {
    const dto = FontStringDTO(line: 'Updated line', id: 'c2');
    final adapter = RecordingHttpClientAdapter(dto.toJson());
    apiClient.dio.httpClientAdapter = adapter;

    final result = await fontApi.updateFontEntry('font-1', dto);

    expect(adapter.lastRequest!.method, 'POST');
    expect(adapter.lastRequest!.uri.path, '/api/font/chars/font-1');
    expect(result, dto);
  });

  test('deleteFontEntry DELETEs by font and entry id', () async {
    const dto = FontStringDTO(line: 'Gone line', id: 'c2');
    final adapter = RecordingHttpClientAdapter(dto.toJson());
    apiClient.dio.httpClientAdapter = adapter;

    final result = await fontApi.deleteFontEntry('font-1', dto);

    expect(adapter.lastRequest!.method, 'DELETE');
    expect(adapter.lastRequest!.uri.path, '/api/font/chars/font-1/c2');
    expect(result, dto);
  });

  group('Font CRUD operations', () {
    test('remove DELETEs with project-scoped path when projectId is present', () async {
      const font = FontModel(
        uiName: 'Test Font',
        id: 'font-1',
        projectId: 'project-123',
      );
      final adapter = RecordingHttpClientAdapter(font.toJson());
      apiClient.dio.httpClientAdapter = adapter;

      final result = await fontApi.remove(font);

      expect(adapter.lastRequest!.method, 'DELETE');
      expect(
        adapter.lastRequest!.uri.path,
        '/api/project/project-123/font/delete/font-1',
      );
      expect(result.projectId, 'project-123');
    });

    test('update POSTs with project-scoped path when projectId is present', () async {
      const font = FontModel(
        uiName: 'Updated Font',
        id: 'font-1',
        projectId: 'project-123',
      );
      final adapter = RecordingHttpClientAdapter(font.toJson());
      apiClient.dio.httpClientAdapter = adapter;

      final result = await fontApi.update(font);

      expect(adapter.lastRequest!.method, 'POST');
      expect(
        adapter.lastRequest!.uri.path,
        '/api/project/project-123/font/update',
      );
      expect(result.projectId, 'project-123');
    });

    test('getPage deserializes models preserving projectId', () async {
      final jsonResponse = {
        'items': [
          {
            'uiName': 'Font One',
            'id': 'f1',
            'projectId': 'project-123',
            'mapper': 'font',
            'ascent': 0,
            'height': 0,
          },
        ],
        'totalItems': 1,
        'totalPages': 1,
        'currentPage': 1,
        'pageSize': 10,
      };
      final adapter = RecordingHttpClientAdapter(jsonResponse);
      apiClient.dio.httpClientAdapter = adapter;

      final result = await fontApi.getPage(
        page: 1,
        size: 10,
        projectId: 'project-123',
      );

      expect(adapter.lastRequest!.method, 'GET');
      expect(adapter.lastRequest!.uri.path, '/api/project/project-123/font');
      expect(result.items.single.projectId, 'project-123');
      expect(result.items.single.id, 'f1');
    });
  });
}
