// SPIKE: throwaway proof of concept for rule based blockstate editing.
import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/blockstate/block_picker_dialog.dart';
import 'package:stelaris/feature/blockstate/block_state_rules.dart';
import 'package:stelaris/feature/blockstate/block_state_rules_tab.dart';
import 'package:stelaris/feature/blockstate/block_state_store.dart';
import 'package:stelaris/feature/dialogs/model_delete_dialog.dart';
import 'package:stelaris/feature/dialogs/model_info_dialog.dart';
import 'package:stelaris/feature/dialogs/notes_view_dialog.dart';
import 'package:stelaris/feature/model/model_card_content.dart';
import 'package:stelaris/feature/model/model_grid.dart';
import 'package:stelaris/feature/model/model_grid_card.dart';
import 'package:stelaris/feature/model/model_notes.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/notes.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The namespace and the path of a block key, e.g. `minecraft` and
/// `pink_petals`. The cards build the namespaced key from both, like the
/// project key and the model key on the other pages.
(String, String) _split(String? key) {
  final value = key ?? '';
  final colon = value.indexOf(':');
  return colon < 0
      ? ('minecraft', value)
      : (value.substring(0, colon), value.substring(colon + 1));
}

/// Writes the notes of a blockstate, for the notes dialog of the cards.
class _BlockStateNotesAction extends ReduxAction<AppState> {
  _BlockStateNotesAction(this.model, this.notes);

  final BlockStateModel model;
  final String? notes;

  @override
  AppState? reduce() {
    BlockStateStore.shared.update(model.copyWith(comment: notes));
    return null;
  }
}

/// The blockstates of the project as a grid of cards, and the selected one
/// opened in place of the grid, like the models page. The selection is
/// [selectedId]; a new one is reported through [onSelected], so the route
/// keeps it in the URL.
///
/// Every blockstate is a context: its name and its block are fixed once it
/// is created, its notes are edited from the card like on the other pages,
/// so what is left to edit are its rules.
class BlockStatePage extends StatelessWidget {
  const BlockStatePage({this.selectedId, this.onSelected, super.key});

  final String? selectedId;
  final ValueChanged<String?>? onSelected;

  @override
  Widget build(BuildContext context) {
    final store = BlockStateStore.shared;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final selected = store.byId(selectedId);
        if (selected != null) {
          return _BlockStateDetail(
            key: ValueKey(selected.id),
            entry: selected,
            others: store.othersOf(selected),
            onBack: () => onSelected?.call(null),
          );
        }
        return _BlockStateList(
          entries: store.entries,
          onSelected: (id) => onSelected?.call(id),
        );
      },
    );
  }
}

class _BlockStateList extends StatelessWidget {
  const _BlockStateList({required this.entries, required this.onSelected});

  final List<BlockStateModel> entries;
  final ValueChanged<String?> onSelected;

