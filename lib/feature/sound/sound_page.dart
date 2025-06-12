import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris/api/model/sound/sound_event_model.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/sound/sound_vm_state.dart';
import 'package:stelaris/feature/base/base_model_view.dart';
import 'package:stelaris/feature/base/model_text.dart';
import 'package:stelaris/feature/dialogs/entry_update_dialog.dart';
import 'package:stelaris/feature/sound/sound_general_page.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/functions.dart';

class SoundPage extends StatelessWidget {
  const SoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SoundViewModel>(
      vm: () => SoundVmFactory(),
      onInit: (store) => store.dispatchAndWait(InitSoundAction()),
      onDispose: (store) => store.dispatch(RemoveSelectedSoundEvent(), notify: false),
      builder: (context, vm) {
        return BaseModelView<SoundEventModel>(
          mapToDataModelItem: (value) => TextWidget(displayName: value.uiName),
          openFunction: () => _openCreationDialog(context),
          selectedItem: vm.selected,
          mapToDeleteDialog: (value) => createDeleteText(value.uiName, context),
          mapToDeleteSuccessfully: (value) {
            context.dispatch(RemoveSoundAction(value));
            return true;
          },
          callFunction: (model) => context.dispatch(SelectSoundAction(model)),
          models: vm.models,
          child: _mapModelToWidget(vm.selected),
          compareFunction: (model) => vm.isSelectedItem(model),
        );
      },
    );
  }

  Widget? _mapModelToWidget(SoundEventModel? model) {
    print('Selected sound model: $model');
    if (model == null) return null;
    return const SoundGeneralPage();
  }

  void _openCreationDialog(BuildContext context) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return EntryUpdateDialog(
          title: 'Create new sound',
          valueUpdate: (value) {
            final SoundEventModel model = SoundEventModel(uiName: value);
            context.dispatchAndWait(SoundAddAction(model));
            Navigator.pop(context, true);
          },
          formKey: GlobalKey<FormState>(),
          hintText: 'Example name',
          formatters: [
            FilteringTextInputFormatter.allow(stringWithSpacePattern),
          ],
          formFieldValidator: (value) {
            final input = value as String;
            return checkIfEmptyAndReturnErrorString(input, context);
          },
          clearFunction: (text) => text.trim().isNotEmpty,
        );
      },
    );
  }
}
