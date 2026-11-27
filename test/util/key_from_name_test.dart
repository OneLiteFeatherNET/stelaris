import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/key_from_name.dart';

void main() {
  group('keyFromName', () {
    test('lower-cases the name and joins words with underscores', () {
      expect(keyFromName('My Sword'), 'my_sword');
    });

    test('spells out umlauts and ß', () {
      expect(keyFromName('Größe Übung'), 'groesse_uebung');
    });

    test('reads other characters as one underscore and trims them', () {
      expect(keyFromName('  Ruby -- Sword!! '), 'ruby_--_sword');
      expect(keyFromName('(Epic) Bow'), 'epic_bow');
    });

    test('keeps digits, dots, dashes and underscores', () {
      expect(keyFromName('Sword v1.2-beta_x'), 'sword_v1.2-beta_x');
    });

    test('collapses double dots', () {
      expect(keyFromName('Wait... what'), 'wait._what');
    });

    test('is empty for a name without usable characters', () {
      expect(keyFromName(''), '');
      expect(keyFromName('!!!'), '');
    });

    test('always yields a valid key part when not empty', () {
      for (final name in [
        'My Sword',
        'Ä..b',
        'a / b',
        'Schwert Lvl. 2 für Bosse!',
      ]) {
        expect(
          adventureKeyPartPattern.hasMatch(keyFromName(name)),
          isTrue,
          reason: name,
        );
      }
    });
  });
}
