import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/model/problem_detail.dart';

void main() {
  group('ProblemDetail', () {
    test('parses complete RFC 9457 JSON correctly', () {
      final json = {
        'type': 'https://vulpes.onelitefeather.net/errors/resource-not-found',
        'title': 'Resource not found',
        'status': 404,
        'detail': 'Attribute not found.',
        'instance': '/project/6f1c/attribute/update',
        'code': 'RESOURCE_NOT_FOUND',
        'traceId': '4bf92f3577b34da6a3ce929d0e0e4736',
        'errors': [
          {
            'field': 'displayName',
            'code': 'INVALID_LENGTH',
            'message': 'Must not be empty',
          },
        ],
      };

      final problem = ProblemDetail.fromJson(json);

      expect(problem.type, 'https://vulpes.onelitefeather.net/errors/resource-not-found');
      expect(problem.title, 'Resource not found');
      expect(problem.status, 404);
      expect(problem.detail, 'Attribute not found.');
      expect(problem.instance, '/project/6f1c/attribute/update');
      expect(problem.code, 'RESOURCE_NOT_FOUND');
      expect(problem.traceId, '4bf92f3577b34da6a3ce929d0e0e4736');
      expect(problem.errors.length, 1);
      expect(problem.errors.first.field, 'displayName');
      expect(problem.errors.first.code, 'INVALID_LENGTH');
      expect(problem.errors.first.message, 'Must not be empty');
      expect(problem.displayMessage, 'Attribute not found.');
    });

    test('parses minimal RFC 9457 JSON with defaults', () {
      final json = <String, dynamic>{
        'title': 'Bad Request',
        'status': 400,
      };

      final problem = ProblemDetail.fromJson(json);

      expect(problem.title, 'Bad Request');
      expect(problem.status, 400);
      expect(problem.detail, '');
      expect(problem.displayMessage, 'Bad Request');
      expect(problem.errors, isEmpty);
    });

    test('extracts ProblemDetail from DioException with response data', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 409,
          data: {
            'title': 'Conflict',
            'status': 409,
            'detail': 'An entry with this name already exists.',
            'code': 'ALREADY_EXISTS',
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final problem = ProblemDetail.fromDioException(dioException);

      expect(problem.status, 409);
      expect(problem.title, 'Conflict');
      expect(problem.detail, 'An entry with this name already exists.');
      expect(problem.code, 'ALREADY_EXISTS');
      expect(problem.displayMessage, 'An entry with this name already exists.');
    });

    test('creates fallback ProblemDetail for connection timeout', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
        message: 'Connection timed out',
      );

      final problem = ProblemDetail.fromDioException(dioException);

      expect(problem.status, 408);
      expect(problem.title, 'Connection Timeout');
      expect(problem.displayMessage, contains('timed out'));
    });

    test('creates fallback ProblemDetail for connection error', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );

      final problem = ProblemDetail.fromDioException(dioException);

      expect(problem.status, 503);
      expect(problem.title, 'Connection Error');
      expect(problem.displayMessage, contains('Unable to connect'));
    });
  });
}
