import 'package:async_redux/async_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/font/font_vm_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/base/chips/info_chip.dart';
import 'package:stelaris/feature/dialogs/model_create_dialog.dart';
import 'package:stelaris/feature/model/model_page.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// A widget that represents the font management page.
///
/// The [FontPage] allows users to view, search, and manage fonts through a
/// [ModelPage]. It provides a dialog for creating new fonts and handles the
/// state management through Redux. Tapping a font navigates to its
/// dedicated detail route, since a font's General/FontFace/Chars tabs need
/// more room than a dialog can comfortably offer.
class FontPage extends StatelessWidget {
  const FontPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, FontViewModel>(
      vm: () => FontVmFactory(),
      onInit: (store) => store.dispatchAndWait(InitFontAction()),
      builder: (context, vm) {
        return ModelPage<FontModel>(
          entry: NavigationEntry.font,
          mapToDataModelItem: (value) =>
              _buildCardContent(context, vm.projectKey, value),
          deleteTitle: context.l10n.dialog_font_delete_title,
          deleteWarning: context.l10n.delete_dialog_related_font,
          mapToDeleteSuccessfully: (value) {
            context.dispatch(FontRemoveAction(value));
            return true;
          },
          models: vm.models,
          nameSelector: (model) => model.uiName,
          keySelector: (model) => model.key ?? '',
          projectKey: vm.projectKey,
          matchesFilter: (model, filter) => true,
          onAdd: () => _openDialog(context, vm.projectKey),
          onModelTap: (model) {
            context.dispatch(SelectFontAction(model));
            context.go('${NavigationEntry.font.route}/detail');
          },
          onRefresh: () => context.dispatch(RefreshFontAction()),
          hasMore: vm.hasNextPage,
          isLoadingMore: vm.isLoadingMore,
          onLoadMore: vm.hasNextPage && !vm.isLoadingMore
              ? () => context.dispatch(InitFontAction())
              : null,
        );
      },
    );
  }

  /// Builds the primary card content for a [FontModel]: its display name
  /// plus its namespaced key (e.g. `manis:test`), derived client-side
  /// from the current project's key and the model's local [FontModel.key].
  Widget _buildCardContent(
    BuildContext context,
    String projectKey,
    FontModel value,
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

  /// Opens a dialog for creating a new font.
  void _openDialog(BuildContext context, String projectKey) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ModelCreateDialog(
          title: context.l10n.dialog_font_create_title,
          projectNamespace: projectKey,
          onSubmit: (name, key) {
            final FontModel model = FontModel(uiName: name, key: key);
            context.dispatch(FontAddAction(model));
            Navigator.pop(context, true);
          },
        );
      },
    );
  }
}
