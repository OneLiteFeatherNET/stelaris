// SPIKE: throwaway proof of concept for rule based blockstate editing.
import 'package:flutter/foundation.dart';
import 'package:stelaris/feature/blockstate/block_state_rules.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Keeps the blockstates in memory only: they are gone after a reload.
final class BlockStateStore extends ChangeNotifier {
  BlockStateStore._();

  static final BlockStateStore shared = BlockStateStore._();

  int _nextId = 1;

  static final BlockSpec _petals = specFor('minecraft:pink_petals');

  late final List<BlockStateModel> _entries = [
    BlockStateModel(
      id: '${_nextId++}',
      uiName: 'Footprints',
      key: _petals.key,
      comment: 'Spuren auf dem Boden, ersetzt die Pink Petals.',
      creationDate: DateTime.now(),
      rules: [
        for (final (amount, model) in const [
          ('1', 'minecraft:block/footprint_slender'),
          ('2', 'minecraft:block/footprint_survivor'),
          ('3', 'minecraft:block/footprint_slender_faded'),
          ('4', 'minecraft:block/footprint_survivor_faded'),
        ])
          ...expandFacing(
            BlockStateRule(
              model: model,
              when: {
                'flower_amount': [amount],
              },
            ),
            _petals,
          ),
      ],
    ),
    BlockStateModel(
      id: '${_nextId++}',
      uiName: 'Möbel',
      key: 'minecraft:note_block',
      comment: 'Stühle und Tische auf der Harfe.',
      creationDate: DateTime.now(),
      rules: const [
        BlockStateRule(
          when: {
            'instrument': ['harp'],
            'note': ['0', '1', '2'],
          },
          model: 'minecraft:block/chair',
        ),
      ],
    ),
    BlockStateModel(
      id: '${_nextId++}',
      uiName: 'Deko',
      key: 'minecraft:note_block',
      creationDate: DateTime.now(),
      rules: const [
        BlockStateRule(
          when: {
            'instrument': ['harp'],
            'note': ['2', '3'],
          },
          model: 'minecraft:block/vase',
        ),
      ],
    ),
  ];

  List<BlockStateModel> get entries => List.unmodifiable(_entries);

  /// The other contexts of [entry]'s block. The export writes them all
  /// into one file.
  List<BlockStateModel> othersOf(BlockStateModel entry) => [
    for (final other in _entries)
      if (other.key == entry.key && other.id != entry.id) other,
  ];

  /// How many blockstates use each block.
  Map<String, int> get contextCounts {
    final counts = <String, int>{};
    for (final entry in _entries) {
      if (entry.key case final key?) counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  BlockStateModel? byId(String? id) {
    for (final entry in _entries) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  BlockStateModel add(String uiName, BlockSpec block) {
    final entry = BlockStateModel(
      id: '${_nextId++}',
      uiName: uiName,
      key: block.key,
      rules: const [BlockStateRule()],
      creationDate: DateTime.now(),
    );
    _entries.add(entry);
    notifyListeners();
    return entry;
  }

  void update(BlockStateModel entry) {
    final index = _entries.indexWhere((other) => other.id == entry.id);
    if (index < 0) return;
    _entries[index] = entry.copyWith(modificationDate: DateTime.now());
    notifyListeners();
  }

  void remove(String? id) {
    _entries.removeWhere((entry) => entry.id == id);
    notifyListeners();
  }
}
