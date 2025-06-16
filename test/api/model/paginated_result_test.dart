import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/model/data_model.dart';
import 'package:stelaris/api/paginated_result.dart';

// Create a simple test model that implements DataModel
class TestModel with DataModel {
  final String id;
  final String name;

  TestModel({required this.id, required this.name});

  // For JSON serialization tests
  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      id: json['id'].toString(),
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

void main() {
  group('PaginatedResult', () {
    // Sample data for tests
    final testItems = [
      TestModel(id: '1', name: 'Item 1'),
      TestModel(id: '2', name: 'Item 2'),
      TestModel(id: '3', name: 'Item 3'),
    ];

    test('constructor creates instance with correct values', () {
      final result = PaginatedResult<TestModel>(
        items: testItems,
        totalItems: 10,
        totalPages: 4,
        currentPage: 1,
        pageSize: 3,
      );

      expect(result.items, equals(testItems));
      expect(result.totalItems, equals(10));
      expect(result.totalPages, equals(4));
      expect(result.currentPage, equals(1));
      expect(result.pageSize, equals(3));
    });

    test('hasNextPage returns correct value', () {
      // First page with more pages available
      final firstPage = PaginatedResult<TestModel>(
        items: testItems,
        totalItems: 10,
        totalPages: 4,
        currentPage: 1,
        pageSize: 3,
      );
      expect(firstPage.hasNextPage, isTrue);

      // Last page with no more pages available
      final lastPage = PaginatedResult<TestModel>(
        items: testItems,
        totalItems: 10,
        totalPages: 4,
        currentPage: 4,
        pageSize: 3,
      );
      expect(lastPage.hasNextPage, isFalse);
    });

    test('hasPreviousPage returns correct value', () {
      // First page with no previous pages
      final firstPage = PaginatedResult<TestModel>(
        items: testItems,
        totalItems: 10,
        totalPages: 4,
        currentPage: 1,
        pageSize: 3,
      );
      expect(firstPage.hasPreviousPage, isFalse);

      // Second page with previous page available
      final secondPage = PaginatedResult<TestModel>(
        items: testItems,
        totalItems: 10,
        totalPages: 4,
        currentPage: 2,
        pageSize: 3,
      );
      expect(secondPage.hasPreviousPage, isTrue);
    });

    test('startIndex calculates correctly', () {
      // First page
      final firstPage = PaginatedResult<TestModel>(
        items: testItems,
        totalItems: 10,
        totalPages: 4,
        currentPage: 1,
        pageSize: 3,
      );
      expect(firstPage.startIndex, equals(1));

      // Second page
      final secondPage = PaginatedResult<TestModel>(
        items: testItems,
        totalItems: 10,
        totalPages: 4,
        currentPage: 2,
        pageSize: 3,
      );
      expect(secondPage.startIndex, equals(4));
    });

    test('endIndex calculates correctly', () {
      // Page with full items
      final fullPage = PaginatedResult<TestModel>(
        items: testItems, // 3 items
        totalItems: 10,
        totalPages: 4,
        currentPage: 1,
        pageSize: 3,
      );
      expect(fullPage.endIndex, equals(3));

      // Page with partial items (last page)
      final partialItems = [TestModel(id: '10', name: 'Last Item')];
      final partialPage = PaginatedResult<TestModel>(
        items: partialItems, // 1 item
        totalItems: 10,
        totalPages: 4,
        currentPage: 4,
        pageSize: 3,
      );
      expect(partialPage.endIndex, equals(10));
    });

    test('copyWith creates a new instance with updated values', () {
      final original = PaginatedResult<TestModel>(
        items: testItems,
        totalItems: 10,
        totalPages: 4,
        currentPage: 1,
        pageSize: 3,
      );

      final newItems = [TestModel(id: '4', name: 'Item 4')];
      final copied = original.copyWith(
        items: newItems,
        currentPage: 2,
      );

      // Check that specified values were updated
      expect(copied.items, equals(newItems));
      expect(copied.currentPage, equals(2));

      // Check that unspecified values were preserved
      expect(copied.totalItems, equals(original.totalItems));
      expect(copied.totalPages, equals(original.totalPages));
      expect(copied.pageSize, equals(original.pageSize));

      // Ensure original was not modified
      expect(original.items, equals(testItems));
      expect(original.currentPage, equals(1));
    });

    test('empty factory creates empty paginated result', () {
      final empty = PaginatedResult<TestModel>.empty();

      expect(empty.items, isEmpty);
      expect(empty.totalItems, equals(0));
      expect(empty.totalPages, equals(0));
      expect(empty.currentPage, equals(1));
      expect(empty.pageSize, equals(0));
    });

    group('JSON serialization', () {
      test('fromJson creates correct instance', () {
        final json = {
          'items': [
            {'id': '1', 'name': 'Item 1'},
            {'id': '2', 'name': 'Item 2'},
          ],
          'totalItems': 10,
          'totalPages': 5,
          'currentPage': 1,
          'pageSize': 2,
        };

        final result = PaginatedResult<TestModel>.fromJson(
          json,
          TestModel.fromJson,
        );

        expect(result.items.length, equals(2));
        expect(result.items[0].id, equals('1'));
        expect(result.items[0].name, equals('Item 1'));
        expect(result.items[1].id, equals('2'));
        expect(result.items[1].name, equals('Item 2'));
        expect(result.totalItems, equals(10));
        expect(result.totalPages, equals(5));
        expect(result.currentPage, equals(1));
        expect(result.pageSize, equals(2));
      });

      test('fromJson handles missing fields gracefully', () {
        final json = {
          'items': [
            {'id': '1', 'name': 'Item 1'},
          ],
        };

        final result = PaginatedResult<TestModel>.fromJson(
          json,
          TestModel.fromJson,
        );

        expect(result.items.length, equals(1));
        expect(result.items[0].id, equals('1'));
        expect(result.totalItems, equals(0));
        expect(result.totalPages, equals(0));
        expect(result.currentPage, equals(1));
        expect(result.pageSize, equals(1)); // Defaults to items.length
      });

      test('toJson creates correct map', () {
        final result = PaginatedResult<TestModel>(
          items: testItems,
          totalItems: 10,
          totalPages: 4,
          currentPage: 1,
          pageSize: 3,
        );

        final json = result.toJson((item) => item.toJson());

        expect(json['items'].length, equals(3));
        expect(json['items'][0]['id'], equals('1'));
        expect(json['items'][0]['name'], equals('Item 1'));
        expect(json['totalItems'], equals(10));
        expect(json['totalPages'], equals(4));
        expect(json['currentPage'], equals(1));
        expect(json['pageSize'], equals(3));
      });
    });

    test('toString returns formatted string', () {
      final result = PaginatedResult<TestModel>(
        items: testItems,
        totalItems: 10,
        totalPages: 4,
        currentPage: 1,
        pageSize: 3,
      );

      final string = result.toString();
      
      expect(string, contains('items: 3'));
      expect(string, contains('totalItems: 10'));
      expect(string, contains('currentPage: 1 of 4'));
      expect(string, contains('pageSize: 3'));
    });
  });
}
