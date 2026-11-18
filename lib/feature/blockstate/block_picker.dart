import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/filter/category_filter_menu.dart';
import 'package:stelaris/feature/base/picker/filter_groups.dart';
import 'package:stelaris/feature/base/picker/grouped_picker_list.dart';
import 'package:stelaris/feature/base/search/dialog_search_bar.dart';
import 'package:stelaris/feature/blockstate/block_group.dart';
import 'package:stelaris/feature/blockstate/block_state_rules.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The size of the picker, the same as the function picker's.
const double blockPickerWidth = 560;
const double blockPickerHeight = 480;

const double _filterButtonSize = 32;

/// The blocks to browse, styled like the function picker: a search bar with
/// a group filter above a list of the blocks under a header per group.
///
/// The search matches the name and the key of a block ignoring case, and
/// the name of a group, so typing e.g. `stairs` lists every stair. A click
/// on a header shows only its group.
///
/// [contexts] says per block key how many blockstates already use it, they
/// share its file; [current] is marked. A tap reports the block through
/// [onBlock].
class BlockPicker extends StatefulWidget {
  const BlockPicker({
    required this.onBlock,
    this.contexts = const {},
    this.current,
    super.key,
  });

  final Map<String, int> contexts;
  final String? current;
  final ValueChanged<BlockSpec> onBlock;

  @override
  State<BlockPicker> createState() => _BlockPickerState();
}

class _BlockPickerState extends State<BlockPicker> {
  final FocusNode _focusNode = FocusNode();

  /// The search text. Only the list listens to it, so a keystroke leaves the
  /// search bar and the filter alone.
  final ValueNotifier<String> _search = ValueNotifier('');

  /// The group picked in the filter. Null shows all.
  BlockGroup? _group;

  /// The blocks per group, computed once so a keystroke only filters.
  /// Groups without any are left out.
  late final Map<BlockGroup, List<BlockSpec>> _entries = () {
    final byGroup = <BlockGroup, List<BlockSpec>>{
      for (final group in BlockGroup.values) group: [],
    };
    for (final block in allBlocks) {
      byGroup[block.group]!.add(block);
    }
    return byGroup..removeWhere((_, blocks) => blocks.isEmpty);
  }();

  @override
  void dispose() {
    _focusNode.dispose();
    _search.dispose();
    super.dispose();
  }

  void _selectGroup(BlockGroup? group) {
    setState(() => _group = group);
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final group = _group;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DialogSearchBar(
          focusNode: _focusNode,
          hintText: group == null
              ? l10n.blockstate_picker_search
              : l10n.blockstate_picker_search_in(group.label(l10n)),
          trailing: [
            CategoryFilterMenu<BlockGroup>(
              value: group,
              allLabel: l10n.blockstate_picker_all,
              keyPrefix: 'block_group_item',
              entries: [
                for (final MapEntry(key: group, value: blocks)
                    in _entries.entries)
                  (
                    value: group,
                    label: group.label(l10n),
                    count: blocks.length,
                    id: group.name,
                  ),
              ],
              onChanged: _selectGroup,
              builder: (context, toggle) => SizedBox(
                // The anchor would stretch the button to the bar's height
                // otherwise.
                width: _filterButtonSize,
                height: _filterButtonSize,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  isSelected: group != null,
                  icon: const Icon(Icons.filter_list),
                  tooltip: l10n.blockstate_picker_filter,
                  onPressed: toggle,
                ),
              ),
            ),
          ],
          onChanged: (value) => _search.value = value,
        ),
        verticalSpacing10,
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: _search,
            builder: (context, search, _) => GroupedPickerList(
              groups: filterGroups(
                _entries,
                search: search,
                only: group,
                groupLabel: (group) => group.label(l10n),
                matches: (block, search) =>
                    block.displayName.toLowerCase().contains(search) ||
                    block.key.contains(search),
              ),
              groupLabel: (group) => group.label(l10n),
              groupTooltip: l10n.blockstate_picker_only_group,
              headerKey: (group) =>
                  ValueKey('block_group_header_${group.name}'),
              itemKey: (block) => ValueKey('block_${block.key}'),
              itemBuilder: (context, block) => _BlockTile(
                block: block,
                contexts: widget.contexts[block.key] ?? 0,
                selected: block.key == widget.current,
                onTap: () => widget.onBlock(block),
              ),
              emptyText: l10n.blockstate_picker_no_match,
              // A filtered list has only one header, so it offers nothing
              // to click.
              onGroup: group == null ? _selectGroup : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _BlockTile extends StatelessWidget {
  const _BlockTile({
    required this.block,
    required this.contexts,
    required this.selected,
    required this.onTap,
  });

  final BlockSpec block;

  /// How many blockstates already use the block.
  final int contexts;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return ListTile(
      dense: true,
      selected: selected,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: Text(block.displayName, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        block.key,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
      ),
      trailing: Text(
        [
          l10n.blockstate_states(block.stateCount),
          if (contexts > 0) l10n.blockstate_contexts(contexts),
        ].join(' · '),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      onTap: onTap,
    );
  }
}
