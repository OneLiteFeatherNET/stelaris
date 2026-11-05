// SPIKE: throwaway proof of concept for rule based blockstate editing.
import 'package:stelaris_models/stelaris_models.dart';
import 'package:vulpes_data/block.dart';

/// A vulpes [BlockStateSpec] with every property reduced to its allowed
/// values, which is all the rules need.
final class BlockSpec {
  final String key;
  final String displayName;
  final Map<String, List<String>> properties;
  final Map<String, String> defaults;

  const BlockSpec(this.key, this.displayName, this.properties, this.defaults);

  /// How many states the block has.
  int get stateCount =>
      properties.values.fold(1, (count, values) => count * values.length);

  /// Every state of the block, as property -> value.
  Iterable<Map<String, String>> get states sync* {
    final names = properties.keys.toList();
    if (names.isEmpty) {
      yield const {};
      return;
    }
    final indices = List.filled(names.length, 0);
    while (true) {
      yield {
        for (var i = 0; i < names.length; i++)
          names[i]: properties[names[i]]![indices[i]],
      };
      var position = names.length - 1;
      while (position >= 0) {
        indices[position]++;
        if (indices[position] < properties[names[position]]!.length) break;
        indices[position] = 0;
        position--;
      }
      if (position < 0) return;
    }
  }
}

List<String> _valuesOf(ComponentSchema schema) => switch (schema) {
  EnumSchema(:final values) => values,
  BoolSchema() => const ['false', 'true'],
  IntSchema(:final min, :final max) => [
    for (var i = min ?? 0; i <= (max ?? 0); i++) '$i',
  ],
  _ => const [],
};

/// Every block of vulpes, sorted by key.
final List<BlockSpec> allBlocks = [
  for (final spec in blockStates)
    BlockSpec(spec.key, spec.displayName, {
      for (final MapEntry(key: name, value: schema) in spec.properties.entries)
        name: _valuesOf(schema),
    }, spec.defaults),
];

final Map<String, BlockSpec> _blocksByKey = {
  for (final block in allBlocks) block.key: block,
};

/// The block with [key], stone for an unknown key.
BlockSpec specFor(String? key) =>
    _blocksByKey[key] ?? _blocksByKey['minecraft:stone']!;

extension BlockStateRuleEdit on BlockStateRule {
  /// Adds [value] to the allowed values of [property], or removes it.
  BlockStateRule toggle(String property, String value) {
    final values = [...?when[property]];
    if (!values.remove(value)) values.add(value);
    return copyWith(when: {...when, property: values});
  }
}

const Map<String, ({int x, int y})> _facingRotation = {
  'north': (x: 0, y: 0),
  'east': (x: 0, y: 90),
  'south': (x: 0, y: 180),
  'west': (x: 0, y: 270),
  'up': (x: 270, y: 0),
  'down': (x: 90, y: 0),
};

/// Splits [rule] into one rule per value of `facing`, each rotated so that a
/// model built facing north points the right way.
List<BlockStateRule> expandFacing(BlockStateRule rule, BlockSpec spec) {
  final selected = rule.when['facing'] ?? const [];
  final values = (spec.properties['facing'] ?? const <String>[]).where(
    (value) => selected.isEmpty || selected.contains(value),
  );
  return [
    for (final value in values)
      rule.copyWith(
        when: {
          ...rule.when,
          'facing': [value],
        },
        x: (rule.x + (_facingRotation[value]?.x ?? 0)) % 360,
        y: (rule.y + (_facingRotation[value]?.y ?? 0)) % 360,
      ),
  ];
}

/// The states of [spec] no rule gives a model.
List<Map<String, String>> uncoveredStates(
  List<BlockStateRule> rules,
  BlockSpec spec,
) => [
  for (final state in spec.states)
    if (!rules.any((rule) => rule.matches(state))) state,
];

/// The blockstate file for [rules], written as `multipart`.
Map<String, Object> toMultipart(List<BlockStateRule> rules, BlockSpec spec) => {
  'multipart': [
    for (final rule in rules)
      {
        if (_when(rule, spec) case final condition when condition.isNotEmpty)
          'when': condition,
        'apply': {
          'model': rule.model.isEmpty ? 'minecraft:block/stone' : rule.model,
          if (rule.x != 0) 'x': rule.x,
          if (rule.y != 0) 'y': rule.y,
          if (rule.uvlock) 'uvlock': true,
        },
      },
  ],
};

Map<String, String> _when(BlockStateRule rule, BlockSpec spec) => {
  for (final entry in rule.when.entries)
    // Selecting every value is the same as selecting none.
    if (entry.value.isNotEmpty &&
        entry.value.length < (spec.properties[entry.key]?.length ?? 0))
      entry.key: [
        for (final value in spec.properties[entry.key]!)
          if (entry.value.contains(value)) value,
      ].join('|'),
};
