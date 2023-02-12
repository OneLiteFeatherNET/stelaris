import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:nil/nil.dart';
import 'package:stelaris_ui/api/model/font_model.dart';
import 'package:stelaris_ui/api/state/actions/font_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/api/tabs/tab_pages.dart';
import 'package:stelaris_ui/api/util/minecraft/font_type.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/feature/base/model_container_list.dart';
import 'package:stelaris_ui/feature/dialogs/stepper/setup_stepper.dart';
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
    return StoreConnector<AppState, List<FontModel>>(
      onInit: (store) {
        store.dispatch(InitFontAction());
      },
      converter: (store) {
        return store.state.fonts;
      },
      builder: (context, vm) {
        if (vm.isNotEmpty) {
          selectedItem.value ??= vm.first;
        }
        return ModelContainerList<FontModel>(
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
            StoreProvider.dispatch(context, RemoveFontsAction(value));
            return true;
          },
          selectedItem: selectedItem,
          items: vm,
          page: mapPageToWidget,
          mapToDataModelItem: (e) {
            return Text(e.name ?? unknownEntry);
          },
          openFunction: () {
            showDialog(
              context: context,
              useRootNavigator: false,
              builder: (BuildContext context) {
                return Dialog(
                  child: SizedBox(
                    width: 500,
                    height: 350,
                    child: Card(
                      elevation: 0.8,
                      child: SetupStepper<FontModel>(
                          buildModel: (name, description) {
                        return FontModel(
                            modelName: name,
                            description: description,
                            type: FontType.bitmap.displayName);
                      }, finishCallback: (model) {
                        StoreProvider.dispatch(context, AddFontAction(model));
                        Navigator.pop(context);
                        selectedItem.value = model;
                      }),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget mapDataToModelItem(FontModel model) {
    return Text(model.name ?? unknownEntry);
  }

  Widget mapPageToWidget(TabPages e, ValueNotifier<FontModel?> test) {
    switch (e) {
      case TabPages.general:
        return ValueListenableBuilder<FontModel?>(
          valueListenable: test,
          builder: (BuildContext context, FontModel? value, Widget? child) {
            if (value == null) return nil;
            return FontGeneralPage(model: value, selectedItem: selectedItem);
          },
        );
      case TabPages.meta:
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
