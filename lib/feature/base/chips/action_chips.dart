import 'package:flutter/material.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// A widget that displays action chips for adding and saving actions.
///
/// The `ActionChips` widget consists of two buttons: one for adding an item
/// and another for saving. It accepts two callback functions that are triggered
/// when the respective buttons are pressed. Additionally, it allows customization
/// of the spacing between the buttons.
///
/// This widget is intended to be used in scenarios where users need to perform
/// actions related to adding and saving items in the application.
class ActionChips extends StatelessWidget {
  const ActionChips({
    required this.addCallback,
    required this.saveCallback,
    this.spacing = 50.0,
    super.key,
  });

  final VoidCallback addCallback;
  final VoidCallback saveCallback;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool spaceIsToLow = constraints.maxWidth < 230;
      return Flex(
        direction: spaceIsToLow ? Axis.vertical : Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: ActionChip(
              avatar: const Icon(Icons.add),
              label: Text(context.l10n.button_add),
              onPressed: addCallback,
            ),
          ),
          SizedBox(
            width: spaceIsToLow ? 0 : spacing,
            height: spaceIsToLow ? spacing : 0,
          ),
          Align(
            alignment: Alignment.center,
            child: FilledButton.icon(
              icon: const Icon(Icons.check),
              label: Text(context.l10n.button_save),
              onPressed: saveCallback,
            ),
          ),
        ],
      );
    });
  }
}
