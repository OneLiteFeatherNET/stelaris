import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/item/item_lore_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/item/item_lore_view_state.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/base/skeleton_bar.dart';
import 'package:stelaris/feature/dialogs/entry_update_dialog.dart';
import 'package:stelaris/feature/item/lore/lore_count_chip.dart';
import 'package:stelaris/feature/item/lore/lore_line_card.dart';
import 'package:stelaris/feature/item/lore/lore_page_view.dart';
import 'package:stelaris/feature/item/item_tab_loader.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/functions.dart';

class LorePage extends StatelessWidget {
  const LorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ItemTabLoader(load: ItemLoreFetchAction.new, builder: _build);
  }

  Widget _build(BuildContext context, bool pending) {
    return StoreConnector<AppState, ItemLoreView>(
      vm: () => ItemLoreViewFactory(),
      builder: (context, vm) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader.small(
                title: context.l10n.tab_lore,
                actions: [
                  LoreCountChip(currentIndex: vm.selected.lore.items.length),
                  PageHeaderAction(
                    icon: const Icon(Icons.add),
                    label: context.l10n.button_add,
                    primary: true,
                    loading: pending,
                    onPressed: () => _openCreateDialog(vm, context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: switch ((pending, vm.selected.lore.hasItems)) {
                  (true, _) => const _LoreSkeleton(),
                  (false, false) => const EmptyDataWidget(),
                  _ => LorePageView(view: vm),
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openCreateDialog(ItemLoreView view, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EntryUpdateDialog(
          valueUpdate: (value) {
            final ItemLoreDto dto = ItemLoreDto(text: value);
            context.dispatch(ItemLoreAddAction(dto));
            Navigator.pop(context);
          },
          formFieldValidator: (value) {
            final String input = value as String;
            return checkIfEmptyAndReturnErrorString(input, context);
          },
          title: context.l10n.button_add_new_line,
          formKey: GlobalKey<FormState>(),
        );
      },
    );
  }
}

/// Stands in for the lore lines while they load: cards in the shape of a
/// [LoreLineCard], with bars for its number and text.
class _LoreSkeleton extends StatelessWidget {
  const _LoreSkeleton();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView.builder(
      key: const Key('lore_skeleton'),
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(right: 16),
      itemCount: 6,
      itemBuilder: (context, index) => Card.filled(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          // Where the number and the text of a card are, 60 high like it.
          padding: EdgeInsets.fromLTRB(44, 23, 16, 23),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: SkeletonBar(widthFactor: 1, height: 14),
              ),
              SizedBox(width: 12),
              Expanded(child: SkeletonBar(widthFactor: 0.6, height: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
