import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/app_shapes.dart';

/// The header of a group in a grouped picker: its [label], and with [onTap]
/// a filter icon and a click that shows only the group, explained by the
/// [tooltip] if there is one.
class PickerGroupHeader extends StatelessWidget {
  const PickerGroupHeader({
    required this.label,
    this.tooltip,
    this.onTap,
    super.key,
  });

  final String label;
  final String? tooltip;

  /// Filters the list by the group, null when it is already filtered.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    final onTap = this.onTap;
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
    final button = InkWell(
      borderRadius: BorderRadius.circular(AppShapes.small),
      onTap: onTap,
      child: header,
    );
    final tooltip = this.tooltip;
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}
