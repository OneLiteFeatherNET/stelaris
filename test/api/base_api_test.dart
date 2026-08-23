import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_client.dart';
import 'package:stelaris/api/base_api.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../support/fake_http_client_adapter.dart';
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
  group('BaseApi.getPage', () {
    test('routes to /project/{projectId}/{endpoint} and omits projectId in queryParameters when provided', () async {
      final client = ApiClient('http://localhost:8080');
      String? capturedPath;
      Map<String, dynamic>? capturedQueryParams;

      client.dio.httpClientAdapter = FakeHttpClientAdapter((options) {
        capturedPath = options.uri.path;
        capturedQueryParams = options.uri.queryParameters;
        return ResponseBody.fromString(
          jsonEncode(
            const PaginatedResult<TestModel>(
              items: [],
              totalItems: 0,
              totalPages: 0,
              currentPage: 1,
              pageSize: 10,
            ).toJson((item) => item.toJson()),
          ),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final api = BaseApi<TestModel>(
        apiClient: client,
        endpoint: 'test',
        fromJson: TestModel.fromJson,
        toJson: (m) => m.toJson(),
      );

      await api.getPage(page: 1, size: 10, projectId: 'proj-123');

      expect(capturedPath, '/project/proj-123/test');
      expect(capturedQueryParams?['projectId'], isNull);
      expect(capturedQueryParams?['page'], '0');
      expect(capturedQueryParams?['size'], '10');
    });

    test('routes to /{endpoint} when projectId is null', () async {
      final client = ApiClient('http://localhost:8080');
      String? capturedPath;
      Map<String, dynamic>? capturedQueryParams;

      client.dio.httpClientAdapter = FakeHttpClientAdapter((options) {
        capturedPath = options.uri.path;
        capturedQueryParams = options.uri.queryParameters;
        return ResponseBody.fromString(
          jsonEncode(
            const PaginatedResult<TestModel>(
              items: [],
              totalItems: 0,
              totalPages: 0,
              currentPage: 1,
              pageSize: 10,
            ).toJson((item) => item.toJson()),
          ),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final api = BaseApi<TestModel>(
        apiClient: client,
        endpoint: 'test',
        fromJson: TestModel.fromJson,
        toJson: (m) => m.toJson(),
      );

      await api.getPage(page: 2, size: 20);

      expect(capturedPath, '/test');
      expect(capturedQueryParams?['projectId'], isNull);
      expect(capturedQueryParams?['page'], '1');
      expect(capturedQueryParams?['size'], '20');
    });
  });

  group('BaseApi CRUD project scoping', () {
    test('add routes to /project/{projectId}/{endpoint} when model has projectId', () async {
      final client = ApiClient('http://localhost:8080');
      String? capturedPath;

      client.dio.httpClientAdapter = FakeHttpClientAdapter((options) {
        capturedPath = options.uri.path;
        return ResponseBody.fromString(
          jsonEncode({'id': 1, 'name': 'foo', 'projectId': 'proj-123'}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final api = BaseApi<ProjectScopedTestModel>(
        apiClient: client,
        endpoint: 'test',
        fromJson: ProjectScopedTestModel.fromJson,
        toJson: (m) => m.toJson(),
      );

      final model = ProjectScopedTestModel(internalId: 1, name: 'foo', projectId: 'proj-123');
      await api.add(model);

      expect(capturedPath, '/project/proj-123/test');
    });

    test('update routes to /project/{projectId}/{endpoint}/update when model has projectId', () async {
      final client = ApiClient('http://localhost:8080');
      String? capturedPath;

      client.dio.httpClientAdapter = FakeHttpClientAdapter((options) {
        capturedPath = options.uri.path;
        return ResponseBody.fromString(
          jsonEncode({'id': 1, 'name': 'foo', 'projectId': 'proj-123'}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final api = BaseApi<ProjectScopedTestModel>(
        apiClient: client,
        endpoint: 'test',
        fromJson: ProjectScopedTestModel.fromJson,
        toJson: (m) => m.toJson(),
      );

      final model = ProjectScopedTestModel(internalId: 1, name: 'foo', projectId: 'proj-123');
      await api.update(model);

      expect(capturedPath, '/project/proj-123/test/update');
    });

    test('remove routes to /project/{projectId}/{endpoint}/delete/{id} when model has projectId', () async {
      final client = ApiClient('http://localhost:8080');
      String? capturedPath;

      client.dio.httpClientAdapter = FakeHttpClientAdapter((options) {
        capturedPath = options.uri.path;
        return ResponseBody.fromString(
          jsonEncode({'id': 1, 'name': 'foo', 'projectId': 'proj-123'}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final api = BaseApi<ProjectScopedTestModel>(
        apiClient: client,
        endpoint: 'test',
        fromJson: ProjectScopedTestModel.fromJson,
        toJson: (m) => m.toJson(),
      );

      final model = ProjectScopedTestModel(internalId: 1, name: 'foo', projectId: 'proj-123');
      await api.remove(model);

      expect(capturedPath, '/project/proj-123/test/delete/1');
    });
  });
}

