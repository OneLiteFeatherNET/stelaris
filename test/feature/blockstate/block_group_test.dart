import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/blockstate/block_group.dart';
import 'package:stelaris/feature/blockstate/block_state_rules.dart';
import 'package:vulpes_data/block.dart';

BlockGroup _groupOf(String key) =>
    allBlocks.firstWhere((block) => block.key == 'minecraft:$key').group;

void main() {
  group('block group', () {
    test('every tag of a group is a known block tag', () {
      for (final group in BlockGroup.values) {
        for (final tag in group.tags) {
          expect(
            blockTags,
            contains('minecraft:$tag'),
            reason: '${group.name} uses minecraft:$tag',
          );
        }
      }
    });

    test('groups a block by its tag', () {
      expect(_groupOf('oak_stairs'), BlockGroup.stairs);
      expect(_groupOf('nether_brick_fence'), BlockGroup.fence);
      expect(_groupOf('oak_wall_sign'), BlockGroup.sign);
      expect(_groupOf('candle_cake'), BlockGroup.candle);
      expect(_groupOf('crimson_stem'), BlockGroup.pillar);
    });

    test('falls back to the end of the key without a tag', () {
      expect(_groupOf('glass_pane'), BlockGroup.pane);
      expect(_groupOf('player_head'), BlockGroup.head);
      expect(_groupOf('quartz_pillar'), BlockGroup.pillar);
    });

    test('lists a stem outside of the logs as other', () {
      expect(_groupOf('melon_stem'), BlockGroup.other);
      expect(_groupOf('mushroom_stem'), BlockGroup.other);
    });

    test('lists a block without properties as none', () {
      expect(_groupOf('stone'), BlockGroup.none);
    });
  });
}
