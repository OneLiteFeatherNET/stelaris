import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/env/environment_validator.dart';

void main() {
  test('throws assertion if value is empty', () {
    expect(
          () => EnvironmentValidator.require('', 'BACKEND_URL'),
      throwsA(isA<AssertionError>()),
    );
  });

  test('does not throw if value is present', () {
    expect(
          () => EnvironmentValidator.require('http://localhost', 'BACKEND_URL'),
      returnsNormally,
    );
  });
}
