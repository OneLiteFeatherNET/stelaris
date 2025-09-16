import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/paginated_result.dart';
import 'package:stelaris/api/model/data_model.dart';

// Mock DataModel for testing
class MockDataModel with DataModel {
  @override
  final String? id;
  final String name;

  const MockDataModel({required this.id, required this.name});

  factory MockDataModel.fromJson(Map<String, dynamic> json) {
    return MockDataModel(
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'Unknown', // Provide default for missing name
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
    // Sample data for tests
    final sampleItems = [
      MockDataModel(id: '1', name: 'Item 1'),
      MockDataModel(id: '2', name: 'Item 2'),
      MockDataModel(id: '3', name: 'Item 3'),
    ];

    // Sample data with null id for edge case testing
    final sampleItemWithNullId = MockDataModel(id: null, name: 'Item without ID');

    group('Constructor', () {
      test('should create instance with all required parameters', () {
        final result = PaginatedResult<MockDataModel>(
          items: sampleItems,
          totalItems: 10,
          totalPages: 4,
          currentPage: 2,
          pageSize: 3,
        );

        expect(result.items, equals(sampleItems));
        expect(result.totalItems, equals(10));
        expect(result.totalPages, equals(4));
        expect(result.currentPage, equals(2));
        expect(result.pageSize, equals(3));
      });
    });

    group('Getters', () {
      late PaginatedResult<MockDataModel> result;

      setUp(() {
        result = PaginatedResult<MockDataModel>(
          items: sampleItems,
          totalItems: 10,
          totalPages: 4,
          currentPage: 2,
          pageSize: 3,
        );
      });

      test('hasNextPage should return true when current page < total pages', () {
        expect(result.hasNextPage, isTrue);
      });

      test('hasNextPage should return false when current page = total pages', () {
        final lastPageResult = result.copyWith(currentPage: 4);
        expect(lastPageResult.hasNextPage, isFalse);
      });

      test('hasPreviousPage should return true when current page > 1', () {
        expect(result.hasPreviousPage, isTrue);
      });

      test('hasPreviousPage should return false when current page = 1', () {
        final firstPageResult = result.copyWith(currentPage: 1);
        expect(firstPageResult.hasPreviousPage, isFalse);
      });

      test('startIndex should calculate correctly', () {
        // Page 2, pageSize 3: startIndex = (2-1) * 3 + 1 = 4
        expect(result.startIndex, equals(4));
      });

      test('endIndex should calculate correctly', () {
        // startIndex = 4, items.length = 3: endIndex = 4 + 3 - 1 = 6
        expect(result.endIndex, equals(6));
      });

      test('startIndex and endIndex for first page', () {
        final firstPageResult = result.copyWith(currentPage: 1);
        expect(firstPageResult.startIndex, equals(1));
        expect(firstPageResult.endIndex, equals(3));
      });
    });

    group('copyWith', () {
      late PaginatedResult<MockDataModel> original;

      setUp(() {
        original = PaginatedResult<MockDataModel>(
          items: sampleItems,
          totalItems: 10,
          totalPages: 4,
          currentPage: 2,
          pageSize: 3,
        );
      });

      test('should return same instance when no parameters provided', () {
        final copy = original.copyWith();
        expect(copy.items, equals(original.items));
        expect(copy.totalItems, equals(original.totalItems));
        expect(copy.totalPages, equals(original.totalPages));
        expect(copy.currentPage, equals(original.currentPage));
        expect(copy.pageSize, equals(original.pageSize));
      });

      test('should update only provided parameters', () {
        final newItems = [MockDataModel(id: '4', name: 'Item 4')];
        final copy = original.copyWith(
          items: newItems,
          currentPage: 3,
        );

        expect(copy.items, equals(newItems));
        expect(copy.currentPage, equals(3));
        expect(copy.totalItems, equals(original.totalItems)); // unchanged
        expect(copy.totalPages, equals(original.totalPages)); // unchanged
        expect(copy.pageSize, equals(original.pageSize)); // unchanged
      });
    });

    group('empty factory', () {
      test('should create empty paginated result', () {
        final empty = PaginatedResult<MockDataModel>.empty();

        expect(empty.items, isEmpty);
        expect(empty.totalItems, equals(0));
        expect(empty.totalPages, equals(0));
        expect(empty.currentPage, equals(1));
        expect(empty.pageSize, equals(0));
        expect(empty.hasNextPage, isFalse);
        expect(empty.hasPreviousPage, isFalse);
      });
    });

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
          MockDataModel.fromJson,
        );

        expect(result.items.length, equals(2));
        expect(result.items.first.id, equals('1'));
        expect(result.totalItems, equals(10));
        expect(result.totalPages, equals(5));
        expect(result.currentPage, equals(2));
        expect(result.pageSize, equals(2));
      });

      test('should handle alternative JSON keys', () {
        final json = {
          'content': [
            {'id': '1', 'name': 'Item 1'},
          ],
          'totalElements': 5,
          'size': 1,
          'page': 0, // 0-based page number
        };

        final result = PaginatedResult<MockDataModel>.fromJson(
          json,
          MockDataModel.fromJson,
        );

        expect(result.items.length, equals(1));
        expect(result.totalItems, equals(5));
        expect(result.currentPage, equals(1)); // converted from 0-based
        expect(result.pageSize, equals(1));
        expect(result.totalPages, equals(5)); // computed
      });

      test('should handle pageable structure', () {
        final json = {
          'data': [
            {'id': '1', 'name': 'Item 1'},
          ],
          'pageable': {
            'size': 10,
            'number': 2, // 0-based
          },
          'totalElements': 50,
        };

        final result = PaginatedResult<MockDataModel>.fromJson(
          json,
          MockDataModel.fromJson,
        );

        expect(result.pageSize, equals(10));
        expect(result.currentPage, equals(3)); // converted from 0-based
        expect(result.totalItems, equals(50));
        expect(result.totalPages, equals(5)); // computed
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
          MockDataModel.fromJson,
        );

        expect(result.items, isEmpty);
        expect(result.totalItems, equals(0));
      });

      test('should handle null items array', () {
        final json = {
          'items': null,
          'totalItems': 0,
        };

        final result = PaginatedResult<MockDataModel>.fromJson(
          json,
          MockDataModel.fromJson,
        );

        expect(result.items, isEmpty);
      });

      test('should compute totalPages when not provided', () {
        final json = {
          'items': [
            {'id': '1', 'name': 'Item 1'},
          ],
          'totalItems': 25,
          'pageSize': 10,
          'currentPage': 1,
        };

        final result = PaginatedResult<MockDataModel>.fromJson(
          json,
          MockDataModel.fromJson,
        );

        expect(result.totalPages, equals(3)); // ceil(25/10) = 3
      });

      test('should handle edge case with zero pageSize', () {
        final json = {
          'items': [
            {'id': '1', 'name': 'Item 1'},
          ],
          'totalItems': 1,
          'pageSize': 0,
        };

        final result = PaginatedResult<MockDataModel>.fromJson(
          json,
          MockDataModel.fromJson,
        );

        expect(result.totalPages, equals(1)); // fallback when pageSize is 0
      });

      test('should filter out invalid JSON items', () {
        final json = {
          'items': [
            {'id': '1', 'name': 'Item 1'}, // valid
            'invalid string', // invalid - not a Map
            42, // invalid - not a Map
            {'id': '2', 'name': 'Item 2'}, // valid
          ],
        };

        final result = PaginatedResult<MockDataModel>.fromJson(
          json,
          MockDataModel.fromJson,
        );

        expect(result.items.length, equals(2)); // Only valid Map items
        expect(result.items[0].id, equals('1'));
        expect(result.items[0].name, equals('Item 1'));
        expect(result.items[1].id, equals('2'));
        expect(result.items[1].name, equals('Item 2'));
      });

      test('should handle null ids in data models', () {
        final json = {
          'items': [
            {'id': '1', 'name': 'Item 1'},
            {'id': null, 'name': 'Item without ID'},
            {'name': 'Item missing ID'}, // missing id field
          ],
        };

        final result = PaginatedResult<MockDataModel>.fromJson(
          json,
          MockDataModel.fromJson,
        );

        expect(result.items.length, equals(3));
        expect(result.items[0].id, equals('1'));
        expect(result.items[0].name, equals('Item 1'));
        expect(result.items[1].id, isNull);
        expect(result.items[1].name, equals('Item without ID'));
        expect(result.items[2].id, isNull);
        expect(result.items[2].name, equals('Item missing ID'));
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
        expect(json['totalItems'], equals(10));
        expect(json['totalPages'], equals(4));
        expect(json['currentPage'], equals(2));
        expect(json['pageSize'], equals(3));
      });

      test('should handle empty items list', () {
        final result = PaginatedResult<MockDataModel>.empty();
        final json = result.toJson((model) => model.toJson());

        expect(json['items'], isEmpty);
        expect(json['totalItems'], equals(0));
      });
    });

    group('toString', () {
      test('should provide meaningful string representation', () {
        final result = PaginatedResult<MockDataModel>(
          items: sampleItems,
          totalItems: 10,
          totalPages: 4,
          currentPage: 2,
          pageSize: 3,
        );

        final stringRep = result.toString();

        expect(stringRep, contains('items: 3'));
        expect(stringRep, contains('totalItems: 10'));
        expect(stringRep, contains('currentPage: 2 of 4'));
        expect(stringRep, contains('pageSize: 3'));
      });
    });

    group('_asInt helper', () {
      // Testing the static helper method indirectly through fromJson
      test('should parse various int representations', () {
        final testCases = [
          {'value': null, 'expected': null},
          {'value': 42, 'expected': 42},
          {'value': '42', 'expected': 42},
          {'value': 'invalid', 'expected': null},
          {'value': 42.5, 'expected': null}, // double should return null
        ];

        for (final testCase in testCases) {
          final json = {
            'items': [],
            'totalItems': testCase['value'],
          };

          final result = PaginatedResult<MockDataModel>.fromJson(
            json,
            MockDataModel.fromJson,
          );

          final expectedTotal = testCase['expected'] ?? 0; // fallback to items length
          expect(result.totalItems, equals(expectedTotal));
        }
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
          MockDataModel.fromJson,
        );

        expect(reconstructed.items.length, equals(original.items.length));
        expect(reconstructed.totalItems, equals(original.totalItems));
        expect(reconstructed.totalPages, equals(original.totalPages));
        expect(reconstructed.currentPage, equals(original.currentPage));
        expect(reconstructed.pageSize, equals(original.pageSize));

        for (int i = 0; i < original.items.length; i++) {
          expect(reconstructed.items[i].id, equals(original.items[i].id));
          expect(reconstructed.items[i].name, equals(original.items[i].name));
        }
      });

      test('pagination calculations should be consistent', () {
        final result = PaginatedResult<MockDataModel>(
          items: sampleItems,
          totalItems: 100,
          totalPages: 10,
          currentPage: 5,
          pageSize: 10,
        );

        // Middle page should have both next and previous
        expect(result.hasNextPage, isTrue);
        expect(result.hasPreviousPage, isTrue);

        // Index calculations
        expect(result.startIndex, equals(41)); // (5-1)*10 + 1
        expect(result.endIndex, equals(43)); // 41 + 3 - 1
      });
    });
  });
}
