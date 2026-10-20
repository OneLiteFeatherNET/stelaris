import 'package:async_redux/async_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/sound/sound_vm_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/model/model_card_content.dart';
import 'package:stelaris/feature/model/model_create.dart';
import 'package:stelaris/feature/model/model_notes.dart';
import 'package:stelaris/feature/model/model_page.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/feature/model/model_copy.dart';

/// A widget that represents the sound event management page.
///
/// The [SoundPage] allows users to view, search, and manage sound events
/// through a [ModelPage]. It provides a dialog for creating new sound
/// events and handles the state management through Redux. Tapping a sound
/// event navigates to its dedicated detail route, since its General/Entries
/// tabs need more room than a dialog can comfortably offer.
class SoundPage extends StatelessWidget {
  const SoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SoundViewModel>(
      vm: () => SoundVmFactory(),
      onInit: (store) => store.dispatchAndWait(InitSoundAction()),
      builder: (context, vm) {
        return ModelPage<SoundEventModel>(
          entry: NavigationEntry.sound,
          mapToDataModelItem: (value) => ModelCardContent(
            name: value.uiName,
            modelKey: value.key,
            projectKey: vm.projectKey,
          ),
          deleteTitle: context.l10n.dialog_sound_delete_title,
          deleteWarning: context.l10n.delete_dialog_related_sound,
          mapToDeleteSuccessfully: (value) {
            context.dispatch(SoundRemoveAction(value));
            return true;
          },
          models: vm.models,
          nameSelector: (model) => model.uiName,
          keySelector: (model) => model.key ?? '',
          notes: ModelNotes(
            read: (model) => model.comment,
            update: SoundNotesUpdateAction.new,
          ),
          copy: ModelCopy(
            title: (l10n) => l10n.dialog_sound_copy,
            relations: soundCopyRelations,
            action: SoundCopyAction.new,
          ),
          projectKey: vm.projectKey,
          matchesFilter: (model, filter) => true,
          onAdd: () => openModelCreateDialog(
            context,
            NavigationEntry.sound,
            vm.projectKey,
          ),
          onModelTap: (model) {
            context.dispatch(SelectSoundAction(model));
            context.go('${NavigationEntry.sound.route}/detail');
          },
          onRefresh: () => context.dispatch(RefreshSoundAction()),
          hasMore: vm.hasNextPage,
          isLoadingMore: vm.isLoadingMore,
          onLoadMore: vm.hasNextPage && !vm.isLoadingMore
              ? () => context.dispatch(InitSoundAction())
              : null,
        );
      },
    );
  }
}
