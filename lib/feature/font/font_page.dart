import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nil/nil.dart';
import 'package:stelaris/api/model/font_model.dart';
import 'package:stelaris/api/state/actions/font_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/font/font_vm_state.dart';
import 'package:stelaris/feature/base/base_model_view_tabs.dart';
import 'package:stelaris/feature/base/model_text.dart';
import 'package:stelaris/feature/dialogs/entry_update_dialog.dart';
import 'package:stelaris/feature/font/chars/char_card.dart';
import 'package:stelaris/feature/font/font_general_page.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/functions.dart';

class FontPage extends StatelessWidget {
  const FontPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, FontViewModel>(
      vm: () => FontVmFactory(),
      onInit: (store) => store.dispatchAndWait(InitFontAction()),
      onDispose: (store) => store.dispatch(RemoveSelectedFont(), notify: false),
      builder: (context, vm) {
        return BaseModelViewTabs<FontModel>(
          mapToDataModelItem: (value) =>
              ModelText(displayName: value.modelName),
          openFunction: () => _openDialog(context),
          selectedItem: vm.selected,
          mapToDeleteDialog: (value) =>
              createDeleteText(value.modelName, context),
          mapToDeleteSuccessfully: (value) {
            context.dispatch(RemoveFontsAction(value));
            return true;
          },
          callFunction: (model) => context.dispatch(SelectFontAction(model)),
          page: (page, notification) => _mapPageToWidget(page, notification),
          models: vm.models,
          tabPages: (pages) => pages,
          compareFunction: (model) => vm.isSelectedItem(model),
          tabs: _getTabs(),
        );
      },
    );
  }

  void _openDialog(BuildContext context) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return EntryUpdateDialog(
          title: 'Create new font',
          valueUpdate: (value) {
            final FontModel model = FontModel(modelName: value);
            context.dispatch(AddFontAction(model));
            Navigator.pop(context, true);
          },
          formKey: GlobalKey<FormState>(),
          hintText: 'Example name',
          formatters: [
            FilteringTextInputFormatter.allow(stringWithSpacePattern)
          ],
          formFieldValidator: (value) {
            final String input = value as String;
            return checkIfEmptyAndReturnErrorString(input, context);
          },
          clearFunction: (text) => text.trim().isNotEmpty,
        );
      },
    );
  }

  List<Tab> _getTabs() {
    return [
      const Tab(
        child: Text(
          'General',
        ),
      ),
      const Tab(
        child: Text(
          'Chars',
        ),
      ),
    ];
  }

  Widget _mapPageToWidget(String value, FontModel? clickedModel) {
    if (value.trim().isEmpty || clickedModel == null) return nil;
    switch (value) {
      case 'General':
        return FontGeneralPage(formKey: GlobalKey<FormState>(),);
      case 'Chars':
        return const CharCard();
    }
    return nil;
  }
}
