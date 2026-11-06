import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_client.dart';
import 'package:stelaris/api/service/generate_api.dart';
import 'package:stelaris/api/service/generator/generator_models.dart';
import 'package:stelaris_models/stelaris_models.dart';

const String _id = '3f1c2a54-8d4e-4c1b-9a77-0e5d2b6f1a90';
const Project _project = Project(
  id: _id,
  displayName: 'Eldoria',
  key: 'eldoria',
);
const String _commit = '0123456789abcdef0123456789abcdef01234567';

void main() {
  late ApiClient apiClient;
  late GenerateApi api;

  setUp(() {
    apiClient = ApiClient('http://generator.test/api');
    api = GenerateApi(apiClient);
  });

  _Adapter answer(
    Object? body, {
    int status = 200,
    Map<String, List<String>>? headers,
  }) {
    final adapter = _Adapter(body, status: status, headers: headers);
    apiClient.dio.httpClientAdapter = adapter;
    return adapter;
  }

  test('branches GETs /git/branches', () async {
    final adapter = answer(['develop', 'main']);

    expect(await api.branches(), ['develop', 'main']);
    expect(adapter.request!.method, 'GET');
    expect(adapter.request!.uri.path, '/api/git/branches');
  });

  group('localBuild', () {
    test('GETs the local build of the project for the base branch', () async {
      final adapter = answer(
        utf8.encode('zip'),
        headers: {
          'content-disposition': ['attachment; filename="eldoria-local.zip"'],
        },
      );

      final file = await api.localBuild(_project, 'feature/font');

      expect(adapter.request!.method, 'GET');
      expect(adapter.request!.uri.path, '/api/projects/$_id/local-build');
      expect(adapter.request!.uri.queryParameters, {
        'baseBranch': 'feature/font',
      });
      expect(file.bytes, utf8.encode('zip'));
      expect(file.filename, 'eldoria-local.zip');
    });

    test('names the file after the project key without a header', () async {
      answer(utf8.encode('zip'));

      final file = await api.localBuild(_project, 'develop');

      expect(file.filename, 'eldoria-local.zip');
    });

    test('reads the diagnostics of a 422 from the byte body', () async {
      answer(
        utf8.encode(
          jsonEncode({
            'reason': 'COMPILATION_FAILED',
            'message': 'does not compile',
            'diagnostics': [
              {'file': 'items/Sword.java', 'line': 12, 'message': 'boom'},
            ],
          }),
        ),
        status: 422,
      );

      await expectLater(
        api.localBuild(_project, 'develop'),
        throwsA(
          isA<GeneratorApiException>().having(
            (e) => e.failure,
            'failure',
            const GeneratorFailure(
              GeneratorFailureKind.rejected,
              statusCode: 422,
              message: 'does not compile',
              diagnostics: [
                Diagnostic(file: 'items/Sword.java', line: 12, message: 'boom'),
              ],
            ),
          ),
        ),
      );
    });
  });

  group('publish', () {
    test('POSTs the project id, version and base branch', () async {
      final adapter = answer({
        'coordinates': 'net.onelitefeather.vulpes.content:eldoria:1.5.0',
        'revision': 'abc',
        'base': {
          'repository': 'OneLiteFeatherNET/vulpes-base',
          'branch': 'develop',
          'commit': _commit,
        },
        'repositoryUrl': 'https://repo.test/releases',
      }, status: 201);

      final result = await api.publish(_project, '1.5.0', 'develop');

      expect(adapter.request!.method, 'POST');
      expect(adapter.request!.uri.path, '/api/generator/release');
      expect(adapter.request!.data, {
        'projectId': _id,
        'version': '1.5.0',
        'baseBranch': 'develop',
      });
      expect(result.base.commit, _commit);
      expect(
        result.gradleLine,
        'vulpes("net.onelitefeather.vulpes.content:eldoria:1.5.0")',
      );
    });

    for (final (status, kind) in [
      (409, GeneratorFailureKind.versionExists),
      (422, GeneratorFailureKind.rejected),
      (500, GeneratorFailureKind.unexpected),
    ]) {
      test('maps $status to ${kind.name}', () async {
        answer({'reason': 'X', 'message': 'nope'}, status: status);

        await expectLater(
          api.publish(_project, '1.5.0', 'develop'),
          throwsA(
            isA<GeneratorApiException>()
                .having((e) => e.failure.kind, 'kind', kind)
                .having((e) => e.failure.statusCode, 'status', status)
                .having((e) => e.failure.message, 'message', 'nope'),
          ),
        );
      });
    }

    test('maps 502 to unavailable and drops its message', () async {
      answer({
        'reason': 'BASE_UNAVAILABLE',
        'message': 'clone of git@internal-host:vulpes-base failed',
      }, status: 502);

      await expectLater(
        api.publish(_project, '1.5.0', 'develop'),
        throwsA(
          isA<GeneratorApiException>().having(
            (e) => e.failure,
            'failure',
            const GeneratorFailure(
              GeneratorFailureKind.unavailable,
              statusCode: 502,
            ),
          ),
        ),
      );
    });

    test('reads a cut diagnostics list', () async {
      answer({
        'reason': 'COMPILATION_FAILED',
        'message': 'm',
        'diagnostics': [
          {'file': 'A.java', 'line': 1, 'message': 'x'},
        ],
        'truncated': true,
      }, status: 422);

      await expectLater(
        api.publish(_project, '1.5.0', 'develop'),
        throwsA(
          isA<GeneratorApiException>().having(
            (e) => e.failure.truncated,
            'truncated',
            isTrue,
          ),
        ),
      );
    });
  });

  test('a request without an answer is a network failure', () async {
    apiClient.dio.httpClientAdapter = _Adapter.unreachable();

    await expectLater(
      api.branches(),
      throwsA(
        isA<GeneratorApiException>().having(
          (e) => e.failure,
          'failure',
          const GeneratorFailure(GeneratorFailureKind.network),
        ),
      ),
    );
  });

  group('publishedVersions', () {
    test('GETs the releases of the project and reads the entries', () async {
      final adapter = answer({
        'versions': [
          {
            'version': '1.4.2',
            'channel': 'release',
            'coordinates': 'g:eldoria:1.4.2',
            'repositoryUrl': 'https://repo.test/releases',
            'jarUrl': 'https://repo.test/releases/x.jar',
          },
          {
            'version': '1.5.0-SNAPSHOT',
            'channel': 'snapshot',
            'coordinates': 'g:eldoria:1.5.0-SNAPSHOT',
            'repositoryUrl': 'https://repo.test/snapshots',
          },
        ],
        'latest': {'release': '1.4.2', 'snapshot': '1.5.0-SNAPSHOT'},
      });

      final versions = await api.publishedVersions(_project);

      expect(adapter.request!.uri.path, '/api/projects/$_id/releases');
      expect(versions.map((it) => it.version), ['1.4.2', '1.5.0-SNAPSHOT']);
      expect(versions.last.channel, ReleaseChannel.snapshot);
    });

    test('maps a 502 to unavailable', () async {
      answer({
        'reason': 'REPOSITORY',
        'message': 'snapshots down',
      }, status: 502);

      await expectLater(
        api.publishedVersions(_project),
        throwsA(
          isA<GeneratorApiException>().having(
            (e) => e.failure.kind,
            'kind',
            GeneratorFailureKind.unavailable,
          ),
        ),
      );
    });
  });

  test('publishedVersionBuild GETs the local build of the version', () async {
    final adapter = answer(utf8.encode('zip'));

    final file = await api.publishedVersionBuild(_project, '1.0.0-SNAPSHOT');

    expect(
      adapter.request!.uri.path,
      '/api/projects/$_id/releases/1.0.0-SNAPSHOT/local-build',
    );
    expect(file.filename, 'eldoria-1.0.0-SNAPSHOT.zip');
  });

  test('a project without an id fails before any request', () async {
    final adapter = answer(const <String>[]);

    await expectLater(
      api.publishedVersions(const Project(displayName: 'New', key: 'new')),
      throwsA(isA<GeneratorApiException>()),
    );
    expect(adapter.request, isNull);
  });
}

/// Records the last request and answers with [body]: bytes as they are,
/// anything else as JSON.
class _Adapter implements HttpClientAdapter {
  _Adapter(this.body, {this.status = 200, this.headers}) : _unreachable = false;

  _Adapter.unreachable()
    : body = null,
      status = 0,
      headers = null,
      _unreachable = true;

  final Object? body;
  final int status;
  final Map<String, List<String>>? headers;
  final bool _unreachable;

  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    if (_unreachable) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'unreachable',
      );
    }
    final Object? body = this.body;
    if (body is List<int>) {
      return ResponseBody.fromBytes(body, status, headers: headers ?? {});
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        ...?headers,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
