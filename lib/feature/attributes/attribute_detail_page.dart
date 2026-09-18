import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/attributes/attribute_general_page.dart';

/// A routed page that displays the currently selected attribute's details.
///
/// Reached by tapping an attribute in [AttributePage]; relies on
/// [AttributeGeneralPage] reading the selection already dispatched to the
/// store via `SelectAttributeAction` before navigating here.
class AttributeDetailPage extends StatelessWidget {
  const AttributeDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [AttributeGeneralPage()]);
  }
}
