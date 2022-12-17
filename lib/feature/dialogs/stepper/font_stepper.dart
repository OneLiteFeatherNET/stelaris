import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/builder/font_builder.dart';
import 'package:stelaris_ui/api/model/font_model.dart';
import 'package:stelaris_ui/api/util/minecraft/font_type.dart';

import '../../../api/api_service.dart';
import '../../../util/constants.dart';

const List<FontType> values = FontType.values;

List<DropdownMenuItem<String>> items =
List.generate(values.length, (index) =>
    DropdownMenuItem(
        alignment: Alignment.center,
        value: values[index].displayName,
        child: Text(values[index].displayName))
);

typedef FinishStepper = void Function(FontModel model);

class FontStepper extends StatefulWidget {

  final FinishStepper finishStepper;

  const FontStepper({Key? key, required this.finishStepper}) : super(key: key);

  @override
  State<FontStepper> createState() => _FontStepperState();
}

class _FontStepperState extends State<FontStepper> {
  int _currentStep = 0;

  final Map<int, Map<String, TextEditingController>> editingController = {};

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

  _continue() async {
    bool isLastStep = _currentStep == getSteps().length - 1;

    if (isLastStep) {
      FontModel font = _fontBuilder.toDTO();
      final model = await ApiService().fontAPI.addFont(font);
      widget.finishStepper(model);
      return null;
    } else {
      setState(() => _currentStep += 1);
    }
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
