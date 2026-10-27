import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_client.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/api/service/client/asset_client_api.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/fake_http_client_adapter.dart';
import '../../support/recording_http_client_adapter.dart';

Map<String, dynamic> _assetJson({String id = 'a-1', String kind = 'MODEL'}) => {
  'id': id,
  'projectId': 'p-1',
  'key': 'vulpes:item/ruby',
  'kind': kind,
  'fileName': 'ruby.json',
  'contentType': 'application/json',
  'size': 512,
  'sha1': 'bbbb',
  'derivedAssetIds': <String>[],
};

void main() {
  late ApiClient apiClient;
  late AssetClientApi assetApi;

  setUp(() {
    apiClient = ApiClient('http://backend.test/api');
    assetApi = AssetClientApi(apiClient: apiClient);
  });

  group('getPage', () {
    test('GETs the project asset collection with zero-based paging', () async {
      final adapter = RecordingHttpClientAdapter({
        'items': [_assetJson()],
        'totalItems': 1,
        'totalPages': 1,
        'currentPage': 0,
        'pageSize': 50,
      });
      apiClient.dio.httpClientAdapter = adapter;

      final result = await assetApi.getPage('p-1');

      expect(adapter.lastRequest!.method, 'GET');
      expect(adapter.lastRequest!.uri.path, '/api/project/p-1/asset/');
      expect(adapter.lastRequest!.uri.queryParameters, {
        'page': '0',
        'size': '50',
      });
      expect(result.items.single.key, 'vulpes:item/ruby');
    });

    test('sends the kind as a query parameter when given', () async {
      final adapter = RecordingHttpClientAdapter({
        'items': <Object>[],
        'totalItems': 0,
        'totalPages': 0,
        'currentPage': 2,
        'pageSize': 20,
      });
      apiClient.dio.httpClientAdapter = adapter;

      await assetApi.getPage(
        'p-1',
        kind: AssetKind.BBMODEL,
        page: 2,
        size: 20,
      );

      expect(adapter.lastRequest!.uri.queryParameters, {
        'kind': 'BBMODEL',
        'page': '2',
        'size': '20',
      });
    });
  });

  group('upload', () {
    test('POSTs a multipart form with the key and the named file', () async {
      final adapter = RecordingHttpClientAdapter(_assetJson(id: 'new'));
      apiClient.dio.httpClientAdapter = adapter;

      final result = await assetApi.upload(
        'p-1',
        key: 'vulpes:item/ruby',
        fileName: 'ruby.json',
        bytes: '{}'.codeUnits,
      );

      expect(adapter.lastRequest!.method, 'POST');
      expect(adapter.lastRequest!.uri.path, '/api/project/p-1/asset');
      final form = adapter.lastRequest!.data as FormData;
      expect(form.fields.single.key, 'key');
      expect(form.fields.single.value, 'vulpes:item/ruby');
      final file = form.files.single;
      expect(file.key, 'file');
      expect(file.value.filename, 'ruby.json');
      expect(file.value.length, 2);
      expect(result.id, 'new');
    });
  });

  group('content', () {
    test('GETs the bytes of the asset', () async {
      final adapter = FakeHttpClientAdapter(
        (_) => ResponseBody.fromBytes(
          Uint8List.fromList([137, 80, 78, 71]),
          200,
        ),
      );
      apiClient.dio.httpClientAdapter = adapter;

      final bytes = await assetApi.content('p-1', 'a-1');

      expect(bytes, [137, 80, 78, 71]);
    });

    test('requests the content path of the asset', () async {
      final recorder = _RecordingBytesAdapter();
      apiClient.dio.httpClientAdapter = recorder;

      await assetApi.content('p-1', 'a-1');

      expect(recorder.lastRequest!.method, 'GET');
      expect(recorder.lastRequest!.uri.path, '/api/project/p-1/asset/a-1/content');
      expect(recorder.lastRequest!.responseType, ResponseType.bytes);
    });
  });

  group('errors', () {
    test('a 409 on upload surfaces as a ProblemDetail with code and field', () async {
      apiClient.dio.httpClientAdapter = FakeHttpClientAdapter.json(
        {
          'title': 'Conflict',
          'status': 409,
          'detail': 'The key is already in use.',
          'code': 'CONFLICT',
          'errors': [
            {
              'field': 'key',
              'code': 'ASSET_KEY_CONFLICT',
              'message': 'Key is already in use',
            },
          ],
        },
        statusCode: 409,
      );

      DioException? error;
      try {
        await assetApi.upload(
          'p-1',
          key: 'vulpes:item/ruby',
          fileName: 'ruby.json',
          bytes: const [1],
        );
      } on DioException catch (e) {
        error = e;
      }

      expect(error, isNotNull, reason: 'a 409 must throw');
      final problem = ProblemDetail.fromDioException(error!);
      expect(problem.status, 409);
      expect(problem.code, 'CONFLICT');
      expect(problem.errors.single.field, 'key');
      expect(problem.errors.single.code, 'ASSET_KEY_CONFLICT');
    });
  });
}

/// Answers every request with an empty bytes body and remembers the request.
class _RecordingBytesAdapter extends FakeHttpClientAdapter {
  _RecordingBytesAdapter()
    : super((_) => ResponseBody.fromBytes(Uint8List(0), 200));

  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    lastRequest = options;
    return super.fetch(options, requestStream, cancelFuture);
  }
}
