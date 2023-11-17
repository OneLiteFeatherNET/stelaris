import 'package:flutter/material.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';

class StepperDialogButton extends StatelessWidget {

  final ControlsDetails details;

  const StepperDialogButton({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    if (details.stepIndex == 0) {
      return Row(
        children: [
          TextButton(
              onPressed: details.onStepContinue,
              child: Text(context.l10n.button_continue)
          )
        ],
      );
    } else {
      return Row(
        children: [
          TextButton(
              onPressed: details.onStepCancel,
              child: Text(context.l10n.button_back)
          ),
          TextButton(
              onPressed: details.onStepContinue,
              child: Text(context.l10n.button_finish)
          )
        ],
      );
    }
  }
}
