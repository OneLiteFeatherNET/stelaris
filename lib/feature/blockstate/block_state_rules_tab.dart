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

/// The rules of a blockstate as a grid of cards.
///
/// Every blockstate is a context of its own. The [others] are the contexts
/// of the same block: the export writes all of them into one file, so a
/// state claimed twice is a conflict, `multipart` would draw both models. A
/// rule claiming such states is marked.
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

  @override
  void didUpdateWidget(BlockStateRulesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.key != widget.entry.key) {
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

  Future<void> _edit(int index) async {
    final rules = await showRuleDialog(
      context,
      title: context.l10n.blockstate_rule(index + 1),
      spec: _spec,
      rule: _rules[index],
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = EditCardGrid.cardWidthIn(constraints.maxWidth);
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EditSectionHeading(
                  title: l10n.blockstate_rules_title(_rules.length),
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

/// Opens the [_RuleDialog] for [rule] of a block with [spec]. It pops the
/// rules to put in its place: the edited rule, none when deleted, one per
/// facing when split. Only an [existing] rule can be deleted.
Future<List<BlockStateRule>?> showRuleDialog(
  BuildContext context, {
  required String title,
  required BlockSpec spec,
  required BlockStateRule rule,
  bool existing = true,
}) => showDialog<List<BlockStateRule>>(
  context: context,
  builder: (_) =>
      _RuleDialog(title: title, spec: spec, rule: rule, existing: existing),
);

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
