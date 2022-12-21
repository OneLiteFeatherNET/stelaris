import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/data_model.dart';
import 'package:stelaris_ui/util/constants.dart';

typedef FinishStepper<E extends DataModel> = void Function(E model);
typedef BuildModel<E extends DataModel> = E Function(String name, String description);

class SetupStepper<E extends DataModel> extends StatefulWidget {

  final FinishStepper<E> finishCallback;
  final BuildModel<E> buildModel;

  const SetupStepper({Key? key, required this.finishCallback, required this.buildModel}) : super(key: key);

  @override
  State<SetupStepper<E>> createState() => _SetupStepperState<E>();
}

class _SetupStepperState<E extends DataModel> extends State<SetupStepper<E>> {
  int _currentStep = 0;

  GlobalKey<_SetupStepperState<E>> itemStepperKey = GlobalKey<_SetupStepperState<E>>();

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  GlobalKey<FormState> key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final steps = getSteps();
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          child: const Text("Create new model"),
        ),
        Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            steps: steps,
            controlsBuilder: (BuildContext context, ControlsDetails details) {
              return Row(
                children: [
                  details.stepIndex == (steps.length - 1)
                      ? TextButton(
                          onPressed: details.onStepContinue,
                          child: const Text('Finish'),
                        )
                      : TextButton(
                          onPressed: details.onStepContinue,
                          child: const Text('Continue'),
                        ),
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  )
                ],
              );
            },
            onStepContinue: () {
              _continue();
            },
            onStepCancel: () {
              _currentStep > 0 ? setState(() => _currentStep -= 1) : "";
            })
      ],
    );
  }

  _continue() async {
    bool isLastStep = _currentStep == getSteps().length - 1;

    if (isLastStep) {
      widget.finishCallback(widget.buildModel(nameController.text, descriptionController.text));
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
                SizedBox(
                  width: 650,
                  child: TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name')),
                ),
              ],
            )),
        Step(
            isActive: _currentStep == 1,
            title: const Text("Description"),
            content: Column(
              children: [
                spaceTenAndTenBox,
                SizedBox(
                  width: 650,
                  child: TextFormField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description')),
                ),
              ],
            )),
      ];
}
