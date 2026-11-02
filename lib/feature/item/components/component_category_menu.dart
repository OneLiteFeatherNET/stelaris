import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/filter/category_filter_menu.dart';
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

  final ComponentCategory? value;

  /// The components per category; categories without any are left out.
  final Map<ComponentCategory, int> counts;
  final ValueChanged<ComponentCategory?> onChanged;

  /// Builds the button; [toggle] opens or closes the menu.
  final Widget Function(BuildContext context, VoidCallback toggle) builder;

  @override
  Widget build(BuildContext context) {
    return CategoryFilterMenu<ComponentCategory>(
      value: value,
      allLabel: context.l10n.component_all_categories,
      keyPrefix: 'component_category_item',
      entries: [
        for (final category in ComponentCategory.values)
          if (counts[category] case final count?)
            (
              value: category,
              label: category.displayName,
              count: count,
              id: category.key,
            ),
      ],
      onChanged: onChanged,
      builder: builder,
    );
  }
}
