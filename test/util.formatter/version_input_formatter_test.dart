import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/util/formatter/version_input_formatter.dart';

void main() {

  const formatter = VersionInputFormatter();
  
  group('VersionInputFormatter', () {
    TextEditingValue oldValue(String text) =>
        TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));

    test('allows digits only', () {
      final old = oldValue('');
      final newValue = oldValue('123');
      final result = formatter.formatEditUpdate(old, newValue);

      expect(result.text, '123');
    });

    test('allows digits with dots', () {
      final old = oldValue('');
      final newValue = oldValue('1.2.3');
      final result = formatter.formatEditUpdate(old, newValue);

      expect(result.text, '1.2.3');
    });

    test('rejects letters', () {
      final old = oldValue('1.2');
      final newValue = oldValue('1.2a');
      final result = formatter.formatEditUpdate(old, newValue);

      expect(result.text, '1.2'); // unchanged (old value kept)
    });

    test('rejects special characters', () {
      final old = oldValue('2');
      final newValue = oldValue('2-3');
      final result = formatter.formatEditUpdate(old, newValue);

      expect(result.text, '2');
    });

    test('accepts empty input', () {
      final old = oldValue('1.2');
      final newValue = oldValue('');
      final result = formatter.formatEditUpdate(old, newValue);

      expect(result.text, '');
    });
  });
}