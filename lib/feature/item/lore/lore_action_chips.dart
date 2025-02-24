import 'package:flutter/material.dart';
import 'package:stelaris/feature/item/lore/lore_count_chip.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The [LoreActionChips] is a widget that displays mostly three different action chips.
/// Each action chip has a different function which is passed as a parameter.
/// There is one scenario where the confirm widget isn't a action chip.
/// In this special case the confirm widget is a [FilledButton.icon].
/// For more details visit the [LorePage] class.
class LoreActionChips extends StatelessWidget {
  final VoidCallback dialogFunction;
  final Widget confirmWidget;
  final VoidCallback deleteFunction;
  final int currentIndex;

  const LoreActionChips({
    required this.dialogFunction,
    required this.confirmWidget,
    required this.deleteFunction,
    required this.currentIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ActionChip(
          avatar: const Icon(Icons.add),
          label: Text(context.l10n.button_add),
          onPressed: () => dialogFunction.call(),
        ),
        ActionChip(
          avatar: const Icon(Icons.delete),
          label: const Text('Delete'),
          onPressed: () => deleteFunction.call(),
        ),
        confirmWidget,
        LoreCountChip(
          currentIndex: currentIndex,
        ),
      ],
    );
  }
}
