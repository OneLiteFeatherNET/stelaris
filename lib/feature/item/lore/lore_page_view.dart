import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/factory/item/selected_item_state.dart';
import 'package:stelaris/feature/dialogs/entry_update_dialog.dart';
import 'package:stelaris/feature/item/lore/grabbed_card.dart';
import 'package:stelaris/feature/item/lore/lore_delete_checkbox.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/functions.dart';

class LorePageView extends StatelessWidget {
  const LorePageView({
    required this.isEditing,
    required this.view,
    super.key,
  });

  final bool isEditing;
  final SelectedItemView view;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      proxyDecorator: (child, index, animation) {
        return GrabbedCard(child: child);
      },
      itemBuilder: (context, index) {
        final key = view.loreLines[index];
        return ListTile(
          key: Key(index.toString()),
          title: Text(key, overflow: TextOverflow.ellipsis),
          leading: Text('${index + 1}'),
          trailing: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: isEditing
                ? LoreDeleteCheckbox(
                    index: index,
                    function: (add, index) {
                      if (add) {
                        view.addFieldToDelete(key);
                      } else {
                        view.removeFieldToDelete(key);
                      }
                    },
                  )
                : _getEditButton(key),
          ),
        );
      },
      itemCount: view.loreLines.length,
      onReorder: (oldIndex, newIndex) {
        if (oldIndex == newIndex) return;
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }

        if (newIndex > view.loreLines.length - 1) {
          newIndex = view.loreLines.length - 1;
        }

        final String oldLine = view.loreLines.removeAt(oldIndex);
        view.loreLines.insert(newIndex, oldLine);
        final newEntry = view.selected.copyWith(lore: view.loreLines);
        context.dispatch(UpdateItemAction(newEntry));
      },
    );
  }

  Widget _getEditButton(String value) {
    return Builder(
      builder: (context) {
        return IconButton(
          onPressed: () => _showDialog(value, context),
          icon: editIcon,
          tooltip: context.l10n.dialog_level_title,
        );
      },
    );
  }

  void _showDialog(String value, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EntryUpdateDialog(
          title: 'Edit lore',
          formKey: GlobalKey<FormState>(),
          valueUpdate: (value) {
            //update(name, value);
            Navigator.pop(context, false);
          },
          formFieldValidator: (value) {
            final String input = value as String;
            return checkIfEmptyAndReturnErrorString(
              input,
              context,
            );
          },
          data: value,
        );
      },
    );
  }
}
