import 'package:flutter/material.dart';
import 'package:stelaris/feature/item/lore/lore_count_chip.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The [LoreActionChips] is a widget that displays mostly three different action chips.
/// Each action chip has a different function which is passed as a parameter.
/// There is one scenario where the confirm widget isn't a action chip.
/// In this special case the confirm widget is a [FilledButton.icon].
/// For more details visit the [LorePage] class.
class LoreActionChips extends StatelessWidget {

  const LoreActionChips({
    required this.dialogFunction,
    required this.currentIndex,
    super.key,
  });

  final VoidCallback dialogFunction;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ActionChip(
              avatar: const Icon(Icons.add),
              label: Text(context.l10n.button_add),
              onPressed: () => dialogFunction.call(),
            ),
            LoreCountChip(
              currentIndex: currentIndex,
            ),
          ],
        ),
      ),
    );
  }
}
