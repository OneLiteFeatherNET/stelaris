import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_client.dart';
import 'package:stelaris/api/service/generate_api.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/recording_http_client_adapter.dart';

void main() {
  late ApiClient apiClient;
  late GenerateApi generateApi;

  setUp(() {
    apiClient = ApiClient('http://backend.test/api');
    generateApi = GenerateApi(apiClient);
  });

  test('generate GETs /generate with the branch as a query param', () async {
    final adapter = RecordingHttpClientAdapter({'status': 'started'});
    apiClient.dio.httpClientAdapter = adapter;

    final response = await generateApi.generate('main');

    expect(adapter.lastRequest!.method, 'GET');
    expect(adapter.lastRequest!.uri.path, '/api/generate');
    expect(adapter.lastRequest!.uri.queryParameters, {'branch': 'main'});
    expect(response.data, {'status': 'started'});
  });

  test('branches GETs /git/branches and returns a list of names', () async {
    final adapter = RecordingHttpClientAdapter(['main', 'develop']);
    apiClient.dio.httpClientAdapter = adapter;

    final result = await generateApi.branches();

    expect(adapter.lastRequest!.method, 'GET');
    expect(adapter.lastRequest!.uri.path, '/api/git/branches');
    expect(result, ['main', 'develop']);
  });

  group('download', () {
    test('GETs /download with branch and projectId query params', () async {
      final adapter = _BytesAdapter(utf8.encode('zip-content'));
      apiClient.dio.httpClientAdapter = adapter;

      await generateApi.download('main', 'project-1');

      expect(adapter.lastRequest!.method, 'GET');
      expect(adapter.lastRequest!.uri.path, '/api/download');
      expect(adapter.lastRequest!.uri.queryParameters, {
        'branch': 'main',
        'projectId': 'project-1',
      });
    });

    test('uses the filename from Content-Disposition when present', () async {
      final bytes = utf8.encode('zip-content');
      apiClient.dio.httpClientAdapter = _BytesAdapter(
        bytes,
        headers: {
          'content-disposition': ['attachment; filename="custom.zip"'],
        },
      );

      final (data, filename) = await generateApi.download('main', 'project-1');

      expect(data, bytes);
      expect(filename, 'custom.zip');
    });

    test('falls back to a branch-based filename otherwise', () async {
      final bytes = utf8.encode('zip-content');
      apiClient.dio.httpClientAdapter = _BytesAdapter(bytes);

      final (data, filename) = await generateApi.download(
        'feature/x',
        'project-1',
      );

      expect(data, bytes);
      expect(filename, 'vulpes-feature/x.zip');
    });
  });

  test('buildInformation GETs /build/data and parses a ReleaseModel', () async {
    final release = ReleaseModel(
      version: '1.2.3',
      publishedAt: DateTime.utc(2024, 1, 1),
    );
    final adapter = RecordingHttpClientAdapter(release.toJson());
    apiClient.dio.httpClientAdapter = adapter;

    final result = await generateApi.buildInformation();

    expect(adapter.lastRequest!.method, 'GET');
    expect(adapter.lastRequest!.uri.path, '/api/build/data');
    expect(result, release);
  });
}

/// A [HttpClientAdapter] fake that records the [RequestOptions] of the last
/// request and responds with raw [bytes] and optional [headers], for
/// endpoints using [ResponseType.bytes].
class _BytesAdapter implements HttpClientAdapter {
  _BytesAdapter(this.bytes, {this.headers = const {}});

  final List<int> bytes;
  final Map<String, List<String>> headers;

  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromBytes(bytes, 200, headers: headers);
  }

  @override
  void close({bool force = false}) {}
}
