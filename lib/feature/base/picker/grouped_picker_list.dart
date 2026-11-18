import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/hide_tooltips_while_scrolling.dart';
import 'package:stelaris/feature/base/picker/picker_group_header.dart';

/// The list of a grouped picker: a header per group followed by its entries.
///
/// [groups] are shown as given, a picker filters them first, e.g. with
/// `filterGroups`. Without any, [emptyText] takes the place of the list.
/// A click on a header reports its group through [onGroup]; null means the
/// list is already filtered, then the headers offer nothing to click.
class GroupedPickerList<G extends Object, T extends Object>
    extends StatelessWidget {
  const GroupedPickerList({
    required this.groups,
    required this.groupLabel,
    required this.groupTooltip,
    required this.headerKey,
    required this.itemKey,
    required this.itemBuilder,
    required this.emptyText,
    this.onGroup,
    super.key,
  });

  final Map<G, List<T>> groups;
  final String Function(G group) groupLabel;

  /// The tooltip of a clickable header, from the group's label. Only asked
  /// for while the headers are clickable.
  final String Function(String label) groupTooltip;

  /// The keys of the rows, unique in the list.
  final Key Function(G group) headerKey;
  final Key Function(T entry) itemKey;

  final Widget Function(BuildContext context, T entry) itemBuilder;
  final String emptyText;
  final ValueChanged<G>? onGroup;

  @override
  Widget build(BuildContext context) {
    final rows = <(Key, G?, T?)>[
      for (final MapEntry(key: group, value: entries) in groups.entries) ...[
        (headerKey(group), group, null),
        for (final entry in entries) (itemKey(entry), null, entry),
      ],
    ];
    if (rows.isEmpty) {
      return Center(child: Text(emptyText, textAlign: TextAlign.center));
    }
    // Lets a row which the search moved keep its element. Without it the
    // list matches rows by index, and every row at a new index is built
    // from scratch.
    final indexOf = <Key, int>{
      for (final (index, (key, _, _)) in rows.indexed) key: index,
    };
    final onGroup = this.onGroup;
    return HideTooltipsWhileScrolling(
      child: ListView.builder(
        // Keeps the rows clear of the scrollbar.
        padding: const EdgeInsets.only(right: 16),
        itemCount: rows.length,
        findChildIndexCallback: (key) => indexOf[key],
        itemBuilder: (context, index) {
          final (key, group, entry) = rows[index];
          // Each row holds its own ink, which the list clips at its edges.
          // Ink on a Material around the list, like the hover of the row
          // under the pointer, would repaint the whole list on every frame
          // of a scroll and draw past the list.
          return Material(
            key: key,
            type: MaterialType.transparency,
            child: group != null
                ? _header(group, onGroup)
                : itemBuilder(context, entry as T),
          );
        },
      ),
    );
  }

  /// The header of [group], the label looked up once.
  Widget _header(G group, ValueChanged<G>? onGroup) {
    final label = groupLabel(group);
    return PickerGroupHeader(
      label: label,
      tooltip: onGroup == null ? null : groupTooltip(label),
      onTap: onGroup == null ? null : () => onGroup(group),
    );
  }
}
