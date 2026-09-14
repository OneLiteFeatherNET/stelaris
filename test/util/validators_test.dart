import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/util/validators.dart';

void main() {
  group('Validators.adventureKeyPart', () {
    final validator = Validators.adventureKeyPart();

    test('valid keys return null', () {
      expect(validator('ruby_sword'), isNull);
      expect(validator('sword'), isNull);
      expect(validator('item/weapon/sword'), isNull);
      expect(validator('magic.wand'), isNull);
      expect(validator('item-1'), isNull);
      expect(validator('path/to/my-item_v2.0'), isNull);
    });

    test('empty or whitespace returns required message', () {
      expect(validator(''), 'Key is required');
      expect(validator('   '), 'Key is required');
      expect(validator(null), 'Key is required');
    });

    test('uppercase letters are rejected with descriptive message', () {
      expect(validator('Ruby_sword'), 'Uppercase letters are not allowed');
      expect(validator('SWORD'), 'Uppercase letters are not allowed');
    });

    test('spaces are rejected', () {
      expect(validator('ruby sword'), 'Spaces are not allowed');
    });

    test('colons are rejected in key part', () {
      expect(validator('minecraft:sword'), 'Colons (:) are not allowed in the key part');
      expect(validator(':sword'), 'Colons (:) are not allowed in the key part');
    });

    test('double dots are rejected', () {
      expect(validator('item..sword'), 'Double dots (..) are not allowed');
    });

    test('disallowed characters return invalid message', () {
      expect(validator('sword!'), contains('Invalid key'));
      expect(validator('item#1'), contains('Invalid key'));
      expect(validator('item@test'), contains('Invalid key'));
    });

    test('non-detailed validator returns invalid message or required message', () {
      final nonDetailed = Validators.adventureKeyPart(detailed: false);
      expect(nonDetailed(''), 'Key is required');
      expect(nonDetailed('Ruby_sword'), contains('Invalid key'));
      expect(nonDetailed('ruby_sword'), isNull);
    });
  });
}
