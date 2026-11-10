import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/font/font_string_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/font/selected_font_char_state.dart';
import 'package:stelaris/feature/font/chars/char_list_view.dart';
import 'package:stelaris/feature/font/chars/font_char_row_warning.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/feature/font/chars/dialog/font_char_dialog.dart';
import 'package:stelaris/feature/font/chars/dialog/font_char_info_dialog.dart';
import 'package:stelaris/feature/base/page_header.dart';
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader.small(
                title: context.l10n.tab_characters,
                actions: [
                  PageHeaderAction(
                    key: const Key('font_char_help'),
                    icon: const Icon(Icons.help_outline),
                    label: context.l10n.button_help,
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => const FontCharInfoDialog(),
                    ),
                  ),
                  PageHeaderAction(
                    key: const Key('font_char_add'),
                    icon: const Icon(Icons.add),
                    label: context.l10n.button_add,
                    primary: true,
                    onPressed: () => _addDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FontCharRowWarning(lengths: vm.lineLengths),
              Expanded(child: _buildBodyContent(vm)),
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
  void _addDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const FontCharDialog());
  }
}