  Future<void> _add(BuildContext context) async {
    final created = await showDialog<BlockStateModel>(
      context: context,
      builder: (context) => const _CreateDialog(),
    );
    if (created != null) onSelected(created.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: l10n.blockstate_list_title(entries.length),
            actions: [
              PageHeaderAction(
                icon: addModelIcon,
                label: l10n.button_add,
                primary: true,
                onPressed: () => _add(context),
              ),
            ],
          ),
          verticalSpacing10,
          Expanded(
            child: entries.isEmpty
                ? Center(child: Text(l10n.blockstate_empty))
                : ModelGrid<BlockStateModel>(
                    items: entries,
                    itemBuilder: (context, entry) {
                      final (namespace, path) = _split(entry.key);
                      return ModelGridCard<BlockStateModel>(
                        key: ValueKey(entry.id),
                        rawModel: entry,
                        mapToDataModelItem: (entry) => ModelCardContent(
                          name: entry.uiName,
                          modelKey: path,
                          projectKey: namespace,
                        ),
                        deleteTitle: l10n.blockstate_delete_title,
                        deleteWarning: l10n.blockstate_delete_warning,
                        mapToDeleteSuccessfully: (entry) {
                          BlockStateStore.shared.remove(entry.id);
                          return true;
                        },
                        nameSelector: (entry) => entry.uiName,
                        keySelector: (_) => path,
                        projectKey: namespace,
                        notes: ModelNotes(
                          read: (entry) => entry.comment,
                          update: _BlockStateNotesAction.new,
                        ),
                        onTap: () => onSelected(entry.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Asks for the two things fixed for good: the name and the block.
class _CreateDialog extends StatefulWidget {
  const _CreateDialog();

  @override
  State<_CreateDialog> createState() => _CreateDialogState();
}

class _CreateDialogState extends State<_CreateDialog> {
  final _name = TextEditingController();
  BlockSpec? _block;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickBlock() async {
    final block = await showBlockPicker(
      context,
      contexts: BlockStateStore.shared.contextCounts,
      current: _block?.key,
    );
    if (block != null) setState(() => _block = block);
  }

  void _create() {
    final name = _name.text.trim();
    final block = _block;
    if (name.isEmpty || block == null) return;
    Navigator.of(context).pop(BlockStateStore.shared.add(name, block));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final block = _block;
    final contexts = block == null
        ? 0
        : BlockStateStore.shared.contextCounts[block.key] ?? 0;
    return AlertDialog(
      title: Text(l10n.blockstate_create_title),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.blockstate_create_name,
              ),
              onSubmitted: (_) => _create(),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickBlock,
              icon: const Icon(Icons.view_in_ar_outlined),
              label: Text(
                block == null
                    ? l10n.blockstate_picker_title
                    : '${block.displayName} (${block.key})',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              contexts == 0
                  ? l10n.blockstate_create_fixed
                  : l10n.blockstate_create_shared(contexts),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.button_cancel),
        ),
        FilledButton(
          onPressed: block == null ? null : _create,
          child: Text(l10n.button_add),
        ),
      ],
    );
  }
}

class _BlockStateDetail extends StatelessWidget {
  const _BlockStateDetail({
    required this.entry,
    required this.others,
    required this.onBack,
    super.key,
  });

  final BlockStateModel entry;
  final List<BlockStateModel> others;
  final VoidCallback onBack;

  String get _namespacedKey => entry.key ?? '';

  void _openNotes(BuildContext context, String notes) => showDialog<void>(
    context: context,
    builder: (_) => NotesViewDialog(name: entry.uiName, notes: notes),
  );

  void _openInfo(BuildContext context) => showDialog<void>(
    context: context,
    builder: (_) => ModelInfoDialog(
      name: entry.uiName,
      namespacedKey: _namespacedKey,
      id: entry.id,
      creationDate: entry.creationDate,
      modificationDate: entry.modificationDate,
    ),
  );

  Future<void> _openDelete(BuildContext context) async {
    final deleted = await showDialog<bool>(
      context: context,
      builder: (_) => ModelDeleteDialog<BlockStateModel>(
        title: context.l10n.blockstate_delete_title,
        name: entry.uiName,
        value: entry,
        namespacedKey: _namespacedKey,
        warning: context.l10n.blockstate_delete_warning,
        successfully: (_) => true,
      ),
    );
    if (deleted != true) return;
    onBack();
    BlockStateStore.shared.remove(entry.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final notes = notesSummary(entry.comment) == null
        ? null
        : entry.comment!.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: PageHeader(
            title: entry.uiName,
            onBack: onBack,
            compactBelow: PageHeader.detailCompactThreshold,
            actions: [
              PageHeaderAction(
                icon: Badge(
                  isLabelVisible: notes != null,
                  smallSize: 8,
                  child: Icon(
                    notes != null
                        ? Icons.sticky_note_2
                        : Icons.sticky_note_2_outlined,
                  ),
                ),
                label: l10n.action_notes,
                // Read only, they are edited from the overview.
                onPressed: notes == null
                    ? null
                    : () => _openNotes(context, notes),
              ),
              PageHeaderAction(
                icon: const Icon(Icons.info_outline),
                label: l10n.menu_item_info,
                onPressed: () => _openInfo(context),
              ),
              PageHeaderAction(
                icon: deleteIcon,
                label: l10n.button_delete,
                onPressed: () => _openDelete(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlockStateRulesTab(
            entry: entry,
            others: others,
            onChanged: BlockStateStore.shared.update,
          ),
        ),
      ],
    );
  }
}
