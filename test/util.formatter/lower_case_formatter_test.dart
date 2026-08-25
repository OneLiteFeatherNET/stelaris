import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/formatter/lower_case_formatter.dart';

void main() {
  const formatter = LowerCaseTextFormatter();

  group('LowerCaseTextFormatter', () {
    TextEditingValue val(String text) =>
        TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));

    test('converts uppercase letters to lowercase', () {
      final oldVal = val('');
      final newVal = val('MyProject');
      final result = formatter.formatEditUpdate(oldVal, newVal);

      expect(result.text, 'myproject');
    });

    test('replaces spaces with underscores when replaceSpaces is true', () {
      final oldVal = val('');
      final newVal = val('my project name');
      final result = formatter.formatEditUpdate(oldVal, newVal);

      expect(result.text, 'my_project_name');
    });

    test('preserves text if already lowercase and no spaces', () {
      final oldVal = val('');
      final newVal = val('minecraft:iron_sword');
      final result = formatter.formatEditUpdate(oldVal, newVal);

      expect(result.text, 'minecraft:iron_sword');
    });

    test('retains spaces if replaceSpaces is false', () {
      const noSpaceFormatter = LowerCaseTextFormatter(replaceSpaces: false);
      final oldVal = val('');
      final newVal = val('My Project');
      final result = noSpaceFormatter.formatEditUpdate(oldVal, newVal);

      expect(result.text, 'my project');
    });
  });
}
