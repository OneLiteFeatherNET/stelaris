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
import 'package:stelaris/feature/item/lore/lore_preview.dart';
import 'package:stelaris/feature/item/item_tab_loader.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/functions.dart';

class LorePage extends StatefulWidget {
  const LorePage({super.key});

  @override
  State<LorePage> createState() => _LorePageState();
}

class _LorePageState extends State<LorePage> {
  /// Whether the preview is shown next to the lines. Not kept across app
  /// starts, the app doesn't store settings locally yet.
  bool _showPreview = true;

  /// From this width on there is room for the preview next to the lines.
  static const double _previewBreakpoint = 840;

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide =
                  constraints.maxWidth >= _previewBreakpoint;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PageHeader.small(
                    title: context.l10n.tab_lore,
                    actions: [
                      // All lines, not only the ones loaded so far.
                      LoreCountChip(
                        currentIndex: vm.selected.lore.totalItems,
                      ),
                      _PreviewButton(
                        wide: wide,
                        shown: _showPreview,
                        onPressed: pending || !vm.selected.lore.hasItems
                            ? null
                            : () => wide
                                  ? setState(() => _showPreview = !_showPreview)
                                  : _openPreviewSheet(context),
                      ),
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
                      _ => LorePageView(
                        view: vm,
                        showPreview: wide && _showPreview,
                      ),
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// Without room next to the lines, the preview opens as a bottom sheet.
  void _openPreviewSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => StoreConnector<AppState, ItemLoreView>(
        vm: () => ItemLoreViewFactory(),
        builder: (context, vm) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: LorePreview(item: vm.selected),
        ),
      ),
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

/// Shows and hides the preview next to the lines, or opens it as a bottom
/// sheet when there is no room for it.
class _PreviewButton extends StatelessWidget {
  const _PreviewButton({
    required this.wide,
    required this.shown,
    required this.onPressed,
  });

  final bool wide;
  final bool shown;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return PageHeaderAction(
      key: const Key('lore_preview_toggle'),
      // The icon tells what a press does.
      icon: Icon(
        wide && shown
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined,
      ),
      label: context.l10n.lore_preview_title,
      onPressed: onPressed,
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
