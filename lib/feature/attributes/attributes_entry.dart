import 'package:async_redux/async_redux.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/api/model/attribute_model.dart';
import 'package:stelaris_ui/api/state/actions/attribute_actions.dart';
import 'package:stelaris_ui/feature/attributes/attribute_row.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/feature/base/cards/expandable_header.dart';
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
      width: 500,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 5),
        child: ExpandableNotifier(
          child: Expandable(
            theme: const ExpandableThemeData(
              iconPlacement: ExpandablePanelIconPlacement.left,
              tapHeaderToExpand: false,
            ),
            collapsed: ExpandableHeader(
              title: Text(attributeModel.modelName ?? emptyString),
              isExpanded: false,
              saveCallback: () {
                final newEntry = attributeModel.copyWith(
                  name: nameController.text,
                  defaultValue: double.parse(defaultController.text),
                  maximumValue: double.parse(maxValueController.text),
                );
                StoreProvider.dispatch(context, UpdateAttributeAction(newEntry));
              },
            ),
            expanded: Column(
              children: [
                ExpandableHeader(
                  title: Text(attributeModel.modelName ?? emptyString),
                  saveCallback: () {
                    final newEntry = attributeModel.copyWith(
                      name: nameController.text,
                      defaultValue: double.parse(defaultController.text),
                      maximumValue: double.parse(maxValueController.text),
                    );
                    StoreProvider.dispatch(context, UpdateAttributeAction(newEntry));
                  },
                  isExpanded: true,
                ),
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
            ),
          ),
        ),
      ),
    );
  }
}
