import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/base_card.dart';
import 'package:stelaris/util/constants.dart';

/// A card widget that contains a [Switch] to toggle a boolean value.
class SwitchCard extends StatelessWidget {
  const SwitchCard({
    required this.display,
    required this.currentValue,
    required this.valueUpdate,
    this.tooltipMessage = emptyString,
    this.focusOrder,
    super.key,
  });

  final String display;
  final bool currentValue;
  final void Function(bool value) valueUpdate;
  final String tooltipMessage;
  final FocusOrder? focusOrder;

  @override
  Widget build(BuildContext context) {
    final toggle = Switch(value: currentValue, onChanged: valueUpdate);
    return BaseCard(
      display: display,
      widget: Center(
        child: focusOrder == null
            ? toggle
            : FocusTraversalOrder(order: focusOrder!, child: toggle),
      ),
      message: tooltipMessage,
    );
  }
}
