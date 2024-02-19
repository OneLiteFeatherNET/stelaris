import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/item_model.dart';

import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/feature/base/button/save_button.dart';
import 'package:stelaris_ui/feature/item/meta/enchantment_card.dart';
import 'package:stelaris_ui/feature/item/meta/flag_card.dart';
import 'package:stelaris_ui/feature/item/meta/lore_card.dart';
import 'package:stelaris_ui/feature/item/item_reducer.dart';
import 'package:stelaris_ui/util/constants.dart';

class ItemMetaPage extends StatelessWidget with DropDownItemReducer {
  final ItemModel model;

  ItemMetaPage({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Wrap(
            clipBehavior: Clip.hardEdge,
            children: [
              verticalSpacing10,
              FlagCard(model: model),
              verticalSpacing10,
              EnchantmentCard(model: model),
              verticalSpacing10,
              LoreCard(model: model),
            ],
          ),
        ),
        SaveButton(
          callback: () {
            ApiService().itemApi.update(model);
          },
        )
      ],
    );
  }
}
