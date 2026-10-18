import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/validators.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  group('Validators.adventureKeyPart', () {
    final validator = Validators.adventureKeyPart(l10n);

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
      final nonDetailed = Validators.adventureKeyPart(l10n, detailed: false);
      expect(nonDetailed(''), 'Key is required');
      expect(nonDetailed('Ruby_sword'), contains('Invalid key'));
      expect(nonDetailed('ruby_sword'), isNull);
    });
  });

  group('Validators.enchantmentLevel', () {
    test('levels up to the max level are valid', () {
      expect(Validators.enchantmentLevel(l10n, value: '1', maxLevel: 5), isNull);
      expect(Validators.enchantmentLevel(l10n, value: '5', maxLevel: 5), isNull);
    });

    test('levels above the max level are rejected unless unsafe', () {
      expect(
        Validators.enchantmentLevel(l10n, value: '6', maxLevel: 5),
        'The maximum is 5',
      );
      expect(
        Validators.enchantmentLevel(l10n, value: '6', maxLevel: 5, unsafe: true),
        isNull,
      );
    });

    test('unsafe levels are limited to the range of a short', () {
      expect(
        Validators.enchantmentLevel(
          l10n,
          value: '$maxEnchantmentLevel',
          maxLevel: 5,
          unsafe: true,
        ),
        isNull,
      );
      expect(
        Validators.enchantmentLevel(
          l10n,
          value: '${maxEnchantmentLevel + 1}',
          maxLevel: 5,
          unsafe: true,
        ),
        'The maximum is $maxEnchantmentLevel',
      );
    });

    test('empty and invalid input is rejected', () {
      expect(
        Validators.enchantmentLevel(l10n, value: null, maxLevel: 5),
        'Please enter a level',
      );
      expect(
        Validators.enchantmentLevel(l10n, value: ' ', maxLevel: 5),
        'Please enter a level',
      );
      expect(
        Validators.enchantmentLevel(l10n, value: 'abc', maxLevel: 5),
        'Please enter a valid number',
      );
    });
  });

  group('Validators.integer', () {
    final validator = Validators.integer(l10n);

    test('whole numbers pass, negative ones included', () {
      expect(validator('0'), isNull);
      expect(validator('7'), isNull);
      expect(validator('-4'), isNull);
    });

    test('empty, a lone minus and invalid input are rejected', () {
      expect(validator(null), 'Please enter a valid number');
      expect(validator(''), 'Please enter a valid number');
      expect(validator('-'), 'Please enter a valid number');
      expect(validator('abc'), 'Please enter a valid number');
    });
  });

  group('Validators.minimum', () {
    final validator = Validators.minimum(l10n, 1);

    test('numbers at or above the minimum pass', () {
      expect(validator('1'), isNull);
      expect(validator('16'), isNull);
    });

    test('numbers below the minimum are rejected', () {
      expect(validator('0'), 'The minimum is 1');
      expect(validator('-3'), 'The minimum is 1');
    });

    test('empty and invalid input is rejected', () {
      expect(validator(null), 'Please enter a valid number');
      expect(validator(''), 'Please enter a valid number');
      expect(validator('abc'), 'Please enter a valid number');
    });
  });

  group('Validators.maximum', () {
    final validator = Validators.maximum(l10n, 8);

    test('numbers at or below the maximum pass', () {
      expect(validator('8'), isNull);
      expect(validator('0'), isNull);
      expect(validator('-3'), isNull);
    });

    test('numbers above the maximum are rejected', () {
      expect(validator('9'), 'The maximum is 8');
    });

    test('empty and invalid input is rejected', () {
      expect(validator(null), 'Please enter a valid number');
      expect(validator('-'), 'Please enter a valid number');
      expect(validator('abc'), 'Please enter a valid number');
    });
  });
}
