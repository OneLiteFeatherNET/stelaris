// SPIKE: throwaway proof of concept for rule based blockstate editing.
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/edit_card/edit_card.dart';
import 'package:stelaris/feature/base/edit_card/edit_card_grid.dart';
import 'package:stelaris/feature/base/edit_card/edit_section_heading.dart';
import 'package:stelaris/feature/dialogs/delete_dialog.dart';
import 'package:stelaris/feature/blockstate/block_state_rules.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/l10n_ext.dart';
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

  void _replace(int index, List<BlockStateRule> rules) {
    setState(() => _generation++);
    _setRules([..._rules]..replaceRange(index, index + 1, rules));
  }

  /// Opens the [_RuleDialog] for [rule]; it pops the rules to put in its
  /// place: the edited rule, none when deleted, one per facing when split.
  Future<List<BlockStateRule>?> _openDialog(
    String title,
    BlockStateRule rule, {
    bool existing = true,
  }) => showDialog<List<BlockStateRule>>(
    context: context,
    builder: (_) =>
        _RuleDialog(title: title, spec: _spec, rule: rule, existing: existing),
  );

  Future<void> _add() async {
    final rules = await _openDialog(
      context.l10n.blockstate_rule_add,
      const BlockStateRule(),
      existing: false,
    );
    if (rules != null && mounted) _setRules([..._rules, ...rules]);
  }

  Future<void> _edit(int index) async {
    final rules = await _openDialog(
      context.l10n.blockstate_rule(index + 1),
      _rules[index],
    );
    if (rules != null && mounted) _replace(index, rules);
  }

  /// A rule in the card of the edit pages: the model as its value, the
  /// condition and the rotation below, and a warning icon when other
  /// contexts claim some of its states. A tap opens the [_RuleDialog].
  Widget _ruleCard(
    int index,
    BlockStateRule rule,
    ({Set<String> names, int count}) overlap,
  ) {
    final l10n = context.l10n;
    final rotation = [
      if (rule.x != 0) 'x ${rule.x}°',
      if (rule.y != 0) 'y ${rule.y}°',
      if (rule.uvlock) 'uvlock',
    ];
    return EditCard(
      icon: overlap.count > 0 ? Icons.warning_amber_rounded : Icons.rule,
      label: overlap.count > 0
          ? l10n.blockstate_rule_overlap(
              index + 1,
              overlap.count,
              overlap.names.map((name) => '“$name”').join(', '),
            )
          : l10n.blockstate_rule(index + 1),
      value: rule.model,
      footer: [
        conditionOf(l10n, rule, _spec),
        if (rotation.isNotEmpty) rotation.join(' · '),
      ].join('\n'),
      onTap: () => _edit(index),
    );
  }

  /// The names of the other contexts claiming [state].
  List<String> _claimedBy(Map<String, String> state) => [
    for (final other in widget.others)
      if (other.rules.any((rule) => rule.matches(state))) other.uiName,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = EditCardGrid.cardWidthIn(
                  constraints.maxWidth,
                );
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EditSectionHeading(
                        title: l10n.blockstate_rules_title(_rules.length),
                        trailing: TextButton.icon(
                          onPressed: _add,
                          icon: const Icon(Icons.add),
                          label: Text(l10n.blockstate_rule_add),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: EditCardGrid.spacing,
                        runSpacing: EditCardGrid.spacing,
                        children: [
                          for (final (index, rule) in _rules.indexed)
                            SizedBox(
                              key: ValueKey('$_generation-$index'),
                              width: cardWidth,
                              child: _ruleCard(index, rule, overlapOf(rule)),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
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

/// The condition of [rule] as `property=a|b`, joined by ` · `.
String conditionOf(AppLocalizations l10n, BlockStateRule rule, BlockSpec spec) {
  final parts = [
    for (final MapEntry(key: property, value: values) in rule.when.entries)
      if (values.isNotEmpty &&
          values.length < (spec.properties[property]?.length ?? 0))
        '$property=${values.join('|')}',
  ];
  return parts.isEmpty ? l10n.blockstate_rule_any_state : parts.join(' · ');
}

/// Edits a copy of [rule]: the values per property it applies to, then the
/// model with its rotation. Pops the rules to put in its place: the edited
/// rule on save, none on delete, one per facing on a split.
class _RuleDialog extends StatefulWidget {
  const _RuleDialog({
    required this.title,
    required this.spec,
    required this.rule,
    required this.existing,
  });

  final String title;
  final BlockSpec spec;
  final BlockStateRule rule;

  /// Whether the rule is already in the list, only then it can be deleted.
  final bool existing;

  @override
  State<_RuleDialog> createState() => _RuleDialogState();
}

class _RuleDialogState extends State<_RuleDialog> {
  late BlockStateRule _rule = widget.rule;

  void _change(BlockStateRule rule) => setState(() => _rule = rule);

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteDialog<BlockStateRule>(
        title: context.l10n.blockstate_rule_delete_title,
        header: [
          TextSpan(
            text: context.l10n.blockstate_rule_delete_header(widget.title),
          ),
        ],
        value: _rule,
        successfully: (_) => true,
      ),
    );
    if (confirmed == true && mounted) {
      Navigator.of(context).pop(const <BlockStateRule>[]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final spec = widget.spec;
    return FormDialog(
      title: widget.title,
      actionLabel: l10n.button_save,
      maxWidth: 640,
      onSubmit: () => Navigator.of(context).pop([_rule]),
      titleActions: [
        if (spec.properties.containsKey('facing'))
          IconButton(
            tooltip: l10n.blockstate_rule_split_facing,
            onPressed: () =>
                Navigator.of(context).pop(expandFacing(_rule, spec)),
            icon: const Icon(Icons.rotate_90_degrees_cw_outlined),
          ),
        if (widget.existing)
          IconButton(
            tooltip: l10n.tooltip_delete,
            onPressed: _delete,
            icon: const Icon(Icons.delete_forever),
          ),
      ],
      content: SingleChildScrollView(
        padding: const EdgeInsets.only(right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.blockstate_rule_when, style: theme.textTheme.labelLarge),
            if (spec.properties.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(l10n.blockstate_rule_no_properties),
              ),
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
                                  _rule.when[property]?.contains(value) ??
                                  false,
                              onSelected: (_) =>
                                  _change(_rule.toggle(property, value)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Text(l10n.blockstate_rule_then, style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            TextFormField(
              initialValue: _rule.model,
              decoration: InputDecoration(
                labelText: l10n.blockstate_rule_model,
                hintText: 'minecraft:block/footprint_slender',
                isDense: true,
              ),
              onChanged: (model) => _change(_rule.copyWith(model: model)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _RotationPicker(
                  axis: 'x',
                  value: _rule.x,
                  onChanged: (x) => _change(_rule.copyWith(x: x)),
                ),
                _RotationPicker(
                  axis: 'y',
                  value: _rule.y,
                  onChanged: (y) => _change(_rule.copyWith(y: y)),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('uvlock'),
                    Switch(
                      value: _rule.uvlock,
                      onChanged: (uvlock) =>
                          _change(_rule.copyWith(uvlock: uvlock)),
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
    final l10n = context.l10n;
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
              l10n.blockstate_probe_title,
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
                l10n.blockstate_probe_free,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            for (final (index, rule) in applied)
              Text(
                l10n.blockstate_probe_rule(index + 1, _describe(l10n, rule)),
              ),
            for (final (name, index, rule) in foreign)
              Text(
                l10n.blockstate_probe_foreign(
                  name,
                  index + 1,
                  _describe(l10n, rule),
                ),
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            if (applied.isNotEmpty && foreign.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                l10n.blockstate_probe_conflict,
                style: TextStyle(color: scheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _describe(AppLocalizations l10n, BlockStateRule rule) =>
      '${rule.model.isEmpty ? l10n.blockstate_rule_no_model : rule.model}'
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
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final others = total - own - free.length + conflicts.length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.blockstate_coverage_title,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: total == 0 ? 1 : (total - free.length) / total,
            ),
            const SizedBox(height: 8),
            Text(l10n.blockstate_coverage_own(own, total)),
            if (contexts > 1)
              Text(
                l10n.blockstate_coverage_others(others, contexts - 1),
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            Text(
              l10n.blockstate_coverage_free_hint(free.length),
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            ..._states(
              l10n,
              l10n.blockstate_coverage_conflicts(conflicts.length),
              conflicts,
              scheme.error,
            ),
            ..._states(
              l10n,
              l10n.blockstate_coverage_free(free.length),
              free,
              scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  /// Up to five of [states] under [title], each to try in the probe.
  List<Widget> _states(
    AppLocalizations l10n,
    String title,
    List<Map<String, String>> states,
    Color color,
  ) => [
    if (states.isNotEmpty) ...[
      const SizedBox(height: 8),
      Text(title, style: TextStyle(color: color)),
      for (final state in states.take(5))
        TextButton(
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.zero,
          ),
          onPressed: () => onPick(state),
          child: Text(
            state.isEmpty
                ? l10n.blockstate_coverage_only_state
                : state.entries.map((e) => '${e.key}=${e.value}').join(','),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      if (states.length > 5)
        Text(l10n.blockstate_coverage_more(states.length - 5)),
    ],
  ];
}
