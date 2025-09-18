import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/converter/paginated_result_converter.dart';
import 'package:stelaris/api/paginated_result.dart';

import '../../test_model.dart';

Map<String, dynamic> testModelToJson(TestModel model) => model.toJson();

void main() {
  group('test generic paginated result converter unit test', () {
    const converter = GenericPaginatedResultConverter<TestModel>(
      fromJsonT: TestModel.fromJson,
      toJsonT: testModelToJson,
    );

    final testModel1 = TestModel(internalId: 1, name: 'Item 1');
    final testModel2 = TestModel(internalId: 2, name: 'Item 2');

    final paginatedResultObject = PaginatedResult<TestModel>(
      items: [testModel1, testModel2],
      totalItems: 10,
      totalPages: 5,
      currentPage: 1,
      pageSize: 2,
    );

    // The JSON structure remains the same as before.
    final paginatedResultJson = {
      'items': [
        {'id': 1, 'name': 'Item 1'},
        {'id': 2, 'name': 'Item 2'},
      ],
      'totalItems': 10,
      'totalPages': 5,
      'currentPage': 1,
      'pageSize': 2,
    };

    test('fromJson should correctly deserialize a JSON map', () {
      final result = converter.fromJson(paginatedResultJson);

      expect(result, isA<PaginatedResult<TestModel>>());
      expect(result.totalItems, paginatedResultObject.totalItems);
      expect(result.items, equals(paginatedResultObject.items));
      // You can also test the DataModel contract implementation
      expect(result.items.first.id, '1');
    });

    test('toJson should correctly serialize a PaginatedResult object', () {
      final result = converter.toJson(paginatedResultObject);
      expect(result, equals(paginatedResultJson));
    });
  });
}
