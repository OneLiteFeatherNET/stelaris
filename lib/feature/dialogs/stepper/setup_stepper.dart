import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/data_model.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class SetupStepper<E extends DataModel> extends StatefulWidget {
  final FinishStepper<E> finishCallback;
  final BuildModel<E> buildModel;

  const SetupStepper({
    Key? key,
    required this.finishCallback,
    required this.buildModel
  }) : super(key: key);

  @override
  State<SetupStepper<E>> createState() => _SetupStepperState<E>();
}

class _SetupStepperState<E extends DataModel> extends State<SetupStepper<E>> {
  int _currentStep = 0;

  GlobalKey<_SetupStepperState<E>> itemStepperKey =
      GlobalKey<_SetupStepperState<E>>();

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  GlobalKey<FormState> key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final steps = getSteps();
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          child: Text(
              context.l10n.setup_new_model,
              style: const TextStyle(fontSize: 25), textAlign: TextAlign.center),
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
                          child: Text(context.l10n.button_finish)
                        )
                      : TextButton(
                          onPressed: details.onStepContinue,
                          child: Text(context.l10n.button_continue)
                        ),
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: Text(context.l10n.button_back)
                  )
                ],
              );
            },
            onStepContinue: () {
              _continue();
            },
            onStepCancel: () {
              _currentStep > 0 ? setState(() => _currentStep -= 1) : empty;
            })
      ],
    );
  }

  _continue() async {
    bool isLastStep = _currentStep == getSteps().length - 1;

    if (isLastStep) {
      widget.finishCallback(
          widget.buildModel(nameController.text, descriptionController.text));
      return null;
    } else {
      setState(() => _currentStep += 1);
    }
  }

  List<Step> getSteps() => [
        Step(
          isActive: _currentStep == 0,
          title: Text(context.l10n.card_name),
          content: Column(
            children: [
              SizedBox(
                width: 650,
                child: TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
              ),
              fifteenBox
            ],
          ),
        ),
        Step(
          isActive: _currentStep == 1,
          title: Text(context.l10n.card_description),
          content: Column(
            children: [
              spaceTenAndTenBox,
              SizedBox(
                width: 650,
                child: TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ),
              fifteenBox
            ],
          ),
        ),
      ];
}
