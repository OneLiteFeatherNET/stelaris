import 'package:stelaris/feature/blockstate/block_state_rules.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:vulpes_data/block.dart';

/// The groups of the block picker in the order they are listed: one per block
/// family, then the remaining blocks with and without properties.
///
/// A family is told apart by its vanilla block tags. Panes, heads and the
/// pillars outside of `minecraft:logs` have no tag, those fall back to the
/// end of the key.
enum BlockGroup {
  stairs(tags: ['stairs']),
  slab(tags: ['slabs']),
  fence(tags: ['fences']),
  fenceGate(tags: ['fence_gates']),
  wall(tags: ['walls']),
  door(tags: ['doors']),
  trapdoor(tags: ['trapdoors']),
  button(tags: ['buttons']),
  pressurePlate(tags: ['pressure_plates']),
  sign(tags: ['all_signs']),
  pane(tags: ['bars'], suffixes: ['_pane']),
  bed(tags: ['beds']),
  candle(tags: ['candles', 'candle_cakes']),
  banner(tags: ['banners']),
  head(suffixes: ['_head', '_skull']),
  rail(tags: ['rails']),
  leaves(tags: ['leaves']),
  pillar(tags: ['logs'], suffixes: ['_pillar']),
  other(),
  none();

  const BlockGroup({this.tags = const [], this.suffixes = const []});

  /// The paths of the block tags whose blocks belong to the group.
  final List<String> tags;

  /// The ends of the keys of the blocks no tag covers.
  final List<String> suffixes;
}

/// The group of each block in one of the groups' tags. A block in the tags
/// of several groups belongs to the first, so the groups are walked backwards
/// and an earlier one overwrites a later one.
final Map<String, BlockGroup> _taggedGroups = {
  for (final group in BlockGroup.values.reversed)
    for (final tag in group.tags)
      for (final key in blockTags['minecraft:$tag'] ?? const <String>[])
        key: group,
};

extension BlockSpecGroup on BlockSpec {
  /// The group the block is listed under in the block picker.
  BlockGroup get group {
    if (properties.isEmpty) return BlockGroup.none;
    if (_taggedGroups[key] case final group?) return group;
    final name = key.substring(key.indexOf(':') + 1);
    return BlockGroup.values.firstWhere(
      (group) => group.suffixes.any(name.endsWith),
      orElse: () => BlockGroup.other,
    );
  }
}

extension BlockGroupLabel on BlockGroup {
  String label(AppLocalizations l10n) => switch (this) {
    BlockGroup.stairs => l10n.blockstate_group_stairs,
    BlockGroup.slab => l10n.blockstate_group_slab,
    BlockGroup.fence => l10n.blockstate_group_fence,
    BlockGroup.fenceGate => l10n.blockstate_group_fence_gate,
    BlockGroup.wall => l10n.blockstate_group_wall,
    BlockGroup.door => l10n.blockstate_group_door,
    BlockGroup.trapdoor => l10n.blockstate_group_trapdoor,
    BlockGroup.button => l10n.blockstate_group_button,
    BlockGroup.pressurePlate => l10n.blockstate_group_pressure_plate,
    BlockGroup.sign => l10n.blockstate_group_sign,
    BlockGroup.pane => l10n.blockstate_group_pane,
    BlockGroup.bed => l10n.blockstate_group_bed,
    BlockGroup.candle => l10n.blockstate_group_candle,
    BlockGroup.banner => l10n.blockstate_group_banner,
    BlockGroup.head => l10n.blockstate_group_head,
    BlockGroup.rail => l10n.blockstate_group_rail,
    BlockGroup.leaves => l10n.blockstate_group_leaves,
    BlockGroup.pillar => l10n.blockstate_group_pillar,
    BlockGroup.other => l10n.blockstate_group_other,
    BlockGroup.none => l10n.blockstate_group_none,
  };
}
