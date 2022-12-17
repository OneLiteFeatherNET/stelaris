import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/data_model.dart';

ShapeBorder rectangleBorder = RoundedRectangleBorder(borderRadius: BorderRadius.circular(15));

class BaseStepper<E extends DataModel> extends StatefulWidget {

  final List<Step> steps;
  final Text title;

  const BaseStepper({Key? key, required this.title, required this.steps}) : super(key: key);

  @override
  State<BaseStepper> createState() => _BaseStepperState<E>();
}

class _BaseStepperState<E extends DataModel> extends State<BaseStepper> {

  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title,
      shape: rectangleBorder,
      actions: <Widget>[
        SizedBox(
            width: 600,
            height: 250,
            child: Stepper(
              type: StepperType.horizontal,
              currentStep: currentStep,
              steps: widget.steps,
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
