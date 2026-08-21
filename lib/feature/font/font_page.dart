import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/font/font_vm_state.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/feature/base/model_text.dart';
import 'package:stelaris/feature/base/paginated_model_view_tab.dart';
import 'package:stelaris/feature/dialogs/entry_update_dialog.dart';
import 'package:stelaris/feature/font/chars/font_char_page.dart';
import 'package:stelaris/feature/font/face/font_face_page.dart';
import 'package:stelaris/feature/font/font_general_page.dart';
import 'package:stelaris/util/formatter/formatters.dart';
import 'package:stelaris/util/functions.dart';
import 'package:stelaris/util/l10n_ext.dart';

class FontPage extends StatelessWidget {
  const FontPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, FontViewModel>(
      vm: () => FontVmFactory(),
      onInit: (store) => store.dispatchAndWait(InitFontAction()),
      onDispose: (store) => store.dispatch(RemoveSelectedFont(), notify: false),
      builder: (context, vm) {
        return PaginatedBaseModelViewTabs<FontModel>(
          mapToDataModelItem: (value) => TextWidget(displayName: value.uiName),
          openFunction: () => _openDialog(context),
          selectedItem: vm.selected,
          mapToDeleteDialog: (value) => createDeleteText(value.uiName, context),
          mapToDeleteSuccessfully: (value) {
            context.dispatch(FontRemoveAction(value));
            return true;
          },
          callFunction: (model) => context.dispatch(SelectFontAction(model)),
          page: (page, notification) =>
              _mapPageToWidget(context, page, notification),
          models: vm.models,
          tabPages: (pages) => pages,
          compareFunction: (model) => vm.isSelectedItem(model),
          tabs: _getTabs(),
          isLoadingMore: vm.isLoadingMore,
          hasMore: vm.hasNextPage,
          onLoadMore: vm.hasNextPage && !vm.isLoadingMore
              ? () => context.dispatch(InitFontAction())
              : null,
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
          title: context.l10n.dialog_font_create_title,
          valueUpdate: (value) {
            final FontModel model = FontModel(uiName: value);
            context.dispatch(FontAddAction(model));
            Navigator.pop(context, true);
          },
          formKey: GlobalKey<FormState>(),
          hintText: 'Example name',
          formatters: [withSpacesFormatter],
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
      const Tab(child: Text('General')),
      const Tab(child: Text('FontFace')),
      const Tab(child: Text('Chars')),
    ];
  }

  /// Maps the given [FontModel] to the right widget.
  /// If the model is null, it returns an [Expanded] widget with an [EmptyDataWidget].
  /// Otherwise, it returns an instance of [FontGeneralPage] or [FontCharPage].
  Widget _mapPageToWidget(
    BuildContext context,
    String value,
    FontModel? listenable,
  ) {
    if (value.trim().isEmpty || listenable == null) {
      return EmptyDataWidget.standard(
        header: context.l10n.empty_data_header,
        subHeader: context.l10n.empty_data_subHeader,
      );
    }
    return switch (value) {
      'General' => const FontGeneralPage(),
      'FontFace' => const FontFacePage(),
      'Chars' => const FontCharPage(),
      _ => const Placeholder(), // optional default case
    };
  }
}
