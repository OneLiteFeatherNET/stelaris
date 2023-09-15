import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nil/nil.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/model/block_model.dart';
import 'package:stelaris_ui/api/state/actions/block_actions.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/feature/base/button/save_button.dart';
import 'package:stelaris_ui/feature/base/cards/text_input_card.dart';
import 'package:stelaris_ui/feature/base/model_container_list.dart';
import 'package:stelaris_ui/feature/base/model_text.dart';
import 'package:stelaris_ui/feature/dialogs/setup_dialog.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/api/tabs/tab_pages.dart';

class BlockPage extends StatefulWidget {
  const BlockPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BlockPageState();
  }
}

class BlockPageState extends State<BlockPage> with BaseLayout {
  final ValueNotifier<BlockModel?> selectedItem = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return ModelContainerList<BlockModel>(
      converter: (store) => store.state.blocks,
      action: InitBlockAction(),
      tabPages: (pages) {
        List<Tab> requiredTabs = List.from(pages, growable: true);
        requiredTabs.removeWhere(
            (element) => identical(element.text, TabPage.meta.content));
        return requiredTabs;
      },
      mapToDeleteDialog: (value) {
        return [
          TextSpan(
              text: context.l10n.delete_dialog_first_line, style: whiteStyle),
          TextSpan(text: value.name ?? unknownEntry, style: redStyle),
          TextSpan(text: context.l10n.delete_dialog_entry, style: whiteStyle),
        ];
      },
      mapToDeleteSuccessfully: (value) {
        StoreProvider.dispatch(context, RemoveBlockAction(value));
        return true;
      },
      selectedItem: selectedItem,
      page: mapPageToWidget,
      mapToDataModelItem: (value) => ModelText(displayName: value.name),
      openFunction: () {
        showDialog(
          context: context,
          useRootNavigator: false,
          builder: (BuildContext context) {
            return SetUpDialog<BlockModel>(
              buildModel: (name, description) {
                return BlockModel(name: name);
              },
              finishCallback: (model) {
                StoreProvider.dispatch(context, AddBlockAction(model));
                Navigator.pop(context);
                selectedItem.value = model;
              },
            );
          },
        );
      },
    );
  }

  Widget mapPageToWidget(TabPage e, ValueNotifier<BlockModel?> test) {
    switch (e) {
      case TabPage.general:
        return ValueListenableBuilder<BlockModel?>(
            valueListenable: test,
            builder: (BuildContext context, BlockModel? value, Widget? child) {
              return getGeneralContent(value);
            });
      case TabPage.meta:
        return nil;
    }
  }

  Widget getGeneralContent(BlockModel? model) {
    if (model == null) {
      return nil;
    }

    return Stack(
      children: [
        Wrap(
          children: [
            TextInputCard<String>(
              title: Text(context.l10n.card_name),
              currentValue: model.name ?? "",
              infoText: context.l10n.tooltip_name,
              formatter: [FilteringTextInputFormatter.allow(stringPattern)],
              valueUpdate: (value) {
                if (value == model.name) return;
                final oldModel = model;
                final newEntry = oldModel.copyWith(name: value);
                setState(() {
                  StoreProvider.dispatch(
                      context, UpdateBlockAction(oldModel, newEntry));
                  selectedItem.value = newEntry;
                });
              },
            ),
            TextInputCard<String>(
              title: Text(context.l10n.card_model_data),
              infoText: context.l10n.tooltip_model_data,
              currentValue: model.customModelId.toString(),
              formatter: [FilteringTextInputFormatter.allow(numberPattern)],
              valueUpdate: (value) {
                if (value == model.customModelId) return;
                final oldModel = model;
                final newID = int.parse(value);
                final newEntry = oldModel.copyWith(customModelId: newID);
                setState(() {
                  StoreProvider.dispatch(
                      context, UpdateBlockAction(oldModel, newEntry));
                  selectedItem.value = newEntry;
                });
              },
            ),
          ],
        ),
        SaveButton(
          callback: () {
            ApiService().blockAPI.update(model);
          },
        )
      ],
    );
  }
}
