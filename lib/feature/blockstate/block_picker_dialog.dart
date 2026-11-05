// SPIKE: throwaway proof of concept for rule based blockstate editing.
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/filter/category_filter_menu.dart';
import 'package:stelaris/feature/base/hide_tooltips_while_scrolling.dart';
import 'package:stelaris/feature/base/search/dialog_search_bar.dart';
import 'package:stelaris/feature/blockstate/block_state_rules.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Below this width the picker fills the screen instead of floating over it.
const double _fullScreenWidth = 600;

/// The size of the floating picker, the same as the function picker's.
const double _maxPickerWidth = 560;
const double _contentHeight = 480;

const double _filterButtonSize = 32;

/// The groups of the picker in the order they are listed: one per block
/// family, told apart by the end of the key, then the remaining blocks with
/// and without properties.
enum _Group {
  stairs(['_stairs']),
  slab(['_slab']),
  fence(['_fence']),
  fenceGate(['_fence_gate']),
  wall(['_wall']),
  door(['_door']),
  trapdoor(['_trapdoor']),
  button(['_button']),
  pressurePlate(['_pressure_plate']),
  sign(['_sign']),
  pane(['_pane', '_bars']),
  bed(['_bed']),
  candle(['candle']),
  banner(['_banner']),
  head(['_head', '_skull']),
  rail(['rail']),
  leaves(['_leaves']),
  pillar(['_log', '_wood', '_stem', '_hyphae', '_pillar']),
  other([]),
  none([]);

  const _Group(this.suffixes);

  final List<String> suffixes;

  String label(AppLocalizations l10n) => switch (this) {
    stairs => l10n.blockstate_group_stairs,
    slab => l10n.blockstate_group_slab,
    fence => l10n.blockstate_group_fence,
    fenceGate => l10n.blockstate_group_fence_gate,
    wall => l10n.blockstate_group_wall,
    door => l10n.blockstate_group_door,
    trapdoor => l10n.blockstate_group_trapdoor,
    button => l10n.blockstate_group_button,
    pressurePlate => l10n.blockstate_group_pressure_plate,
    sign => l10n.blockstate_group_sign,
    pane => l10n.blockstate_group_pane,
    bed => l10n.blockstate_group_bed,
    candle => l10n.blockstate_group_candle,
    banner => l10n.blockstate_group_banner,
    head => l10n.blockstate_group_head,
    rail => l10n.blockstate_group_rail,
    leaves => l10n.blockstate_group_leaves,
    pillar => l10n.blockstate_group_pillar,
    other => l10n.blockstate_group_other,
    none => l10n.blockstate_group_none,
  };

  static _Group of(BlockSpec block) {
    if (block.properties.isEmpty) return none;
    final name = block.key.substring(block.key.indexOf(':') + 1);
    for (final group in values) {
      if (group.suffixes.any(name.endsWith)) return group;
    }
    return other;
  }
}

/// Opens the picker of the blocks, to search and tap one. [contexts] says
/// per block key how many blockstates already use it, they share its file;
/// [current] is marked. Floats over the page on a wide screen, fills a narrow one.
Future<BlockSpec?> showBlockPicker(
  BuildContext context, {
  Map<String, int> contexts = const {},
  String? current,
}) {
  final fullScreen = MediaQuery.sizeOf(context).width < _fullScreenWidth;
  return showDialog<BlockSpec>(
    context: context,
    builder: (dialogContext) {
      final title = dialogContext.l10n.blockstate_picker_title;
      // Built from the dialog's own context: a tap pops the dialog.
      final content = _BlockPicker(
        contexts: contexts,
        current: current,
        onBlock: (block) => Navigator.of(dialogContext).pop(block),
      );
      if (fullScreen) {
        return Dialog.fullscreen(
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                tooltip: dialogContext.l10n.button_close,
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              title: Text(title),
            ),
            body: Padding(padding: const EdgeInsets.all(16), child: content),
          ),
        );
      }
      return FormDialog(
        title: title,
        actionLabel: dialogContext.l10n.button_close,
        onSubmit: null,
        showActions: false,
        maxWidth: _maxPickerWidth,
        // Fixed, so the dialog keeps its size while the user types.
        content: SizedBox(height: _contentHeight, child: content),
      );
    },
  );
}

/// The blocks to browse, styled like the function picker: a search bar with
/// a group filter above a list of the blocks under a header per group.
///
/// The search matches the name and the key of a block ignoring case, and
/// the name of a group, so typing e.g. `stairs` lists every stair. A click
/// on a header shows only its group.
class _BlockPicker extends StatefulWidget {
  const _BlockPicker({
    required this.contexts,
    required this.current,
    required this.onBlock,
  });

