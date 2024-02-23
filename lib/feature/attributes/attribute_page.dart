import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/attribute_model.dart';
import 'package:stelaris_ui/api/state/actions/attribute_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/api/state/factory/attribute_vm_state.dart';
import 'package:stelaris_ui/feature/attributes/attribute_general_page.dart';
import 'package:stelaris_ui/feature/base/base_model_view.dart';
import 'package:stelaris_ui/feature/base/model_text.dart';
import 'package:stelaris_ui/feature/dialogs/setup_dialog.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';

class AttributePage extends StatelessWidget {
  const AttributePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AttributeViewModel>(
      vm: () => AttributeVmFactory(),
      onInit: (store) => store.dispatchAsync(InitAttributeAction()),
      builder: (context, vm) {
        return BaseModelView<AttributeModel>(
          mapToDataModelItem: (value) =>
              ModelText(displayName: value.modelName),
          openFunction: () => _openDialog(context),
          selectedItem: vm.selected,
          mapToDeleteDialog: (value) => _createDeleteText(value, context),
          mapToDeleteSuccessfully: (value) {
            StoreProvider.dispatch(context, AttributeRemoveAction(value));
            return true;
          },
          callFunction: (model) {
            StoreProvider.dispatch(context, SelectAttributeAction(model));
          },
          models: vm.models,
          child: _mapModelToWidget(vm.selected),
        );
      },
    );
  }

  Widget? _mapModelToWidget(AttributeModel? model) {
    if (model == null) return null;
    return AttributeGeneralPage(
      attributeModel: model,
    );
  }

  void _openDialog(BuildContext context) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return SetUpDialog<AttributeModel>(
          buildModel: (name, description) {
            return AttributeModel(modelName: name);
          },
          finishCallback: (model) {
            StoreProvider.dispatch(context, AttributeAddAction(model));
            Navigator.pop(context, true);
          },
        );
      },
    );
  }

  List<TextSpan> _createDeleteText(AttributeModel value, BuildContext context) {
    return [
      TextSpan(text: context.l10n.delete_dialog_first_line),
      TextSpan(
        text: value.modelName ?? unknownEntry,
        style: redStyle,
      ),
      TextSpan(
        text: context.l10n.delete_dialog_entry,
      ),
    ];
  }
}
