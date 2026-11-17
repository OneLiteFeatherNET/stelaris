// SPIKE: throwaway proof of concept for rule based blockstate editing.
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/button/delete_icon_button.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/edit_card/edit_card.dart';
import 'package:stelaris/feature/base/edit_card/edit_card_grid.dart';
import 'package:stelaris/feature/base/edit_card/edit_section_heading.dart';
import 'package:stelaris/feature/dialogs/delete_dialog.dart';
import 'package:stelaris/feature/blockstate/block_state_rules.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The rules of a blockstate as a grid of cards. A tap on a card opens the
/// rule in a dialog, its result is reported through [onChanged].
///
/// Every blockstate is a context of its own. The [others] are the contexts
/// of the same block: the export writes all of them into one file, so a
/// state claimed twice is a conflict, `multipart` would draw both models. A
/// rule claiming such states is marked.
class BlockStateRuleGrid extends StatelessWidget {
  const BlockStateRuleGrid({
    required this.entry,
    required this.others,
    required this.onChanged,
    super.key,
  });

  final BlockStateModel entry;
  final List<BlockStateModel> others;
  final ValueChanged<BlockStateModel> onChanged;

  /// Puts [rules] in place of the rule at [index].
  void _replace(int index, List<BlockStateRule> rules) => onChanged(
    entry.copyWith(
      rules: [...entry.rules]..replaceRange(index, index + 1, rules),
    ),
  );

  Future<void> _edit(BuildContext context, BlockSpec spec, int index) async {
    final rule = await showRuleDialog(
      context,
      index: index,
      spec: spec,
      rule: entry.rules[index],
    );
    if (rule != null) _replace(index, [rule]);
  }

  Future<void> _delete(BuildContext context, int index) async {
    final confirmed = await confirmRuleDelete(
      context,
      ruleTitle(context.l10n, entry.rules[index], index),
      entry.rules[index],
    );
    if (confirmed) _replace(index, const []);
  }

