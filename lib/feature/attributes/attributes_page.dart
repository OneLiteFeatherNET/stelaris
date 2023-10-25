import 'package:flutter/material.dart';
import 'package:stelaris_ui/feature/attributes/attributes_entry.dart';

import '../../api/model/attribute_model.dart';
import '../base/position_bottom_right.dart';

class AttributesPage extends StatelessWidget {
  const AttributesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(

          child: Wrap(
            clipBehavior: Clip.hardEdge,
            children: [
              const SizedBox(height: 10),
              const Text("Attributes"),
              const SizedBox(height: 10),
              const AttributesEntry(attributeModel: AttributeModel(name: "Test", defaultValue: 1, maximumValue: 10,)),
            ],
          ),
        ),
        PositionBottomRight(
          child: FloatingActionButton.extended(
            heroTag: UniqueKey(),
            onPressed: () {},
            label: Text("Add"),
            icon: Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
