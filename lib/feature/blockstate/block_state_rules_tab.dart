// SPIKE: throwaway proof of concept for rule based blockstate editing.
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/blockstate/block_state_rules.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The rules of a blockstate: the rules on the left, a state to try them
/// on and the coverage of the block on the right.
///
/// Every blockstate is a context of its own. The [others] are the contexts
/// of the same block: the export writes all of them into one file, so the
/// states they claim are shown next to the own ones, and a state claimed
/// twice is a conflict, `multipart` would draw both models.
class BlockStateRulesTab extends StatefulWidget {
  const BlockStateRulesTab({
    required this.entry,
    required this.others,
    required this.onChanged,
    super.key,
  });

  final BlockStateModel entry;
  final List<BlockStateModel> others;
  final ValueChanged<BlockStateModel> onChanged;

  @override
  State<BlockStateRulesTab> createState() => _BlockStateRulesTabState();
}

class _BlockStateRulesTabState extends State<BlockStateRulesTab> {
  /// Bumped whenever the rules are replaced as a whole, so the model fields
  /// pick up their new text.
  int _generation = 0;
  late Map<String, String> _probe = {..._spec.defaults};

  @override
  void didUpdateWidget(BlockStateRulesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.key != widget.entry.key) {
      _probe = {..._spec.defaults};
      _generation++;
    }
  }

  BlockSpec get _spec => specFor(widget.entry.key);
  List<BlockStateRule> get _rules => widget.entry.rules;

  void _setRules(List<BlockStateRule> rules) =>
      widget.onChanged(widget.entry.copyWith(rules: rules));

  void _update(int index, BlockStateRule rule) =>
      _setRules([..._rules]..[index] = rule);

  void _replace(int index, List<BlockStateRule> rules) {
    setState(() => _generation++);
    _setRules([..._rules]..replaceRange(index, index + 1, rules));
  }

  /// The names of the other contexts claiming [state].
  List<String> _claimedBy(Map<String, String> state) => [
    for (final other in widget.others)
      if (other.rules.any((rule) => rule.matches(state))) other.uiName,
  ];

  @override
  Widget build(BuildContext context) {
    final states = _spec.states.toList();
    final claims = [for (final state in states) _claimedBy(state)];
    var own = 0;
    final free = <Map<String, String>>[];
    final conflicting = <Map<String, String>>[];
    for (final (index, state) in states.indexed) {
      final mine = _rules.any((rule) => rule.matches(state));
      if (mine) own++;
      if (mine && claims[index].isNotEmpty) {
        conflicting.add(state);
      }
      if (!mine && claims[index].isEmpty) free.add(state);
    }

    /// Per rule the names of the contexts it overlaps and on how many states.
    ({Set<String> names, int count}) overlapOf(BlockStateRule rule) {
      final names = <String>{};
      var count = 0;
      for (final (index, state) in states.indexed) {
        if (claims[index].isEmpty || !rule.matches(state)) continue;
        count++;
        names.addAll(claims[index]);
      }
      return (names: names, count: count);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView(
              children: [
                for (final (index, rule) in _rules.indexed)
                  _RuleCard(
                    key: ValueKey('$_generation-$index'),
                    index: index,
                    spec: _spec,
                    rule: rule,
                    active: rule.matches(_probe),
                    overlap: overlapOf(rule),
                    onChanged: (rule) => _update(index, rule),
                    onDelete: () => _replace(index, const []),
                    onExpandFacing: _spec.properties.containsKey('facing')
                        ? () => _replace(index, expandFacing(rule, _spec))
                        : null,
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.tonalIcon(
                      onPressed: () =>
                          _setRules([..._rules, const BlockStateRule()]),
                      icon: const Icon(Icons.add),
                      label: const Text('Regel hinzufügen'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 400,
            child: ListView(
              children: [
                _ProbeCard(
                  spec: _spec,
                  probe: _probe,
                  rules: _rules,
                  others: widget.others,
                  onChanged: (probe) => setState(() => _probe = probe),
                ),
                _CoverageCard(
                  total: states.length,
                  own: own,
                  conflicts: conflicting,
                  free: free,
                  contexts: widget.others.length + 1,
                  onPick: (state) => setState(() => _probe = state),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.index,
    required this.spec,
    required this.rule,
    required this.active,
    required this.overlap,
    required this.onChanged,
    required this.onDelete,
    required this.onExpandFacing,
    super.key,
  });

  final int index;
  final BlockSpec spec;
  final BlockStateRule rule;
  final bool active;

  /// The other contexts claiming states of this rule, and how many.
  final ({Set<String> names, int count}) overlap;
  final ValueChanged<BlockStateRule> onChanged;
  final VoidCallback onDelete;
  final VoidCallback? onExpandFacing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: active ? scheme.primary : scheme.outlineVariant,
          width: active ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Regel ${index + 1}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (active) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.bolt, size: 18, color: scheme.primary),
                ],
                const Spacer(),
                if (onExpandFacing != null)
                  TextButton.icon(
                    onPressed: onExpandFacing,
                    icon: const Icon(Icons.rotate_90_degrees_cw_outlined),
                    label: const Text('Pro facing drehen'),
                  ),
                IconButton(
                  tooltip: 'Löschen',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            if (overlap.count > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: scheme.error,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${overlap.count} ${overlap.count == 1 ? 'Zustand ist' : 'Zustände sind'} '
                        'auch in ${overlap.names.map((name) => '„$name“').join(', ')} belegt',
                        style: TextStyle(color: scheme.error),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Text('Wenn', style: Theme.of(context).textTheme.labelLarge),
            for (final MapEntry(key: property, value: values)
                in spec.properties.entries)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(property),
                      ),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          for (final value in values)
                            FilterChip(
                              visualDensity: VisualDensity.compact,
                              label: Text(value),
                              selected:
                                  rule.when[property]?.contains(value) ?? false,
                              onSelected: (_) =>
                                  onChanged(rule.toggle(property, value)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Text('Dann', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            TextFormField(
              initialValue: rule.model,
              decoration: const InputDecoration(
                labelText: 'Modell',
                hintText: 'minecraft:block/footprint_slender',
                isDense: true,
              ),
              onChanged: (model) => onChanged(rule.copyWith(model: model)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _RotationPicker(
                  axis: 'x',
                  value: rule.x,
                  onChanged: (x) => onChanged(rule.copyWith(x: x)),
                ),
                _RotationPicker(
                  axis: 'y',
                  value: rule.y,
                  onChanged: (y) => onChanged(rule.copyWith(y: y)),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('uvlock'),
                    Switch(
                      value: rule.uvlock,
                      onChanged: (uvlock) =>
                          onChanged(rule.copyWith(uvlock: uvlock)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RotationPicker extends StatelessWidget {
  const _RotationPicker({
    required this.axis,
    required this.value,
    required this.onChanged,
  });

  final String axis;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(axis),
      const SizedBox(width: 8),
      SegmentedButton<int>(
        showSelectedIcon: false,
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
        segments: [
          for (final degrees in const [0, 90, 180, 270])
            ButtonSegment(value: degrees, label: Text('$degrees°')),
        ],
        selected: {value},
        onSelectionChanged: (selection) => onChanged(selection.first),
      ),
    ],
  );
}

class _ProbeCard extends StatelessWidget {
  const _ProbeCard({
    required this.spec,
    required this.probe,
    required this.rules,
    required this.others,
    required this.onChanged,
  });

  final BlockSpec spec;
  final Map<String, String> probe;
  final List<BlockStateRule> rules;
  final List<BlockStateModel> others;
  final ValueChanged<Map<String, String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final applied = [
      for (final (index, rule) in rules.indexed)
        if (rule.matches(probe)) (index, rule),
    ];
    final foreign = [
      for (final other in others)
        for (final (index, rule) in other.rules.indexed)
          if (rule.matches(probe)) (other.uiName, index, rule),
    ];
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Zustand testen',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final MapEntry(key: property, value: values)
                in spec.properties.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DropdownMenu<String>(
                  key: ValueKey('$property=${probe[property]}'),
                  width: 368,
                  label: Text(property),
                  initialSelection: probe[property],
                  onSelected: (value) {
                    if (value != null) onChanged({...probe, property: value});
                  },
                  dropdownMenuEntries: [
                    for (final value in values)
                      DropdownMenuEntry(value: value, label: value),
                  ],
                ),
              ),
            const Divider(),
            if (applied.isEmpty && foreign.isEmpty)
              Text(
                'Frei: beim Export braucht er den vanilla Rückfall.',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            for (final (index, rule) in applied)
              Text('Regel ${index + 1}: ${_describe(rule)}'),
            for (final (name, index, rule) in foreign)
              Text(
                '„$name“ · Regel ${index + 1}: ${_describe(rule)}',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            if (applied.isNotEmpty && foreign.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Doppelt belegt: multipart zeichnet beide Modelle übereinander.',
                style: TextStyle(color: scheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _describe(BlockStateRule rule) =>
      '${rule.model.isEmpty ? '(kein Modell)' : rule.model}'
      '${rule.x != 0 ? '  x=${rule.x}' : ''}'
      '${rule.y != 0 ? '  y=${rule.y}' : ''}';
}

class _CoverageCard extends StatelessWidget {
  const _CoverageCard({
    required this.total,
    required this.own,
    required this.conflicts,
    required this.free,
    required this.contexts,
    required this.onPick,
  });

  final int total;

  /// How many states this context claims.
  final int own;

  /// The states this and another context claim.
  final List<Map<String, String>> conflicts;

  /// The states no context claims.
  final List<Map<String, String>> free;

  /// How many contexts the block has, this one included.
  final int contexts;
  final ValueChanged<Map<String, String>> onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final others = total - own - free.length + conflicts.length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Abdeckung des Blocks', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: total == 0 ? 1 : (total - free.length) / total,
            ),
            const SizedBox(height: 8),
            Text('$own von $total Zuständen belegt dieser Kontext'),
            if (contexts > 1)
              Text(
                '$others belegen die ${contexts - 1} anderen Kontexte',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            Text(
              '${free.length} frei, sie bekommen beim Export den vanilla '
              'Rückfall',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            ..._states(context, 'Doppelt belegt', conflicts, scheme.error),
            ..._states(context, 'Frei', free, scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  /// Up to five of [states] under [title], each to try in the probe.
  List<Widget> _states(
    BuildContext context,
    String title,
    List<Map<String, String>> states,
    Color color,
  ) => [
    if (states.isNotEmpty) ...[
      const SizedBox(height: 8),
      Text('$title (${states.length}):', style: TextStyle(color: color)),
      for (final state in states.take(5))
        TextButton(
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.zero,
          ),
          onPressed: () => onPick(state),
          child: Text(
            state.isEmpty
                ? '(einziger Zustand)'
                : state.entries.map((e) => '${e.key}=${e.value}').join(','),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      if (states.length > 5) Text('… und ${states.length - 5} weitere'),
    ],
  ];
}
