import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/font/font_string_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/font/selected_font_char_state.dart';
import 'package:stelaris/feature/font/chars/char_list_view.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/feature/font/chars/dialog/font_char_add_dialog.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';

class FontCharPage extends StatelessWidget {
  const FontCharPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedFontCharView>(
      vm: () => SelectedFontCharFactory<FontCharPage>(),
      onInit: (store) => store.dispatchAndWait(FontCharFetchAction()),
      builder: (context, vm) {
        return Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              verticalSpacing25,
              Align(
                alignment: Alignment.center,
                child: ActionChip(
                  avatar: const Icon(Icons.add),
                  label: Text(context.l10n.button_add),
                  onPressed: () => _addDialog(context, vm),
                ),
              ),
              verticalSpacing25,
              Flexible(
                flex: 1,
                fit: FlexFit.loose,
                child: _buildBodyContent(vm),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBodyContent(SelectedFontCharView vm) {
    if (!vm.hasChars) {
      return const EmptyDataWidget();
    } else if (vm.isLoadingMore) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else {
      return CharListView(fontModel: vm);
    }
  }

  /// Shows the dialog to add a new [FontStringDTO].
  /// [context] the involved context
  /// [view] the view model
  void _addDialog(BuildContext context, SelectedFontCharView view) {
    showDialog(
      context: context,
      builder: (context) {
        return FontCharAddDialog(fontModel: view.selected);
      },
    );
  }
}
