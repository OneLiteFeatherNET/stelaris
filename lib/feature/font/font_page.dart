import 'package:async_redux/async_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/font/font_vm_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/dialogs/model_create_dialog.dart';
import 'package:stelaris/feature/model/model_page.dart';
import 'package:stelaris/util/functions.dart';
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
          mapToDataModelItem: (value) => _buildCardContent(context, value),
          mapToDeleteDialog: (value) =>
              createDeleteText(value.uiName, context),
          mapToDeleteSuccessfully: (value) {
            context.dispatch(FontRemoveAction(value));
            return true;
          },
          models: vm.models,
          matchesSearch: (model, query) =>
              model.uiName.toLowerCase().contains(query.toLowerCase()),
          nameSelector: (model) => model.uiName,
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
  /// plus its configured provider, if any.
  Widget _buildCardContent(BuildContext context, FontModel value) {
    final provider = value.provider;
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
        if (provider != null && provider.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.text_fields_outlined,
                  size: 12,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    provider,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
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
