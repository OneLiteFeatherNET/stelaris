import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/formatter/formatters.dart';

void main() {
  group('decimalFormatter', () {
    TextEditingValue val(String text) => TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );

    String format(String oldText, String newText) =>
        decimalFormatter.formatEditUpdate(val(oldText), val(newText)).text;

    test('accepts whole, decimal and negative numbers', () {
      expect(format('', '0'), '0');
      expect(format('0.0', '0.08'), '0.08');
      expect(format('-102', '-1024'), '-1024');
    });

    test('accepts unfinished numbers while typing', () {
      expect(format('', '-'), '-');
      expect(format('1', '1.'), '1.');
      expect(format('', '.5'), '.5');
    });

    test('rejects edits that leave no number', () {
      expect(format('1', '1a'), '1');
      expect(format('1.5', '1.5.'), '1.5');
      expect(format('1', '1-'), '1');
    });
  });
}
