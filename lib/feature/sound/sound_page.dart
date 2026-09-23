import 'package:async_redux/async_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/sound/sound_vm_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/base/chips/info_chip.dart';
import 'package:stelaris/feature/dialogs/model_create_dialog.dart';
import 'package:stelaris/feature/model/model_page.dart';
import 'package:stelaris/util/l10n_ext.dart';

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
          mapToDataModelItem: (value) =>
              _buildCardContent(context, vm.projectKey, value),
          deleteTitle: context.l10n.dialog_sound_delete_title,
          deleteWarning: context.l10n.delete_dialog_related_sound,
          mapToDeleteSuccessfully: (value) {
            context.dispatch(SoundRemoveAction(value));
            return true;
          },
          models: vm.models,
          matchesSearch: (model, query) =>
              model.uiName.toLowerCase().contains(query.toLowerCase()),
          nameSelector: (model) => model.uiName,
          keySelector: (model) => model.key ?? '',
          projectKey: vm.projectKey,
          matchesFilter: (model, filter) => true,
          onAdd: () => _openCreationDialog(context, vm.projectKey),
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

  /// Builds the primary card content for a [SoundEventModel]: its display
  /// name plus its namespaced key (e.g. `manis:test`), derived client-side
  /// from the current project's key and the model's local
  /// [SoundEventModel.key].
  Widget _buildCardContent(
    BuildContext context,
    String projectKey,
    SoundEventModel value,
  ) {
    final key = value.key;
    final namespacedKey = key != null && key.isNotEmpty
        ? '$projectKey:$key'
        : null;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.uiName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (namespacedKey != null) ...[
          const SizedBox(height: 6),
          InfoChip(icon: Icons.vpn_key_outlined, text: namespacedKey),
        ],
      ],
    );
  }

  /// Opens a dialog for creating a new sound event.
  void _openCreationDialog(BuildContext context, String projectKey) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ModelCreateDialog(
          title: context.l10n.dialog_sound_create,
          projectNamespace: projectKey,
          onSubmit: (name, key) {
            final model = SoundEventModel(uiName: name, key: key);
            context.dispatch(SoundAddAction(model));
            Navigator.pop(context, true);
          },
        );
      },
    );
  }
}
