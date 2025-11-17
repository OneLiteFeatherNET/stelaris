import 'package:flutter/material.dart';
import 'package:stelaris/api/state/factory/item/item_lore_view_state.dart';
import 'package:stelaris/feature/base/action/entry_actions.dart';
import 'package:stelaris/feature/dialogs/entry_update_dialog.dart';
import 'package:stelaris/feature/item/lore/grabbed_card.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/functions.dart';

class LorePageView extends StatelessWidget {
  const LorePageView({
    required this.view,
    super.key,
  });

  final ItemLoreView view;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      proxyDecorator: (child, index, animation) {
        return GrabbedCard(child: child);
      },
      itemBuilder: (context, index) {
        final key = view.selected.lore.items[index];
        return ListTile(
          key: Key(index.toString()),
          title: Text(key.text, overflow: TextOverflow.ellipsis),
          leading: Text('${index + 1}'),
          trailing: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: EntryActions(
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        );
      },
      itemCount: view.selected.lore.items.length,
      onReorder: (oldIndex, newIndex) {
        if (oldIndex == newIndex) return;
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }

        if (newIndex > view.selected.lore.items.length - 1) {
          newIndex = view.selected.lore.items.length - 1;
        }

        // final String oldLine = view.selected.lore.items.removeAt(oldIndex);
        // view.loreLines.insert(newIndex, oldLine);
       // final newEntry = view.selected.copyWith(lore: view.loreLines);
        //context.dispatch(UpdateItemAction(newEntry));
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
