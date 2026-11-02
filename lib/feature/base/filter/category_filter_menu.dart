import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/app_shapes.dart';

/// A category offered by a [CategoryFilterMenu].
typedef CategoryFilterEntry<T> = ({
  T value,
  String label,
  int count,

  /// Makes up the key of its menu item: `<keyPrefix>_<id>`.
  String id,
});

/// Opens a menu to filter a list by a category, null stands for all of them.
///
/// The pickers share it, each passes its own button through [builder]. The
/// first item shows everything with the sum of the [entries]' counts, the
/// [entries] follow in their order.
class CategoryFilterMenu<T extends Object> extends StatelessWidget {
  const CategoryFilterMenu({
    required this.value,
    required this.entries,
    required this.allLabel,
    required this.keyPrefix,
    required this.onChanged,
    required this.builder,
    super.key,
  });

  static const double _width = 260;
  static const double _maxHeight = 480;

  final T? value;

  /// The categories to offer; categories without any entries are left out.
  final List<CategoryFilterEntry<T>> entries;

  /// The label of the item which shows all categories.
  final String allLabel;

  /// The start of the menu items' keys, the all item ends in `_all`.
  final String keyPrefix;
  final ValueChanged<T?> onChanged;

  /// Builds the button; [toggle] opens or closes the menu.
  final Widget Function(BuildContext context, VoidCallback toggle) builder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final countStyle = theme.textTheme.labelMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    final total = entries.fold(0, (sum, entry) => sum + entry.count);

    Widget item(T? category, String id, String label, int count) {
      final isActive = category == value;
      return MenuItemButton(
        key: Key('${keyPrefix}_$id'),
        onPressed: () => onChanged(category),
        // The menu takes the width of its items, so they fix it; the end
        // padding keeps the counts clear of the scrollbar.
        style: MenuItemButton.styleFrom(
          minimumSize: const Size(_width, 40),
          maximumSize: const Size(_width, 40),
          padding: const EdgeInsetsDirectional.only(start: 12, end: 20),
          backgroundColor: isActive ? colorScheme.secondaryContainer : null,
          foregroundColor: isActive ? colorScheme.onSecondaryContainer : null,
        ),
        // An empty box keeps the labels in line with the active one.
        leadingIcon: isActive
            ? const Icon(Icons.check, size: 18)
            : const SizedBox(width: 18),
        trailingIcon: Text('$count', style: countStyle),
        child: Text(label),
      );
    }

    return MenuAnchor(
      // Opens below the button, aligned to its end, so the menu stays
      // inside a dialog whose edge the button sits at.
      alignmentOffset: const Offset(-_width, 4),
      style: MenuStyle(
        alignment: AlignmentDirectional.bottomEnd,
        maximumSize: const WidgetStatePropertyAll(
          Size(double.infinity, _maxHeight),
        ),
        visualDensity: VisualDensity.compact,
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppShapes.medium),
          ),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 6),
        ),
      ),
      menuChildren: [
        item(null, 'all', allLabel, total),
        const Divider(height: 9),
        for (final entry in entries)
          if (entry.count > 0)
            item(entry.value, entry.id, entry.label, entry.count),
      ],
      builder: (context, controller, _) => builder(
        context,
        () => controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}
