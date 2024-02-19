import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:nil/nil.dart';
import 'package:stelaris_ui/api/model/font_model.dart';
import 'package:stelaris_ui/api/state/actions/font_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/api/tabs/tab_pages.dart';
import 'package:stelaris_ui/api/util/minecraft/font_type.dart';
import 'package:stelaris_ui/feature/base/base_model_view_tabs.dart';
import 'package:stelaris_ui/feature/base/model_text.dart';
import 'package:stelaris_ui/feature/dialogs/setup_dialog.dart';
import 'package:stelaris_ui/feature/font/font_general_page.dart';
import 'package:stelaris_ui/feature/font/meta/font_meta_page.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';

class FontPage extends StatelessWidget {

  const FontPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, FontModel?>(
      converter: (store) => store.state.selectedFont,
      builder: (context, vm) {
        return BaseModelViewTabs<FontModel>(
          action: InitFontAction(),
          mapToDataModelItem: (value) =>
              ModelText(displayName: value.modelName),
          openFunction: () => _openDialog(context),
          selectedItem: vm,
          mapToDeleteDialog: (value) => _createDeleteText(value, context),
          mapToDeleteSuccessfully: (value) {
            StoreProvider.dispatch(context, RemoveFontsAction(value));
            Navigator.pop(context);
            return true;
          },
          converter: (store) => store.state.fonts,
          callFunction: (model) =>
            StoreProvider.dispatch(context, SelectFontAction(model)),
          page: (page, notification) => _mapPageToWidget(page, notification),
          tabPages: (pages) => pages,
        );
      },
    );
  }

  void _openDialog(BuildContext context) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return SetUpDialog<FontModel>(
          buildModel: (name, description) {
            return FontModel(
                modelName: name,
                description: description,
                type: FontType.bitmap.displayName);
          },
          finishCallback: (model) {
            StoreProvider.dispatch(context, AddFontAction(model));
            Navigator.pop(context);
          },
        );
      },
    );
  }

  List<TextSpan> _createDeleteText(FontModel value, BuildContext context) {
    return [
      TextSpan(
        text: context.l10n.delete_dialog_first_line,
        style: whiteStyle,
      ),
      TextSpan(
        text: value.modelName ?? unknownEntry,
        style: redStyle,
      ),
      TextSpan(
        text: context.l10n.delete_dialog_entry,
        style: whiteStyle,
      ),
    ];
  }

  Widget _mapPageToWidget(TabPage value, FontModel? clickedModel) {
    if (clickedModel == null) return nil;
    switch (value) {
      case TabPage.general:
        return FontGeneralPage(model: clickedModel);
      case TabPage.meta:
        return FontMetaPage(model: clickedModel);
    }
  }
}
