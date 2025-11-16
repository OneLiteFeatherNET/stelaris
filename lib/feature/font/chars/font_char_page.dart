import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris/api/model/font/font_string_dto.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/actions/font/font_string_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/font/selected_font_char_state.dart';
import 'package:stelaris/feature/dialogs/delete_dialog.dart';
import 'package:stelaris/feature/font/chars/char_list_view.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/feature/font/chars/dialog/font_char_add_dialog.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';

class FontCharPage extends StatefulWidget {
  const FontCharPage({super.key});

  @override
  State<FontCharPage> createState() => _FontCharPageState();
}

class _FontCharPageState extends State<FontCharPage> {
  @override
  void initState() {
    super.initState();
  }

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
                  onPressed: () => _addDialog(vm),
                ),
              ),
              verticalSpacing25,
              Flexible(
                flex: 1,
                fit: FlexFit.loose,
                child: (!vm.hasChars)
                    ? const EmptyDataWidget()
                    : vm.isLoadingMore
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : CharListView(fontModel: vm),
              ),
            ],
          ),
        );
      },
    );
  }

  List<TextSpan> _getDeleteHeader(BuildContext context, List<String> keys) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    final spanTiles = List.generate(keys.length, (index) {
      return TextSpan(text: '${keys[index]}\n', style: redStyle);
    });
    spanTiles.insert(
      0,
      TextSpan(
        text: 'The deletion contains following entries:\n\n',
        style: textStyle,
      ),
    );
    return spanTiles;
  }

  void _showDeleteDialog(SelectedFontCharView view, BuildContext context) {
    if (view.selectedFields.isEmpty) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteDialog<Set<FontStringDTO>>(
          title: Text(
            context.l10n.dialog_delete_confirm,
            textAlign: TextAlign.center,
          ),
          header: _getDeleteHeader(context, ["Hallo"]),
          value: view.selectedFields,
          successfully: (value) {
            if (!view.hasChars) return false;
            final oldEntry = view.selected;
            final List<FontStringDTO> chars = List.of(
              view.selected.chars.items,
              growable: true,
            );

            for (FontStringDTO element in view.selectedFields) {
              chars.remove(element);
            }

            view.clearDeleted();

            // final newEntry = oldEntry.copyWith(chars: chars);
            context.dispatch(UpdateFontAction(oldEntry));
            return true;
          },
        );
      },
    );
  }

  void _addDialog(SelectedFontCharView view) {
    showDialog(
      context: context,
      builder: (context) {
        return FontCharAddDialog(fontModel: view.selected);
      },
    );
  }
}
