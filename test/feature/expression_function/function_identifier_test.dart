import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/expression_function/function_identifier.dart';

void main() {
  group('functionIdentifierFor', () {
    test('keeps a name that already is an identifier', () {
      expect(functionIdentifierFor('damage_bonus'), 'damage_bonus');
    });

    test('replaces the characters an identifier cannot hold', () {
      expect(functionIdentifierFor('Damage bonus!'), 'Damage_bonus_');
    });

    test('puts an underscore in front of a leading digit', () {
      expect(functionIdentifierFor('3d hit'), '_3d_hit');
    });

    test('falls back to function for a blank name', () {
      expect(functionIdentifierFor('   '), 'function');
    });
  });
}
