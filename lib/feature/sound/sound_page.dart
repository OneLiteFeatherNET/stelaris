import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris/api/model/sound/sound_event_model.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/sound/sound_vm_state.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/feature/base/model_text.dart';
import 'package:stelaris/feature/base/paginated_model_view_tab.dart';
import 'package:stelaris/feature/dialogs/entry_update_dialog.dart';
import 'package:stelaris/feature/sound/sound_file_entries.dart';
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
      onDispose: (store) =>
          store.dispatch(RemoveSelectedSoundEvent(), notify: false),
      builder: (context, vm) {
        return PaginatedBaseModelViewTabs<SoundEventModel>(
          mapToDataModelItem: (value) => TextWidget(displayName: value.uiName),
          openFunction: () => _openCreationDialog(context),
          selectedItem: vm.selected,
          mapToDeleteDialog: (value) => createDeleteText(value.uiName, context),
          mapToDeleteSuccessfully: (value) {
            context.dispatch(SoundRemoveAction(value));
            return true;
          },
          callFunction: (model) => context.dispatch(SelectSoundAction(model)),
          models: vm.models,
          page: (page, model) => _mapPageToWidget(page, model),
          compareFunction: (model) => vm.isSelectedItem(model),
          tabs: _getTabs(),
          tabPages: (pages) => pages,
          isLoadingMore: vm.isLoadingMore,
          hasMore: vm.hasNextPage,
          onLoadMore: vm.hasNextPage && !vm.isLoadingMore
              ? () => context.dispatch(InitSoundAction())
              : null,
        );
      },
    );
  }

  void _openCreationDialog(BuildContext context) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return EntryUpdateDialog(
          title: 'Create sound',
          valueUpdate: (value) {
            final model = SoundEventModel(uiName: value);
            context.dispatch(SoundAddAction(model));
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

  List<Tab> _getTabs() {
    return [
      const Tab(child: Text('General')),
      const Tab(child: Text('Entries')),
    ];
  }

  /// Maps the given [SoundEventModel] to the right widget.
  /// If the model is null, it returns an [Expanded] widget with an [EmptyDataWidget].
  /// Otherwise, it returns an instance of [SoundGeneralPage] or [SoundFileEntryPage].
  Widget _mapPageToWidget(String value, SoundEventModel? listenable) {
    if (value.trim().isEmpty || listenable == null) {
      return const EmptyDataWidget.standard(
        header: 'No data selected',
        subHeader: 'Please create or selected a model',
      );
    }
    return switch (value) {
      'General' => SoundGeneralPage(key: ValueKey('sound${listenable.id}')),
      'Meta' => const SoundFileEntryPage(),
      _ => const Placeholder(), // optional default case
    };
  }
}
