import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/api/model/attribute_model.dart';
import 'package:stelaris_ui/feature/attributes/attribute_row.dart';
import 'package:stelaris_ui/feature/attributes/attributes_tile.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/util/constants.dart';

class AttributesEntry extends StatelessWidget with BaseLayout {
  final AttributeModel attributeModel;

  const AttributesEntry({super.key, required this.attributeModel});

  @override
  Widget build(BuildContext context) {
    var nameController = TextEditingController(text: attributeModel.name ?? "");
    var defaultController =
        TextEditingController(text: "${attributeModel.defaultValue}");
    var maxValueController =
        TextEditingController(text: "${attributeModel.maximumValue}");
    return Container(
      width: 750,
      padding: padding,
      child: constructContainer(
        [
          ExpansionTile(
            controlAffinity: ListTileControlAffinity.trailing,
            title: AttributesTile(
              attributeModel: attributeModel,
            ),
            children: [
              AttributeRow(
                controller: nameController,
                label: "Name",
                formatter: FilteringTextInputFormatter.allow(letterPattern),
              ),
              AttributeRow(
                controller: defaultController,
                label: "Default",
                formatter: FilteringTextInputFormatter.allow(decimalPattern),
              ),
              AttributeRow(
                controller: maxValueController,
                label: "Maximum",
                formatter: FilteringTextInputFormatter.allow(decimalPattern),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          )
        ],
      ),
    );
  }
}