  final Map<String, int> contexts;
  final String? current;
  final ValueChanged<BlockSpec> onBlock;

  @override
  State<_BlockPicker> createState() => _BlockPickerState();
}

class _BlockPickerState extends State<_BlockPicker> {
  final FocusNode _focusNode = FocusNode();

  /// The search text. Only the list listens to it, so a keystroke leaves the
  /// search bar and the filter alone.
  final ValueNotifier<String> _search = ValueNotifier('');

  /// The group picked in the filter. Null shows all.
  _Group? _group;

  /// The blocks per group, computed once so a keystroke only filters.
  /// Groups without any are left out.
  late final Map<_Group, List<BlockSpec>> _entries = () {
    final byGroup = <_Group, List<BlockSpec>>{
      for (final group in _Group.values) group: [],
    };
    for (final block in allBlocks) {
      byGroup[_Group.of(block)]!.add(block);
    }
    return byGroup..removeWhere((_, blocks) => blocks.isEmpty);
  }();

  @override
  void dispose() {
    _focusNode.dispose();
    _search.dispose();
    super.dispose();
  }

  void _selectGroup(_Group? group) {
    setState(() => _group = group);
    _focusNode.requestFocus();
  }

  /// The rows of the list: a header per group followed by its blocks.
  List<_Row> _rows(AppLocalizations l10n, String text) {
    final search = text.trim().toLowerCase();
    final rows = <_Row>[];
    for (final MapEntry(key: group, value: blocks) in _entries.entries) {
      if (_group != null && group != _group) continue;
      final Iterable<BlockSpec> matches =
          search.isEmpty || group.label(l10n).toLowerCase().contains(search)
          ? blocks
          : blocks.where(
              (block) =>
                  block.displayName.toLowerCase().contains(search) ||
                  block.key.contains(search),
            );
      if (matches.isEmpty) continue;
      rows
        ..add(_HeaderRow(group))
        ..addAll(matches.map(_BlockRow.new));
    }
    return rows;
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
            CategoryFilterMenu<_Group>(
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
            builder: (context, search, _) => _list(search),
          ),
        ),
      ],
    );
  }

  Widget _list(String search) {
    final l10n = context.l10n;
    final rows = _rows(l10n, search);
    if (rows.isEmpty) {
      return Center(child: Text(l10n.blockstate_picker_no_match));
    }
    // Lets a row which the search moved keep its element.
    final indexOf = <Key, int>{
      for (final (index, row) in rows.indexed) row.key: index,
    };
    final group = _group;
    return Material(
      type: MaterialType.transparency,
      clipBehavior: Clip.hardEdge,
      child: HideTooltipsWhileScrolling(
        child: ListView.builder(
          // Keeps the rows clear of the scrollbar.
          padding: const EdgeInsets.only(right: 16),
          itemCount: rows.length,
          findChildIndexCallback: (key) => indexOf[key],
          itemBuilder: (context, index) => switch (rows[index]) {
            final _HeaderRow row => _GroupHeader(
              key: row.key,
              row.group,
              // A filtered list has only this header, so it offers nothing
              // to click.
              onTap: group == null ? () => _selectGroup(row.group) : null,
            ),
            final _BlockRow row => _BlockTile(
              key: row.key,
              block: row.block,
              contexts: widget.contexts[row.block.key] ?? 0,
              selected: row.block.key == widget.current,
              onTap: () => widget.onBlock(row.block),
            ),
          },
        ),
      ),
    );
  }
}

/// A row of the list.
sealed class _Row {
  const _Row();

  /// The key of the row's widget, unique in the list.
  Key get key;
}

final class _HeaderRow extends _Row {
  const _HeaderRow(this.group);

  final _Group group;

  @override
  Key get key => ValueKey('block_group_header_${group.name}');
}

final class _BlockRow extends _Row {
  const _BlockRow(this.block);

  final BlockSpec block;

  @override
  Key get key => ValueKey('block_${block.key}');
}

/// The header of a group, like the group headers of the function picker: a
/// click shows only the group.
class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.group, {required this.onTap, super.key});

  final _Group group;

  /// Filters the list by the group, null when it is already filtered.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    final label = group.label(l10n);
    final header = Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(color: color),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 4),
            Icon(Icons.filter_list, size: 16, color: color),
          ],
        ],
      ),
    );
    if (onTap == null) return header;
    return Tooltip(
      message: l10n.blockstate_picker_only_group(label),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppShapes.small),
        onTap: onTap,
        child: header,
      ),
    );
  }
}

class _BlockTile extends StatelessWidget {
  const _BlockTile({
    required this.block,
    required this.contexts,
    required this.selected,
    required this.onTap,
    super.key,
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
