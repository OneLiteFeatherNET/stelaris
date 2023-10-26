import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/state/actions/attribute_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/feature/attributes/attributes_entry.dart';
import 'package:stelaris_ui/feature/dialogs/setup_dialog.dart';

import '../../api/model/attribute_model.dart';
import '../base/position_bottom_right.dart';

class AttributesPage extends StatelessWidget {
  const AttributesPage({super.key});

  @override
  Widget build(BuildContext context) {
    AttributeAddAction(AttributeModel(modelName: "test"));
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: StoreConnector<AppState, List<AttributeModel>>(
                onInit: (store) {
                  store.dispatch(InitAttributeListAction());
                },
                converter: (store) => store.state.attributes,
                builder: (BuildContext context, vm) {
                  return Wrap(
                    clipBehavior: Clip.hardEdge,
                    children: vm
                        .map((e) => AttributesEntry(
                              attributeModel: e,
                            ))
                        .toList(),
                  );
                }),
          ),
        ),
        PositionBottomRight(
          child: FloatingActionButton.extended(
            heroTag: UniqueKey(),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return SetUpDialog<AttributeModel>(
                    buildModel: (name, description) {
                      return AttributeModel(
                          modelName: name);
                    },
                    finishCallback: (model) {
                      StoreProvider.dispatch(context, AttributeAddAction(model));
                      Navigator.pop(context);
                    },
                  );
                },
              );
            },
            label: const Text("Add"),
            icon: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
