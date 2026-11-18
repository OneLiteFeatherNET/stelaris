import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/util/bytes.dart';

void main() {
  test('a Uint8List is used as it is', () {
    final bytes = Uint8List.fromList([1, 2, 3]);

    expect(identical(asUint8List(bytes), bytes), isTrue);
  });

  test('any other list is copied into a Uint8List', () {
    final bytes = <int>[1, 2, 3];

    final result = asUint8List(bytes);

    expect(result, isA<Uint8List>());
    expect(result, [1, 2, 3]);
  });
}
