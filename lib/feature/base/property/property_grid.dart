import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/property/property.dart';
import 'package:stelaris/feature/base/property/property_card.dart';

/// Lays out one [PropertyCard] per property, with as many columns as fit,
/// like the components tab's grid.
class PropertyGrid extends StatelessWidget {
  const PropertyGrid({required this.properties, super.key});

  static const double _maxCardExtent = 320;
  static const double _cardHeight = 80;
  static const double _spacing = 12;

  final List<Property> properties;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            ((constraints.maxWidth + _spacing) / (_maxCardExtent + _spacing))
                .floor()
                .clamp(1, 4);
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: _cardHeight,
            crossAxisSpacing: _spacing,
            mainAxisSpacing: _spacing,
          ),
          itemCount: properties.length,
          itemBuilder: (context, index) =>
              PropertyCard(property: properties[index]),
        );
      },
    );
  }
}
