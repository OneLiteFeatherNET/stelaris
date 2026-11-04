import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_client.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/api/service/client/pack_meta_client_api.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';
import '../../../support/recording_http_client_adapter.dart';

Map<String, dynamic> _packMetaJson({
  String packType = 'RESOURCE',
  Object? maxFormatMinor,
}) => {
  'id': 'pm-1',
  'projectId': 'p-1',
  'packType': packType,
  'description': '{"text":"Vulpes"}',
  'minFormatMajor': 64,
  'minFormatMinor': 0,
  'maxFormatMajor': 69,
  'maxFormatMinor': maxFormatMinor,
  'enabledFeatures': ['minecraft:trade_rebalance'],
  'creationDate': '2026-11-03T12:00:00Z',
  'modificationDate': '2026-11-03T12:30:00Z',
};

void main() {
  late ApiClient apiClient;
  late PackMetaClientApi packMetaApi;

  setUp(() {
    apiClient = ApiClient('http://backend.test/api');
    packMetaApi = PackMetaClientApi(apiClient: apiClient);
  });

  group('getAll', () {
    test('GETs the pack meta collection of the project', () async {
      final adapter = RecordingHttpClientAdapter([
        _packMetaJson(packType: 'DATA'),
        _packMetaJson(),
      ]);
      apiClient.dio.httpClientAdapter = adapter;

      final result = await packMetaApi.getAll('p-1');

      expect(adapter.lastRequest!.method, 'GET');
      expect(adapter.lastRequest!.uri.path, '/api/project/p-1/pack-meta/');
      expect(result.map((meta) => meta.packType), [
        PackType.data,
        PackType.resource,
      ]);
    });

    test('returns an empty list for a project without pack metas', () async {
      apiClient.dio.httpClientAdapter = RecordingHttpClientAdapter(<Object>[]);

      expect(await packMetaApi.getAll('p-1'), isEmpty);
    });
  });

  group('get', () {
    test('GETs the pack meta by its pack type', () async {
      final adapter = RecordingHttpClientAdapter(_packMetaJson());
      apiClient.dio.httpClientAdapter = adapter;

      final result = await packMetaApi.get('p-1', PackType.resource);

      expect(adapter.lastRequest!.method, 'GET');
      expect(
        adapter.lastRequest!.uri.path,
        '/api/project/p-1/pack-meta/RESOURCE',
      );
      expect(result.description, '{"text":"Vulpes"}');
      expect(result.maxFormatMinor, isNull);
      expect(result.enabledFeatures, ['minecraft:trade_rebalance']);
    });

    test('a 404 surfaces as a ProblemDetail', () async {
      apiClient.dio.httpClientAdapter = FakeHttpClientAdapter.json({
        'title': 'Not Found',
        'status': 404,
        'detail': 'The project has no pack meta of that type.',
      }, statusCode: 404);

      DioException? error;
      try {
        await packMetaApi.get('p-1', PackType.data);
      } on DioException catch (e) {
        error = e;
      }

      expect(error, isNotNull, reason: 'a 404 must throw');
      expect(ProblemDetail.fromDioException(error!).status, 404);
    });
  });

  group('put', () {
    test('PUTs only the content to the path of its pack type', () async {
      final adapter = RecordingHttpClientAdapter(
        _packMetaJson(packType: 'DATA', maxFormatMinor: 2),
      );
      apiClient.dio.httpClientAdapter = adapter;

      final result = await packMetaApi.put(
        'p-1',
        const PackMeta(
          id: 'pm-1',
          projectId: 'p-1',
          packType: PackType.data,
          description: '{"text":"Vulpes"}',
          minFormatMajor: 64,
          maxFormatMajor: 69,
          maxFormatMinor: 2,
          enabledFeatures: ['minecraft:trade_rebalance'],
        ),
      );

      final request = adapter.lastRequest!;
      expect(request.method, 'PUT');
      expect(request.uri.path, '/api/project/p-1/pack-meta/DATA');
      expect(request.data, {
        'description': '{"text":"Vulpes"}',
        'minFormatMajor': 64,
        'minFormatMinor': 0,
        'maxFormatMajor': 69,
        'maxFormatMinor': 2,
        'enabledFeatures': ['minecraft:trade_rebalance'],
      });
      expect(result.packType, PackType.data);
      expect(result.maxFormatMinor, 2);
    });

    test('sends a null maximum minor format for any minor version', () async {
      final adapter = RecordingHttpClientAdapter(_packMetaJson());
      apiClient.dio.httpClientAdapter = adapter;

      await packMetaApi.put(
        'p-1',
        const PackMeta(
          packType: PackType.resource,
          description: '{"text":"Vulpes"}',
          minFormatMajor: 64,
          maxFormatMajor: 69,
        ),
      );

      final body = adapter.lastRequest!.data as Map<String, dynamic>;
      expect(body.containsKey('maxFormatMinor'), isTrue);
      expect(body['maxFormatMinor'], isNull);
      expect(body['enabledFeatures'], isEmpty);
    });

    test('a 400 surfaces as a ProblemDetail', () async {
      apiClient.dio.httpClientAdapter = FakeHttpClientAdapter.json({
        'title': 'Bad Request',
        'status': 400,
        'detail': 'The format range is inverted.',
      }, statusCode: 400);

      DioException? error;
      try {
        await packMetaApi.put(
          'p-1',
          const PackMeta(
            packType: PackType.resource,
            description: '{"text":"Vulpes"}',
            minFormatMajor: 69,
            maxFormatMajor: 64,
          ),
        );
      } on DioException catch (e) {
        error = e;
      }

      expect(error, isNotNull, reason: 'a 400 must throw');
      expect(ProblemDetail.fromDioException(error!).status, 400);
    });
  });

  group('delete', () {
    test('DELETEs the pack meta by its pack type', () async {
      final adapter = RecordingHttpClientAdapter(_packMetaJson());
      apiClient.dio.httpClientAdapter = adapter;

      final result = await packMetaApi.delete('p-1', PackType.resource);

      expect(adapter.lastRequest!.method, 'DELETE');
      expect(
        adapter.lastRequest!.uri.path,
        '/api/project/p-1/pack-meta/RESOURCE',
      );
      expect(result.id, 'pm-1');
    });
  });

  test('the pack type path matches the JSON value of the pack type', () {
    for (final packType in PackType.values) {
      final json = PackMeta(
        packType: packType,
        description: '{}',
        minFormatMajor: 1,
        maxFormatMajor: 1,
      ).toJson();
      expect(PackMetaClientApi.packTypePath(packType), json['packType']);
    }
  });
}
