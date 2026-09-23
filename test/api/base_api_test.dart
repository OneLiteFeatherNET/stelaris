import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_client.dart';
import 'package:stelaris/api/base_api.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../support/recording_http_client_adapter.dart';
import '../test_model.dart';

class ProjectScopedTestModel with DataModel {
  final int internalId;
  final String name;
  final String? projectId;

  ProjectScopedTestModel({
    required this.internalId,
    required this.name,
    this.projectId,
  });

  @override
  String? get id => internalId.toString();

  @override
  DateTime? get creationDate => null;

  @override
  DateTime? get modificationDate => null;

  factory ProjectScopedTestModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw ArgumentError('json must be a Map<String, dynamic>');
    }
    return ProjectScopedTestModel(
      internalId: json['id'] as int,
      name: json['name'] as String,
      projectId: json['projectId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': internalId,
    'name': name,
    if (projectId != null) 'projectId': projectId,
  };
}

void main() {
  late ApiClient apiClient;
  late BaseApi<TestModel> baseApi;

  setUp(() {
    apiClient = ApiClient('http://backend.test/api');
    baseApi = BaseApi<TestModel>(
      apiClient: apiClient,
      endpoint: 'items',
      fromJson: TestModel.fromJson,
      toJson: (model) => model.toJson(),
    );
  });

  RecordingHttpClientAdapter respondWith(Object? json) {
    final adapter = RecordingHttpClientAdapter(json);
    apiClient.dio.httpClientAdapter = adapter;
    return adapter;
  }

  group('get', () {
    test('sends a GET to the endpoint and parses the model', () async {
      final model = TestModel(internalId: 1, name: 'Item 1');
      final adapter = respondWith(model.toJson());

      final result = await baseApi.get();

      expect(adapter.lastRequest!.method, 'GET');
      expect(
        adapter.lastRequest!.uri.toString(),
        'http://backend.test/api/items',
      );
      expect(result, model);
    });
  });

  group('add', () {
    test('sends a POST with the model body to the endpoint', () async {
      final model = TestModel(internalId: 2, name: 'New');
      final adapter = respondWith(model.toJson());

      final result = await baseApi.add(model);

      expect(adapter.lastRequest!.method, 'POST');
      expect(
        adapter.lastRequest!.uri.toString(),
        'http://backend.test/api/items',
      );
      expect(adapter.lastRequest!.data, model.toJson());
      expect(result, model);
    });
  });

  group('update', () {
    test('sends a POST to the /update sub-path', () async {
      final model = TestModel(internalId: 3, name: 'Updated');
      final adapter = respondWith(model.toJson());

      final result = await baseApi.update(model);

      expect(adapter.lastRequest!.method, 'POST');
      expect(
        adapter.lastRequest!.uri.toString(),
        'http://backend.test/api/items/update',
      );
      expect(adapter.lastRequest!.data, model.toJson());
      expect(result, model);
    });
  });

  group('remove', () {
    test('sends a DELETE to the /delete/{id} sub-path', () async {
      final model = TestModel(internalId: 4, name: 'Gone');
      final adapter = respondWith(model.toJson());

      final result = await baseApi.remove(model);

      expect(adapter.lastRequest!.method, 'DELETE');
      expect(
        adapter.lastRequest!.uri.toString(),
        'http://backend.test/api/items/delete/4',
      );
      expect(result, model);
    });
  });

  group('getPage', () {
    final emptyPage = const PaginatedResult<TestModel>(
      items: [],
      totalItems: 0,
      totalPages: 0,
      currentPage: 1,
      pageSize: 10,
    ).toJson((item) => item.toJson());

    test('converts the 1-based page to the 0-based query param', () async {
      final adapter = respondWith({
        'items': [
          {'id': 1, 'name': 'Item 1'},
        ],
        'totalItems': 1,
        'totalPages': 1,
        'currentPage': 1,
        'pageSize': 10,
      });

      final result = await baseApi.getPage(page: 1, size: 10);

      expect(adapter.lastRequest!.method, 'GET');
      expect(adapter.lastRequest!.uri.path, '/api/items');
      expect(adapter.lastRequest!.uri.queryParameters, {
        'page': '0',
        'size': '10',
      });
      expect(result.items, [TestModel(internalId: 1, name: 'Item 1')]);
      expect(result.totalItems, 1);
    });

    test('routes to /project/{projectId}/{endpoint} and omits projectId in '
        'queryParameters when provided', () async {
      final adapter = respondWith(emptyPage);

      await baseApi.getPage(page: 1, size: 10, projectId: 'proj-123');

      expect(adapter.lastRequest!.uri.path, '/api/project/proj-123/items');
      expect(adapter.lastRequest!.uri.queryParameters, {
        'page': '0',
        'size': '10',
      });
    });

    test('routes to /{endpoint} when projectId is null', () async {
      final adapter = respondWith(emptyPage);

      await baseApi.getPage(page: 2, size: 20);

      expect(adapter.lastRequest!.uri.path, '/api/items');
      expect(adapter.lastRequest!.uri.queryParameters, {
        'page': '1',
        'size': '20',
      });
    });
  });

  group('project scoping', () {
    late BaseApi<ProjectScopedTestModel> scopedApi;
    final model = ProjectScopedTestModel(
      internalId: 1,
      name: 'foo',
      projectId: 'proj-123',
    );

    setUp(() {
      scopedApi = BaseApi<ProjectScopedTestModel>(
        apiClient: apiClient,
        endpoint: 'test',
        fromJson: ProjectScopedTestModel.fromJson,
        toJson: (m) => m.toJson(),
      );
    });

    test('add routes to /project/{projectId}/{endpoint}', () async {
      final adapter = respondWith(model.toJson());

      await scopedApi.add(model);

      expect(adapter.lastRequest!.uri.path, '/api/project/proj-123/test');
    });

    test('update routes to /project/{projectId}/{endpoint}/update', () async {
      final adapter = respondWith(model.toJson());

      final result = await scopedApi.update(model);

      expect(adapter.lastRequest!.method, 'POST');
      expect(
        adapter.lastRequest!.uri.path,
        '/api/project/proj-123/test/update',
      );
      expect(result.projectId, 'proj-123');
    });

    test(
      'remove routes to /project/{projectId}/{endpoint}/delete/{id}',
      () async {
        final adapter = respondWith(model.toJson());

        final result = await scopedApi.remove(model);

        expect(adapter.lastRequest!.method, 'DELETE');
        expect(
          adapter.lastRequest!.uri.path,
          '/api/project/proj-123/test/delete/1',
        );
        expect(result.projectId, 'proj-123');
      },
    );
  });
}
