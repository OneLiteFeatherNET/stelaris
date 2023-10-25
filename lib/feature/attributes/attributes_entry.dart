import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/attribute_model.dart';
import 'package:stelaris_ui/feature/attributes/attributes_tile.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/feature/base/button/delete_entry_button.dart';

class AttributesEntry extends StatelessWidget with BaseLayout {

  final AttributeModel attributeModel;

  const AttributesEntry({super.key, required this.attributeModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: constructContainer(
        [
          ExpansionTile(
              controlAffinity: ListTileControlAffinity.trailing,
              title: AttributesTile(attributeModel: attributeModel,),
              children: [
                SizedBox(height: 10,),
                Row(
                  children: [
                    // Add your Row children here
                    Text("Test"),
                    SizedBox(width: 10,),
                    Expanded(
                      child: FractionallySizedBox(
                        widthFactor: 0.9,
                        child: TextFormField(
                          controller: TextEditingController(),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20,),
                Row(
                  children: [
                    // Add your Row children here
                    Text("Test"),
                    SizedBox(width: 10,),
                    Expanded(
                      child: FractionallySizedBox(
                        widthFactor: 0.9,
                        child: TextFormField(
                          controller: TextEditingController(),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20,),
                Padding(
                  padding: padding,
                  child: Row(
                    children: [
                      // Add your Row children here
                      Text("Test"),
                      SizedBox(width: 10,),
                      Expanded(
                        child: FractionallySizedBox(
                          widthFactor: 0.9,
                          child: TextFormField(
                            controller: TextEditingController(),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20,)
              ],
          )
        ],
      ),
    );
  }
}
