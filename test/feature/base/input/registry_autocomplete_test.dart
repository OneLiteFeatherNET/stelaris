import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/base/input/registry_autocomplete.dart';

void main() {
  List<String> keys(String registry, String query) => [
    for (final entry in suggestRegistry(registry, query)) entry.key,
  ];

  group('suggestRegistry', () {
    test('matches every word of the query against the name', () {
      expect(
        keys('sound_event', 'zombie hurt'),
        contains('minecraft:entity.zombie.hurt'),
      );
    });

    test('accepts the namespace in the query', () {
      expect(keys('damage_type', 'minecraft:arrow').first, 'minecraft:arrow');
    });

    test('puts the entries starting with the query first', () {
      // indirect_magic comes first in the registry, but only contains it.
      expect(keys('damage_type', 'magic'), [
        'minecraft:magic',
        'minecraft:indirect_magic',
      ]);
    });

    test('suggests at most eight entries', () {
      expect(keys('sound_event', 'block').length, maxRegistrySuggestions);
      expect(maxRegistrySuggestions, 8);
    });

    test('suggests nothing for an empty query', () {
      expect(keys('sound_event', '  '), isEmpty);
    });

    test('suggests nothing for an unknown registry', () {
      expect(suggestsRegistry('recipe'), isFalse);
      expect(keys('recipe', 'stone'), isEmpty);
    });

    test('knows the registries vulpes_data has entries for', () {
      for (final registry in [
        'sound_event',
        'damage_type',
        'trim_material',
        'trim_pattern',
        'banner_pattern',
        'instrument',
        'jukebox_song',
        'painting_variant',
      ]) {
        expect(suggestsRegistry(registry), isTrue, reason: registry);
      }
    });
  });
}
