import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:vulpes_data/component.dart';

/// Opens a menu to filter components by their category, null stands for
/// all categories.
///
/// The menu is the same in the component picker and the components tab;
/// each passes its own button through [builder]. It lists only the
/// categories in [counts], each with its number of components.
class ComponentCategoryMenu extends StatelessWidget {
  const ComponentCategoryMenu({
    required this.value,
    required this.counts,
    required this.onChanged,
    required this.builder,
    super.key,
  });

  static const double _width = 260;
  static const double _maxHeight = 480;

  final ComponentCategory? value;

  /// The components per category; categories without any are left out.
  final Map<ComponentCategory, int> counts;
  final ValueChanged<ComponentCategory?> onChanged;

  /// Builds the button; [toggle] opens or closes the menu.
  final Widget Function(BuildContext context, VoidCallback toggle) builder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final countStyle = theme.textTheme.labelMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    final total = counts.values.fold(0, (sum, count) => sum + count);

    Widget item(ComponentCategory? category, String label, int count) {
      final isActive = category == value;
      return MenuItemButton(
        key: Key('component_category_item_${category?.key ?? 'all'}'),
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
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 6),
        ),
      ),
      menuChildren: [
        item(null, context.l10n.component_all_categories, total),
        const Divider(height: 9),
        for (final category in ComponentCategory.values)
          if (counts[category] case final count? when count > 0)
            item(category, category.displayName, count),
      ],
      builder: (context, controller, _) => builder(
        context,
        () => controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}
