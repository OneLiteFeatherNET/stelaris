import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/blockstate/block_state_rules.dart';
import 'package:stelaris_models/stelaris_models.dart';

BlockStateModel _context(String name, List<BlockStateRule> rules) =>
    BlockStateModel(
      id: name,
      uiName: name,
      key: 'minecraft:note_block',
      rules: rules,
    );

void main() {
  final spec = specFor('minecraft:note_block');

  BlockStateRule notes(List<String> values) => BlockStateRule(
    when: {
      'instrument': ['harp'],
      'note': values,
    },
  );

  test('counts the states other contexts claim per rule', () {
    final overlaps = overlapsOf(
      [
        notes(['0', '1', '2']),
        notes(['5']),
      ],
      [
        _context('Decoration', [
          notes(['2', '3']),
        ]),
      ],
      spec,
    );

    final powered = spec.properties['powered']!.length;
    expect(overlaps[0].names, {'Decoration'});
    expect(overlaps[0].count, powered);
    expect(overlaps[1].count, 0);
    expect(overlaps[1].names, isEmpty);
  });

  test('finds nothing without other contexts', () {
    final [overlap] = overlapsOf([const BlockStateRule()], const [], spec);
    expect(overlap.count, 0);
    expect(overlap.names, isEmpty);
  });
}
