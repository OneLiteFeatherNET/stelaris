import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/builder/font_builder.dart';
import 'package:stelaris_ui/api/util/minecraft/font_type.dart';

import '../../../util/constants.dart';

const List<FontType> values = FontType.values;

List<DropdownMenuItem<String>> items =
List.generate(values.length, (index) =>
    DropdownMenuItem(
        alignment: Alignment.center,
        value: values[index].displayName,
        child: Text(values[index].displayName))
);

class FontStepper extends StatefulWidget {
  const FontStepper({Key? key}) : super(key: key);

  @override
  State<FontStepper> createState() => _FontStepperState();
}

class _FontStepperState extends State<FontStepper> {
  int _currentStep = 0;

  final FontBuilder _fontBuilder = FontBuilder();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const SizedBox(
        width: 100,
        height: 20,
        child: Text(fontStepperTitle, textAlign: TextAlign.center),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      actions: <Widget>[
        SizedBox(
          width: 600,
          height: 250,
          child: Stepper(
            type: StepperType.horizontal,
            currentStep: _currentStep,
            steps: getSteps(),
          ),
        )
      ],
    );
  }

  List<Step> getSteps() => [
        Step(
            isActive: _currentStep == 0,
            title: const Text("Name"),
            content: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                )
              ],
            )),
        Step(
            isActive: _currentStep == 1,
            title: const Text("data"),
            content: Column(
              children: [

              ],
            )
        )
      ];
}
