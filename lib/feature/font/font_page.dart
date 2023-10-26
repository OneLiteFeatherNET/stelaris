import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:nil/nil.dart';
import 'package:stelaris_ui/api/model/font_model.dart';
import 'package:stelaris_ui/api/state/actions/font_actions.dart';
import 'package:stelaris_ui/api/tabs/tab_pages.dart';
import 'package:stelaris_ui/api/util/minecraft/font_type.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/feature/base/model_container_list.dart';
import 'package:stelaris_ui/feature/base/model_text.dart';
import 'package:stelaris_ui/feature/dialogs/setup_dialog.dart';
import 'package:stelaris_ui/feature/font/font_general_page.dart';
import 'package:stelaris_ui/feature/font/font_meta_page.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';

class FontPage extends StatefulWidget {
  const FontPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FontPageState();
  }
}

class FontPageState extends State<FontPage> with BaseLayout {
  final ValueNotifier<FontModel?> selectedItem = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return ModelContainerList<FontModel>(
      action: InitFontAction(),
      tabPages: (pages) => pages,
      converter: (store) => store.state.fonts,
      mapToDeleteDialog: (value) {
        return [
          TextSpan(
              text: context.l10n.delete_dialog_first_line, style: whiteStyle),
          TextSpan(
            text: value.modelName ?? unknownEntry,
            style: redStyle,
          ),
          TextSpan(
            text: context.l10n.delete_dialog_entry,
            style: whiteStyle,
          ),
        ];
      },
      mapToDeleteSuccessfully: (value) {
        StoreProvider.dispatch(context, RemoveFontsAction(value));
        Navigator.pop(context);
        return true;
      },
      selectedItem: selectedItem,
      page: mapPageToWidget,
      mapToDataModelItem: (value) => ModelText(displayName: value.modelName),
      openFunction: () {
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
                selectedItem.value = model;
              },
            );
          },
        );
      },
    );
  }

  Widget mapPageToWidget(TabPage value, ValueNotifier<FontModel?> test) {
    switch (value) {
      case TabPage.general:
        return ValueListenableBuilder<FontModel?>(
          valueListenable: test,
          builder: (BuildContext context, FontModel? value, Widget? child) {
            if (value == null) return nil;
            return FontGeneralPage(model: value, selectedItem: selectedItem);
          },
        );
      case TabPage.meta:
        return ValueListenableBuilder<FontModel?>(
          valueListenable: test,
          builder: (BuildContext context, FontModel? value, Widget? child) {
            if (value == null) return nil;
            return FontMetaPage(model: value, selectedItem: selectedItem);
          },
        );
    }
  }
}
