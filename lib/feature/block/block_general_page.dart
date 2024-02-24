import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/model/block_model.dart';
import 'package:stelaris_ui/api/state/actions/block_actions.dart';
import 'package:stelaris_ui/feature/base/button/save_button.dart';
import 'package:stelaris_ui/feature/base/cards/text_input_card.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';

class BlockGeneralPage extends StatelessWidget {
  final BlockModel selectedBlock;

  const BlockGeneralPage({
    required this.selectedBlock,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Wrap(
          children: [
            TextInputCard<String>(
              display: context.l10n.card_name,
              currentValue: selectedBlock.name ?? emptyString,
              tooltipMessage: context.l10n.tooltip_name,
              formatter: [FilteringTextInputFormatter.allow(stringPattern)],
              valueUpdate: (value) {
                if (value == selectedBlock.name) return;
                final oldModel = selectedBlock;
                final newEntry = oldModel.copyWith(name: value);
                StoreProvider.dispatch(
                    context, UpdateBlockAction(oldModel, newEntry));
              },
            ),
            TextInputCard<int>(
              display: context.l10n.card_model_data,
              tooltipMessage: context.l10n.tooltip_model_data,
              currentValue: selectedBlock.customModelId.toString(),
              formatter: [FilteringTextInputFormatter.allow(numberPattern)],
              valueUpdate: (value) {
                if (value == selectedBlock.customModelId) return;
                final oldModel = selectedBlock;
                final newID = value ?? 0;
                final newEntry = oldModel.copyWith(customModelId: newID);
                StoreProvider.dispatch(
                    context, UpdateBlockAction(oldModel, newEntry));
              },
            ),
          ],
        ),
        SaveButton(
          callback: ApiService().blockAPI.update,
          parameter: selectedBlock,
        ),
      ],
    );
  }
}
