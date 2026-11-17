import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/block_state_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/feature/blockstate/block_picker.dart';
import 'package:stelaris/feature/blockstate/block_state_rules.dart';
import 'package:stelaris/util/dispatch_ext.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Opens the dialog that creates a blockstate. Resolves to whether one was
/// created.
Future<bool> openBlockStateCreateDialog(BuildContext context) async =>
    await showDialog<bool>(
      context: context,
      builder: (_) => const BlockStateCreateDialog(),
    ) ??
    false;

/// How many of [blockStates] use each block.
Map<String, int> contextCountsOf(List<BlockStateModel> blockStates) {
  final counts = <String, int>{};
  for (final blockState in blockStates) {
    if (blockState.key case final key?) counts[key] = (counts[key] ?? 0) + 1;
  }
  return counts;
}

/// Asks for the two things fixed for good, the name and the block, and
/// creates the blockstate with one rule for every state. It closes once the
/// blockstate exists, a failure keeps what was entered and shows why.
///
/// The block is chosen in a second step of the same dialog: its back arrow
/// and Cancel return to the name.
class BlockStateCreateDialog extends StatefulWidget {
  const BlockStateCreateDialog({super.key});

  @override
  State<BlockStateCreateDialog> createState() => _BlockStateCreateDialogState();
}

class _BlockStateCreateDialogState extends State<BlockStateCreateDialog> {
  final _name = TextEditingController();
  BlockSpec? _block;
  bool _busy = false;
  bool _picking = false;

  Map<String, int> get _contexts => contextCountsOf(
    StoreProvider.state<AppState>(context, notify: false).blockStates.items,
  );

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
    // The counts need every context of a block, also those on a page the
    // list hasn't loaded.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.dispatchAndWait(LoadAllBlockStatesAction());
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _complete => _name.text.trim().isNotEmpty && _block != null;

  void _pick(BlockSpec block) => setState(() {
    _block = block;
    _picking = false;
  });

  void _back() => setState(() => _picking = false);

  Future<void> _create() async {
    final block = _block;
    if (!_complete || block == null || _busy) return;
    setState(() => _busy = true);
    final (:ok, :error) = await context.dispatchAndCatch(
      BlockStateAddAction(
        BlockStateModel(
          uiName: _name.text.trim(),
          key: block.key,
          rules: const [BlockStateRule()],
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (error != null) {
      context.showErrorSnackBar(error);
      return;
    }
    if (ok) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_picking) {
      return FormDialog(
        title: l10n.blockstate_picker_title,
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const Icon(Icons.arrow_back),
          onPressed: _back,
        ),
        onCancel: _back,
        actionLabel: l10n.button_add,
        onSubmit: null,
        showActions: false,
        maxWidth: blockPickerWidth,
        // Fixed, so the dialog keeps its size while the user types.
        content: SizedBox(
          height: blockPickerHeight,
          child: BlockPicker(
            contexts: _contexts,
            current: _block?.key,
            onBlock: _pick,
          ),
        ),
      );
    }
    final theme = Theme.of(context);
    final block = _block;
    final contexts = block == null ? 0 : _contexts[block.key] ?? 0;
    return FormDialog(
      title: l10n.blockstate_create_title,
      actionLabel: l10n.button_add,
      busy: _busy,
      onSubmit: _complete ? _create : null,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            decoration: InputDecoration(
              labelText: '${l10n.blockstate_create_name} *',
              prefixIcon: const Icon(Icons.title),
            ),
            onSubmitted: (_) => _create(),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => setState(() => _picking = true),
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
    );
  }
}
