import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_client.dart';
import 'package:stelaris/api/model/asset_model.dart';
import 'package:stelaris/api/service/client/asset_client_api.dart';
import 'package:stelaris/feature/asset/loading/asset_library.dart';

import '../../../support/fake_http_client_adapter.dart';

const _projectId = 'p-1';
const _bytesOfTexture = [1, 2, 3, 4];

/// A fake backend for the asset endpoints of one project.
///
/// Serves [assets] filtered by the `kind` query parameter and split into pages of [pageSize],
/// and the bytes of each asset from [contents] by asset id. Every request is recorded.
class _FakeBackend {
  _FakeBackend({
    required this.assets,
    this.pageSize = 50,
    Map<String, List<int>> contents = const {},
  }) : contents = {
         for (final entry in contents.entries) entry.key: entry.value,
       };

  final List<Map<String, Object?>> assets;
  final int pageSize;
  final Map<String, List<int>> contents;
  final List<RequestOptions> requests = [];

  late final FakeHttpClientAdapter adapter = FakeHttpClientAdapter(_handle);

  int requestsTo(String pathSuffix) =>
      requests.where((r) => r.uri.path.endsWith(pathSuffix)).length;

  ResponseBody _handle(RequestOptions options) {
    requests.add(options);
    final contentMatch = RegExp(r'/asset/([^/]+)/content$')
        .firstMatch(options.uri.path);
    if (contentMatch != null) {
      final bytes = contents[contentMatch.group(1)];
      return bytes == null
          ? FakeHttpClientAdapter.response({
              'title': 'Not Found',
            }, statusCode: 404)
          : ResponseBody.fromBytes(bytes, 200);
    }
    final kind = options.uri.queryParameters['kind'];
    final page = int.parse(options.uri.queryParameters['page']!);
    final matching = assets
        .where((asset) => kind == null || asset['kind'] == kind)
        .toList();
    final from = page * pageSize;
    final items = from >= matching.length
        ? <Map<String, Object?>>[]
        : matching.sublist(
            from,
            (from + pageSize) > matching.length
                ? matching.length
                : from + pageSize,
          );
    final totalPages = (matching.length + pageSize - 1) ~/ pageSize;
    return FakeHttpClientAdapter.response({
      'items': items,
      'totalItems': matching.length,
      'totalPages': totalPages,
      'currentPage': page,
      'pageSize': pageSize,
    });
  }
}

Map<String, Object?> _asset({
  required String id,
  required String key,
  required String kind,
  String sha1 = 'sha-default',
  int? width,
  int? height,
}) => {
  'id': id,
  'projectId': _projectId,
  'key': key,
  'kind': kind,
  'fileName': '$id.file',
  'contentType': 'application/octet-stream',
  'size': 10,
  'sha1': sha1,
  'width': ?width,
  'height': ?height,
  'derivedAssetIds': <String>[],
};

AssetLibrary _library(_FakeBackend backend) {
  final apiClient = ApiClient('http://backend.test/api');
  apiClient.dio.httpClientAdapter = backend.adapter;
  return AssetLibrary(AssetClientApi(apiClient: apiClient));
}

String _json(Object? value) => jsonEncode(value);

List<int> _utf8(String text) => utf8.encode(text);

