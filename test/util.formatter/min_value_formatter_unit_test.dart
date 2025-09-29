import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/util/formatter/min_value_fomatter.dart';

void main() {
  group('MinValueFormatter', () {
    const min = 1;
    final formatter = MinValueFormatter(min);

    TextEditingValue format(String oldText, String newText, {int? cursor}) {
      return formatter.formatEditUpdate(
        TextEditingValue(
          text: oldText,
          selection: TextSelection.collapsed(offset: oldText.length),
        ),
        TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: cursor ?? newText.length),
        ),
      );
    }

    test('empty input resets to min', () {
      final result = format('2', '');
      expect(result.text, '1');
      expect(result.selection.baseOffset, '1'.length);
    });

    test('leading zero removed', () {
      final result = format('', '01');
      expect(result.text, '1');
      expect(result.selection.baseOffset, 1);
    });

    test('below min resets to min', () {
      final result = format('', '0');
      expect(result.text, '1');
      expect(result.selection.baseOffset, 1);
    });

    test('valid number stays as is', () {
      final result = format('', '21');
      expect(result.text, '21');
      expect(result.selection.baseOffset, 2);
    });

    test('multiple leading zeros collapse', () {
      final result = format('', '0007');
      expect(result.text, '7');
      expect(result.selection.baseOffset, 1);
    });
  });
}
