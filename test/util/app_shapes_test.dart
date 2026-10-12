import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('corners come from AppShapes, not from numbers in the widgets', () {
    final number = RegExp(r'(BorderRadius|Radius)\.circular\(\d');
    final offenders = [
      for (final file in Directory('lib').listSync(recursive: true))
        if (file is File &&
            file.path.endsWith('.dart') &&
            !file.path.endsWith('app_shapes.dart'))
          for (final (index, line) in file.readAsLinesSync().indexed)
            if (number.hasMatch(line)) '${file.path}:${index + 1}',
    ];

    expect(offenders, isEmpty);
  });
}
