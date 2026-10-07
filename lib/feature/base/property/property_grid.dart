import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/property/property.dart';
import 'package:stelaris/feature/base/property/property_card.dart';

/// Lays out one [PropertyCard] per property, with as many columns as fit,
/// like the components tab's grid. The cards take the height their texts
/// need, so a larger text scale or font doesn't cut them off.
class PropertyGrid extends StatelessWidget {
  const PropertyGrid({required this.properties, super.key});

  static const double _maxCardExtent = 320;
  static const double _spacing = 12;
  static const double _padding = 16;

  final List<Property> properties;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth - 2 * _padding;
        final columns = ((width + _spacing) / (_maxCardExtent + _spacing))
            .floor()
            .clamp(1, 4);
        // Floored, so rounding never pushes the last card of a row into
        // the next one.
        final cardWidth = ((width - _spacing * (columns - 1)) / columns)
            .floorToDouble();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(_padding),
          child: Wrap(
            spacing: _spacing,
            runSpacing: _spacing,
            children: [
              for (final property in properties)
                SizedBox(
                  width: cardWidth,
                  child: PropertyCard(property: property),
                ),
            ],
          ),
        );
      },
    );
  }
}
