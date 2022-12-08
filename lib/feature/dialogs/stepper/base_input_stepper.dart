import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/data_model.dart';

ShapeBorder rectangleBorder = RoundedRectangleBorder(borderRadius: BorderRadius.circular(15));

class BaseStepper<E extends DataModel> extends StatefulWidget {

  final List<Step> steps;
  final Text title;

  const BaseStepper({Key? key, required this.title, required this.steps}) : super(key: key);

  @override
  State<BaseStepper> createState() => _BaseStepperState<E>(title, steps);
}

class _BaseStepperState<E extends DataModel> extends State<BaseStepper> {

  int currentStep = 0;
  final List<Step> steps;
  final Text title;

  _BaseStepperState(this.title, this.steps);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      shape: rectangleBorder,
      actions: <Widget>[
        SizedBox(
            width: 600,
            height: 250,
            child: Stepper(
              type: StepperType.horizontal,
              currentStep: currentStep,
              steps: steps,
              onStepContinue: () {
                //TODO Check if currentStep is over the global step amount
                setState(() => currentStep += 1);
              },
              onStepCancel: () {
                setState(() => decreaseCount());
              },
            ),
        )
      ],
    );
  }

  void decreaseCount() {
    if (currentStep == 0) return;
    currentStep -= 1;
  }
}
