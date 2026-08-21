import 'package:stelaris/feature/base/mixins/infinite_scroll_mixin.dart';
import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/item/item_lore_actions.dart';
import 'package:stelaris/api/state/factory/item/item_lore_view_state.dart';
import 'package:stelaris/feature/base/action/entry_actions.dart';
import 'package:stelaris/feature/dialogs/delete_dialog.dart';
import 'package:stelaris/feature/dialogs/entry_update_dialog.dart';
import 'package:stelaris/feature/item/lore/grabbed_card.dart';
import 'package:stelaris/util/functions.dart';
import 'package:stelaris/util/l10n_ext.dart';

class LorePageView extends StatefulWidget {
  const LorePageView({required this.view, super.key});

  final ItemLoreView view;

  @override
  State<LorePageView> createState() => _LorePageViewState();
}

class _LorePageViewState extends State<LorePageView>
    with InfiniteScrollMixin<LorePageView> {
  @override
  bool canLoadMore() {
    final lore = widget.view.selected.lore;
    return lore.hasNextPage;
  }

  @override
  bool isLoadingMore() => widget.view.isLoadingMore;

  @override
  void onLoadMore() {
    context.dispatch(ItemLoreLoadNextPageAction());
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      child: ReorderableListView.builder(
        scrollController: scrollController,
        proxyDecorator: (child, index, animation) {
          return GrabbedCard(child: child);
        },
        itemBuilder: (context, index) {
          final key = widget.view.selected.lore.items[index];
          return ListTile(
            key: Key(key.id!), // Use a unique key from your data model
            title: Text(key.text, overflow: TextOverflow.ellipsis),
            leading: Text('${index + 1}'),
            trailing: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: EntryActions(
                onEdit: () => _showDialog(key),
                onDelete: () => _showDeleteDialog(key),
              ),
            ),
          );
        },
        itemCount: widget.view.selected.lore.items.length,
        onReorder: (oldIndex, newIndex) {
          if (oldIndex == newIndex) return;
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }

          if (newIndex > widget.view.selected.lore.items.length - 1) {
            newIndex = widget.view.selected.lore.items.length - 1;
          }

          // final String oldLine = view.selected.lore.items.removeAt(oldIndex);
          // view.loreLines.insert(newIndex, oldLine);
          // final newEntry = view.selected.copyWith(lore: view.loreLines);
          //context.dispatch(UpdateItemAction(newEntry));
        },
      ),
    );
  }

  void _showDeleteDialog(ItemLoreDto dto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteDialog<ItemLoreDto>(
          title: Text(
            context.l10n.dialog_item_lore_delete_header,
            textAlign: TextAlign.center,
          ),
          header: [TextSpan(text: context.l10n.dialog_item_lore_delete_header)],
          value: dto,
          successfully: (value) {
            context.dispatch(ItemLoreDeleteAction(value));
            return true;
          },
        );
      },
    );
  }

  void _showDialog(ItemLoreDto dto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EntryUpdateDialog(
          title: context.l10n.dialog_item_lore_edit_title,
          formKey: GlobalKey<FormState>(),
          valueUpdate: (value) {
            final updatedDto = dto.copyWith(text: value);
            context.dispatch(ItemLoreUpdateAction(updatedDto));
            Navigator.pop(context, false);
          },
          formFieldValidator: (value) {
            final String input = value as String;
            return checkIfEmptyAndReturnErrorString(input, context);
          },
          data: dto.text,
        );
      },
    );
  }
}
