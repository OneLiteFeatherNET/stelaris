import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/paginated_result.dart';
import 'package:stelaris/api/model/data_model.dart';

class MockDataModel with DataModel {
  @override
  final String? id;
  final String name;

  const MockDataModel({required this.id, required this.name});

  factory MockDataModel.fromJson(Map<String, dynamic> json) {
    return MockDataModel(
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MockDataModel && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

void main() {
  group('PaginatedResult', () {
    final sampleItems = [
      const MockDataModel(id: '1', name: 'Item 1'),
      const MockDataModel(id: '2', name: 'Item 2'),
      const MockDataModel(id: '3', name: 'Item 3'),
    ];

    group('fromJson factory', () {
      test('should parse standard JSON structure', () {
        final json = {
          'items': [
            {'id': '1', 'name': 'Item 1'},
            {'id': '2', 'name': 'Item 2'},
          ],
          'totalItems': 10,
          'totalPages': 5,
          'currentPage': 2,
          'pageSize': 2,
        };

        final result = PaginatedResult<MockDataModel>.fromJson(
          json,
              (json) => MockDataModel.fromJson(json as Map<String, dynamic>),
        );

        expect(result.items.length, equals(2));
        expect(result.items.first.id, equals('1'));
        expect(result.totalItems, equals(10));
      });

      test('should handle alternative JSON keys', () {
        final json = {
          'content': [{'id': '1', 'name': 'Item 1'}],
          'totalElements': 5,
          'size': 1,
          'page': 0,
        };

        final result = PaginatedResult<MockDataModel>.fromJson(
          json,
              (json) => MockDataModel.fromJson(json as Map<String, dynamic>),
        );

        expect(result.items.length, equals(1));
        expect(result.totalItems, equals(5));
        expect(result.currentPage, equals(1));
      });

      // UPDATED: Apply the wrapper to all other fromJson tests...
      test('should handle pageable structure', () {
        final json = {
          'data': [{'id': '1', 'name': 'Item 1'}],
          'pageable': {'size': 10, 'number': 2},
          'totalElements': 50,
        };

        final result = PaginatedResult<MockDataModel>.fromJson(
          json,
              (json) => MockDataModel.fromJson(json as Map<String, dynamic>),
        );
        expect(result.pageSize, equals(10));
        expect(result.currentPage, equals(3));
      });

      test('should handle empty or missing items', () {
        final json = <String, dynamic>{
          'totalItems': 0,
          'totalPages': 0,
          'currentPage': 1,
          'pageSize': 10,
        };

        final result = PaginatedResult<MockDataModel>.fromJson(
          json,
              (json) => MockDataModel.fromJson(json as Map<String, dynamic>),
        );

        expect(result.items, isEmpty);
        expect(result.totalItems, equals(0));
      });
    });

    group('toJson', () {
      test('should serialize to JSON correctly', () {
        final result = PaginatedResult<MockDataModel>(
          items: sampleItems,
          totalItems: 10,
          totalPages: 4,
          currentPage: 2,
          pageSize: 3,
        );

        final json = result.toJson((model) => model.toJson());

        expect(json['items'], hasLength(3));
        expect(json['items'][0]['id'], equals('1'));
      });
    });

    group('Integration tests', () {
      test('round-trip JSON serialization should preserve data', () {
        final original = PaginatedResult<MockDataModel>(
          items: sampleItems,
          totalItems: 10,
          totalPages: 4,
          currentPage: 2,
          pageSize: 3,
        );

        final json = original.toJson((model) => model.toJson());

        final reconstructed = PaginatedResult<MockDataModel>.fromJson(
          json,
              (json) => MockDataModel.fromJson(json as Map<String, dynamic>),
        );

        expect(reconstructed.items.length, equals(original.items.length));
        expect(reconstructed.totalItems, equals(original.totalItems));
      });
    });
  });
}