  @override
  Widget build(BuildContext context) {
    final spec = specFor(entry.key);
    final rules = entry.rules;
    final overlaps = overlapsOf(rules, others, spec);
    return LayoutBuilder(
      builder: (context, constraints) {
        // Without the padding on both sides, like the edit card grid.
        final cardWidth = EditCardGrid.cardWidthIn(constraints.maxWidth - 32);
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EditSectionHeading(
                title: context.l10n.blockstate_rules_title(rules.length),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: EditCardGrid.spacing,
                runSpacing: EditCardGrid.spacing,
                children: [
                  for (final (index, rule) in rules.indexed)
                    SizedBox(
                      width: cardWidth,
                      child: _RuleCard(
                        index: index,
                        rule: rule,
                        spec: spec,
                        overlap: overlaps[index],
                        onTap: () => _edit(context, spec, index),
                        onSplit: spec.properties.containsKey('facing')
                            ? () => _replace(index, expandFacing(rule, spec))
                            : null,
                        onDelete: () => _delete(context, index),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A rule in the card of the edit pages: the model as its value with the
/// number of the rule above, or for a named rule the name as its value with
/// the model above. The condition and the rotation are below. It has no
/// icon, only a warning icon when other contexts claim some of its states.
/// In its corner it has a split button, for a block with a facing, and a
/// delete button.
class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.index,
    required this.rule,
    required this.spec,
    required this.overlap,
    required this.onTap,
    required this.onSplit,
    required this.onDelete,
  });

  final int index;
  final BlockStateRule rule;
  final BlockSpec spec;
  final RuleOverlap overlap;
  final VoidCallback onTap;

  /// Splits the rule per facing, null for a block without one: then the
  /// button is left out.
  final VoidCallback? onSplit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rotation = [
      if (rule.x != 0) 'x ${rule.x}°',
      if (rule.y != 0) 'y ${rule.y}°',
      if (rule.uvlock) 'uvlock',
    ];
    final overlapping = overlap.count > 0;
    final name = rule.name?.trim() ?? '';
    final number = l10n.blockstate_rule(index + 1);
    // A name is what the rule was given to be told apart, so it is the
    // large text and the model moves into the label.
    final label = name.isEmpty || rule.model.isEmpty ? number : rule.model;
    return EditCard(
      icon: overlapping ? Icons.warning_amber_rounded : null,
      label: overlapping
          ? l10n.blockstate_rule_overlap(
              label,
              overlap.count,
              overlap.names.map((other) => '“$other”').join(', '),
            )
          : label,
      value: name.isEmpty ? rule.model : name,
      footer: [
        conditionOf(l10n, rule, spec),
        if (rotation.isNotEmpty) rotation.join(' · '),
      ].join('\n'),
      onTap: onTap,
      actions: [
        if (onSplit != null)
          IconButton(
            tooltip: l10n.blockstate_rule_split_facing,
            onPressed: onSplit,
            icon: const Icon(Icons.rotate_90_degrees_cw_outlined),
          ),
        DeleteIconButton(tooltip: l10n.tooltip_delete, onPressed: onDelete),
      ],
    );
  }
}

/// The title of [rule] at [index]: its name, or `Rule 2` without one.
String ruleTitle(AppLocalizations l10n, BlockStateRule rule, int index) =>
    switch (rule.name) {
      final name? when name.trim().isNotEmpty => name,
      _ => l10n.blockstate_rule(index + 1),
    };

/// Asks whether to delete the rule titled [title], e.g. `Rule 2`.
Future<bool> confirmRuleDelete(
  BuildContext context,
  String title,
  BlockStateRule rule,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (_) => DeleteDialog<BlockStateRule>(
        title: context.l10n.blockstate_rule_delete_title,
        header: [
          TextSpan(text: context.l10n.blockstate_rule_delete_header(title)),
        ],
        value: rule,
        successfully: (_) => true,
      ),
    ) ==
    true;

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

/// Opens the [_RuleDialog] for [rule] at [index] of a block with [spec]. It
/// pops the edited rule, null when cancelled. Splitting and deleting are on
/// the card.
Future<BlockStateRule?> showRuleDialog(
  BuildContext context, {
  required int index,
  required BlockSpec spec,
  required BlockStateRule rule,
}) => showDialog<BlockStateRule>(
  context: context,
  builder: (_) => _RuleDialog(index: index, spec: spec, rule: rule),
);

/// Edits a copy of [rule]: the values per property it applies to, then the
/// model with its rotation. Its name is the title, renamed in place. Pops
/// the edited rule on save.
class _RuleDialog extends StatefulWidget {
  const _RuleDialog({
    required this.index,
    required this.spec,
    required this.rule,
  });

  /// Where the rule is or will be in the list, for the title without a name.
  final int index;
  final BlockSpec spec;
  final BlockStateRule rule;

  @override
  State<_RuleDialog> createState() => _RuleDialogState();
}

class _RuleDialogState extends State<_RuleDialog> {
  late BlockStateRule _rule = widget.rule;
  late final _name = TextEditingController(text: widget.rule.name);
  bool _renaming = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _change(BlockStateRule rule) => setState(() => _rule = rule);

  // The text fields keep their text themselves, so typing changes the rule
  // without a rebuild. The title shows the name once the renaming ends.
  // An empty name falls back to the number of the rule.
  void _rename(String name) =>
      _rule = _rule.copyWith(name: name.trim().isEmpty ? null : name);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final spec = widget.spec;
    final titleStyle = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.bold,
    );
    return FormDialog(
      title: ruleTitle(l10n, _rule, widget.index),
      titleChild: _renaming
          ? TextField(
              controller: _name,
              autofocus: true,
              style: titleStyle,
              decoration: InputDecoration(
                hintText: l10n.blockstate_rule(widget.index + 1),
                isDense: true,
              ),
              onChanged: _rename,
              onSubmitted: (_) => setState(() => _renaming = false),
            )
          : null,
      titleActions: [
        if (!_renaming)
          IconButton(
            tooltip: l10n.blockstate_rule_rename,
            onPressed: () => setState(() => _renaming = true),
            icon: const Icon(Icons.edit_outlined),
          ),
      ],
      actionLabel: l10n.button_save,
      maxWidth: 640,
      onSubmit: () => Navigator.of(context).pop(_rule),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EditSectionHeading(title: l10n.blockstate_rule_when),
          if (spec.properties.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(l10n.blockstate_rule_no_properties),
            ),
          for (final MapEntry(key: property, value: values)
              in spec.properties.entries)
            _LabeledRow(
              label: property,
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (final value in values)
                    FilterChip(
                      // A checkmark would widen the chip and push the
                      // others of the row aside.
                      showCheckmark: false,
                      visualDensity: VisualDensity.compact,
                      label: Text(value),
                      selected: _rule.when[property]?.contains(value) ?? false,
                      onSelected: (_) => _change(_rule.toggle(property, value)),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          EditSectionHeading(title: l10n.blockstate_rule_then),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _rule.model,
            decoration: InputDecoration(
              labelText: l10n.blockstate_rule_model,
              hintText: 'minecraft:block/footprint_slender',
              prefixIcon: const Icon(Icons.view_in_ar_outlined),
            ),
            onChanged: (model) => _rule = _rule.copyWith(model: model),
          ),
          const SizedBox(height: 8),
          _LabeledRow(
            label: l10n.blockstate_rule_tilt,
            child: _RotationPicker(
              value: _rule.x,
              onChanged: (x) => _change(_rule.copyWith(x: x)),
            ),
          ),
          _LabeledRow(
            label: l10n.blockstate_rule_turn,
            child: _RotationPicker(
              value: _rule.y,
              onChanged: (y) => _change(_rule.copyWith(y: y)),
            ),
          ),
          _LabeledRow(
            label: l10n.blockstate_rule_uvlock,
            child: Row(
              children: [
                Switch(
                  value: _rule.uvlock,
                  onChanged: (uvlock) =>
                      _change(_rule.copyWith(uvlock: uvlock)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.blockstate_rule_uvlock_hint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A row of the rule dialog: a muted [label] in a fixed column, so the
/// controls of all rows line up, and the [child] beside it.
class _LabeledRow extends StatelessWidget {
  const _LabeledRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        Expanded(
          child: Align(alignment: Alignment.centerLeft, child: child),
        ),
      ],
    ),
  );
}

/// The rotation around one axis in steps of 90 degrees.
class _RotationPicker extends StatelessWidget {
  const _RotationPicker({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<int>(
    showSelectedIcon: false,
    style: const ButtonStyle(visualDensity: VisualDensity.compact),
    segments: [
      for (final degrees in const [0, 90, 180, 270])
        ButtonSegment(value: degrees, label: Text('$degrees°')),
    ],
    selected: {value},
    onSelectionChanged: (selection) => onChanged(selection.first),
  );
}