void main() {
  group('findModelByKey', () {
    test('finds a model on a later page', () async {
      final backend = _FakeBackend(
        pageSize: 1,
        assets: [
          _asset(id: 'm-other', key: 'vulpes:item/other', kind: 'MODEL'),
          _asset(id: 'm-ruby', key: 'vulpes:item/ruby', kind: 'MODEL'),
        ],
      );

      final found = await _library(backend)
          .findModelByKey(_projectId, 'vulpes:item/ruby');

      expect(found?.id, 'm-ruby');
      expect(backend.requestsTo('/asset/'), 2);
    });

    test('returns null when no model has the key', () async {
      final backend = _FakeBackend(
        assets: [
          _asset(id: 'm-other', key: 'vulpes:item/other', kind: 'MODEL'),
          _asset(id: 'b-other', key: 'vulpes:item/other2', kind: 'BBMODEL'),
        ],
      );

      final found = await _library(backend)
          .findModelByKey(_projectId, 'vulpes:item/ruby');

      expect(found, isNull);
    });

    test('ignores a texture that has the same key', () async {
      final backend = _FakeBackend(
        assets: [
          _asset(id: 't-ruby', key: 'vulpes:item/ruby', kind: 'TEXTURE'),
        ],
      );

      final found = await _library(backend)
          .findModelByKey(_projectId, 'vulpes:item/ruby');

      expect(found, isNull);
    });

    test('serves a second lookup of the same key from the cache', () async {
      final backend = _FakeBackend(
        assets: [_asset(id: 'm-ruby', key: 'vulpes:item/ruby', kind: 'MODEL')],
      );
      final library = _library(backend);

      final first = await library.findModelByKey(
        _projectId,
        'vulpes:item/ruby',
      );
      final requestsAfterFirst = backend.requests.length;
      final second = await library.findModelByKey(
        _projectId,
        'vulpes:item/ruby',
      );

      expect(second?.id, first?.id);
      expect(backend.requests.length, requestsAfterFirst);
    });

    test('uses a remembered model without fetching', () async {
      final backend = _FakeBackend(assets: const []);
      final library = _library(backend);
      final uploaded = AssetModel.fromJson(
        _asset(id: 'm-new', key: 'vulpes:item/new', kind: 'MODEL'),
      );

      library.remember(uploaded);
      final found = await library.findModelByKey(_projectId, 'vulpes:item/new');

      expect(found?.id, 'm-new');
      expect(backend.requests, isEmpty);
    });
  });

  group('loadScene', () {
    test('loads a Blockbench model with its three detail levels', () async {
      final bbmodel = {
        'resolution': {'width': 16, 'height': 16},
        'elements': [
          {
            'type': 'cube',
            'from': [0, 0, 0],
            'to': [16, 16, 16],
            'faces': <String, Object?>{},
          },
          {'type': 'mesh', 'name': 'Sword blade'},
        ],
      };
      final backend = _FakeBackend(
        assets: [
          _asset(id: 'b-ruby', key: 'vulpes:item/ruby', kind: 'BBMODEL'),
        ],
        contents: {'b-ruby': _utf8(_json(bbmodel))},
      );
      final library = _library(backend);
      final asset = AssetModel.fromJson(
        _asset(id: 'b-ruby', key: 'vulpes:item/ruby', kind: 'BBMODEL'),
      );

      final data = await library.loadScene(_projectId, asset);

      expect((data.scene['levels'] as List), hasLength(3));
      expect(data.unsupported, ['mesh: Sword blade']);
      expect(data.scene['unsupported'], ['mesh: Sword blade']);
    });

    test('resolves a texture by key into a data URI', () async {
      final model = {
        'parent': 'minecraft:item/generated',
        'textures': {'layer0': 'vulpes:item/ruby'},
      };
      final backend = _FakeBackend(
        assets: [
          _asset(
            id: 'm-ruby',
            key: 'vulpes:item/ruby',
            kind: 'MODEL',
            sha1: 'sha-model',
          ),
          _asset(
            id: 't-ruby',
            key: 'vulpes:item/ruby',
            kind: 'TEXTURE',
            sha1: 'sha-texture',
            width: 32,
            height: 32,
          ),
        ],
        contents: {'m-ruby': _utf8(_json(model)), 't-ruby': _bytesOfTexture},
      );
      final asset = AssetModel.fromJson(
        _asset(id: 'm-ruby', key: 'vulpes:item/ruby', kind: 'MODEL'),
      );

      final data = await _library(backend).loadScene(_projectId, asset);

      final textures = data.scene['textures'] as List;
      expect(textures, hasLength(1));
      final texture = textures.single as Map<String, Object?>;
      expect(
        texture['dataUri'],
        'data:image/png;base64,${base64Encode(_bytesOfTexture)}',
      );
      expect(texture['width'], 32);
      expect(texture['height'], 32);
    });

    test('leaves a texture that is not in the project null', () async {
      final model = {
        'elements': [
          {
            'from': [0, 0, 0],
            'to': [16, 16, 16],
            'faces': {
              'north': {
                'uv': [0, 0, 16, 16],
                'texture': '#a',
              },
              'south': {
                'uv': [0, 0, 16, 16],
                'texture': '#b',
              },
            },
          },
        ],
        'textures': {'a': 'vulpes:item/ruby', 'b': 'vulpes:item/missing'},
      };
      final backend = _FakeBackend(
        assets: [
          _asset(id: 'm-block', key: 'vulpes:block/box', kind: 'MODEL'),
          _asset(id: 't-ruby', key: 'vulpes:item/ruby', kind: 'TEXTURE'),
        ],
        contents: {'m-block': _utf8(_json(model)), 't-ruby': _bytesOfTexture},
      );
      final asset = AssetModel.fromJson(
        _asset(id: 'm-block', key: 'vulpes:block/box', kind: 'MODEL'),
      );

      final data = await _library(backend).loadScene(_projectId, asset);

      final faces =
          ((data.scene['levels'] as List).first
                  as Map<String, Object?>)['boxes']
              as List;
      final box = faces.single as Map<String, Object?>;
      final boxFaces = box['faces'] as Map<String, Object?>;
      final north = boxFaces['north'] as Map<String, Object?>;
      final south = boxFaces['south'] as Map<String, Object?>;
      expect(north['texture'], isNotNull);
      expect(south['texture'], isNull);
    });

    test('downloads the content of an asset once per sha1', () async {
      final bbmodel = {
        'elements': [
          {
            'from': [0, 0, 0],
            'to': [16, 16, 16],
            'faces': <String, Object?>{},
          },
        ],
      };
      final backend = _FakeBackend(
        assets: [
          _asset(
            id: 'b-ruby',
            key: 'vulpes:item/ruby',
            kind: 'BBMODEL',
            sha1: 'sha-bbmodel',
          ),
        ],
        contents: {'b-ruby': _utf8(_json(bbmodel))},
      );
      final library = _library(backend);
      final asset = AssetModel.fromJson(
        _asset(
          id: 'b-ruby',
          key: 'vulpes:item/ruby',
          kind: 'BBMODEL',
          sha1: 'sha-bbmodel',
        ),
      );

      await library.loadScene(_projectId, asset);
      final contentRequestsAfterFirst = backend.requestsTo('/content');
      await library.loadScene(_projectId, asset);

      expect(contentRequestsAfterFirst, 1);
      expect(backend.requestsTo('/content'), 1);
    });

    test('throws a FormatException when the file is not JSON', () async {
      final backend = _FakeBackend(
        assets: [_asset(id: 'm-bad', key: 'vulpes:item/bad', kind: 'MODEL')],
        contents: {'m-bad': _utf8('{ not json')},
      );
      final asset = AssetModel.fromJson(
        _asset(id: 'm-bad', key: 'vulpes:item/bad', kind: 'MODEL'),
      );

      expect(
        () => _library(backend).loadScene(_projectId, asset),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('vulpes:item/bad is not valid JSON'),
          ),
        ),
      );
    });
  });
}
