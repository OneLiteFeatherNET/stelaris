// SPIKE: throwaway proof of concept for rule based blockstate editing.
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/button/card_actions_menu.dart';
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
    final rules = await showRuleDialog(
      context,
      title: context.l10n.blockstate_rule(index + 1),
      spec: spec,
      rule: entry.rules[index],
    );
    if (rules != null) _replace(index, rules);
  }

  Future<void> _delete(BuildContext context, int index) async {
    final confirmed = await confirmRuleDelete(
      context,
      context.l10n.blockstate_rule(index + 1),
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
        final cardWidth = EditCardGrid.cardWidthIn(constraints.maxWidth);
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

/// A rule in the card of the edit pages: the model as its value, the
/// condition and the rotation below, and a warning icon when other contexts
/// claim some of its states. Like a model card it has a menu and a delete
/// button in its corner.
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
  /// menu would be empty and is left out.
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
    return EditCard(
      icon: overlapping ? Icons.warning_amber_rounded : Icons.rule,
      label: overlapping
          ? l10n.blockstate_rule_overlap(
              index + 1,
              overlap.count,
              overlap.names.map((name) => '“$name”').join(', '),
            )
          : l10n.blockstate_rule(index + 1),
      value: rule.model,
      footer: [
        conditionOf(l10n, rule, spec),
        if (rotation.isNotEmpty) rotation.join(' · '),
      ].join('\n'),
      onTap: onTap,
      actions: [
        if (onSplit case final onSplit?)
          CardActionsMenu(
            entries: [
              (
                icon: Icons.rotate_90_degrees_cw_outlined,
                label: l10n.blockstate_rule_split_facing,
                onTap: onSplit,
              ),
            ],
          ),
        DeleteIconButton(tooltip: l10n.tooltip_delete, onPressed: onDelete),
      ],
    );
  }
}

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
    final confirmed = await confirmRuleDelete(context, widget.title, _rule);
    if (confirmed && mounted) {
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
