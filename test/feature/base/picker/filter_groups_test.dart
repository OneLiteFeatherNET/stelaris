import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/base/picker/filter_groups.dart';

const Map<String, List<String>> _groups = {
  'Stairs': ['oak_stairs', 'stone_stairs'],
  'Slabs': ['oak_slab', 'stone_slab'],
};

Map<String, List<String>> _filter(
  String search, {
  Map<String, List<String>> groups = _groups,
  String? only,
}) => filterGroups(
  groups,
  search: search,
  groupLabel: (group) => group,
  matches: (entry, search) => entry.contains(search),
  only: only,
);

void main() {
  group('filterGroups', () {
    test('empty search keeps every group', () {
      expect(_filter(''), _groups);
    });

    test('matches entries ignoring case and spaces', () {
      expect(_filter('  OAK '), {
        'Stairs': ['oak_stairs'],
        'Slabs': ['oak_slab'],
      });
    });

    test('a matching group label keeps the whole group', () {
      expect(_filter('stairs'), {
        'Stairs': ['oak_stairs', 'stone_stairs'],
      });
      final result = _filter(
        'sla',
        groups: {
          'Stairs': ['oak_stairs', 'slab_stairs'],
          'Slabs': ['oak_slab', 'stone_slab'],
        },
      );
      expect(result, {
        'Stairs': ['slab_stairs'],
        'Slabs': ['oak_slab', 'stone_slab'],
      });
      expect(result.keys, ['Stairs', 'Slabs']);
    });

    test('only limits to one group', () {
      expect(_filter('', only: 'Slabs'), {'Slabs': _groups['Slabs']});
      expect(_filter('stairs', only: 'Slabs'), isEmpty);
    });

    test('drops groups without matches', () {
      expect(_filter('birch'), isEmpty);
    });
  });
}
