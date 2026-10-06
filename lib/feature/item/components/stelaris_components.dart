import 'package:vulpes_data/component.dart';

/// The components every item has, so they can't be removed.
///
/// Mirrors `vulpes.item-components.required` of the backend, which creates
/// them with every item; a key added there has to be added here too.
const Set<String> requiredComponents = {'stelaris:material'};

/// The components Stelaris adds on top of the vanilla data components. They
/// describe the item stack itself and are listed first, under Custom.
const List<ComponentSpec> stelarisComponents = [
  ComponentSpec(
    'stelaris:material',
    'Material',
    ComponentCategory.custom,
    'MATERIAL',
    KeySchema(registry: 'item'),
  ),
  ComponentSpec(
    'stelaris:amount',
    'Amount',
    ComponentCategory.custom,
    'AMOUNT',
    IntSchema(min: 1, max: 99),
  ),
];

/// Whether a component is required, derived from its key.
extension StelarisComponentSpec on ComponentSpec {
  /// Whether every item has the component, so it can't be removed.
  bool get isRequired => requiredComponents.contains(key);
}
