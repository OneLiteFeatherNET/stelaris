import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:nil/nil.dart';
import 'package:stelaris_ui/api/model/block_model.dart';
import 'package:stelaris_ui/api/state/actions/block_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/feature/base/base_model_view_tabs.dart';
import 'package:stelaris_ui/feature/base/model_text.dart';
import 'package:stelaris_ui/feature/block/block_general_page.dart';
import 'package:stelaris_ui/feature/dialogs/setup_dialog.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/api/tabs/tab_pages.dart';

class BlockPage extends StatelessWidget {
  const BlockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, BlockModel?>(
      converter: (store) => store.state.selectedBlock,
      builder: (context, vm) {
        return BaseModelViewTabs<BlockModel>(
          action: InitBlockAction(),
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
                  },
                );
              },
            );
          },
          selectedItem: vm,
          mapToDeleteDialog: (value) {
            return [
              TextSpan(
                  text: context.l10n.delete_dialog_first_line,
                  style: whiteStyle),
              TextSpan(text: value.name ?? unknownEntry, style: redStyle),
              TextSpan(
                  text: context.l10n.delete_dialog_entry, style: whiteStyle),
            ];
          },
          mapToDeleteSuccessfully: (value) {
            StoreProvider.dispatch(context, RemoveBlockAction(value));
            return true;
          },
          converter: (store) => store.state.blocks,
          callFunction: (model) {
            StoreProvider.dispatch(context, SelectBlockAction(model));
          },
          page: _mapPageToWidget,
          tabPages: (pages) {
            List<Tab> requiredTabs = List.from(pages, growable: true);
            requiredTabs.removeWhere(
                (element) => identical(element.text, TabPage.meta.content));
            return requiredTabs;
          },
        );
      },
    );
  }

  Widget _mapPageToWidget(TabPage page, BlockModel? model) {
    if (page != TabPage.general) return nil;
    if (model == null) return nil;
    return BlockGeneralPage(selectedBlock: model);
  }
}
