import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/api/model/data_model.dart';
import 'package:stelaris_ui/feature/base/button/setup_stepper_button.dart';
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

  GlobalKey<_SetupStepperState<E>> itemStepperKey = GlobalKey<
      _SetupStepperState<E>>();

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  GlobalKey<FormState> key = GlobalKey<FormState>();

  FocusNode focusNode = FocusNode();

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
              style: const TextStyle(fontSize: 25),
              textAlign: TextAlign.center),
        ),
        Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            steps: steps,
            controlsBuilder: (BuildContext context, ControlsDetails details) {
              return StepperDialogButton(details: details);
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

    if (!isLastStep) {
      setState(() => _currentStep += 1);
    }

    if (isLastStep && nameController.text.isEmpty) {
      setState(() {
        _currentStep -= 1;
        focusNode.requestFocus();
      });
      _currentStep = 0;
    }

    if (isLastStep && nameController.text.trim().isNotEmpty) {
      widget.finishCallback(
          widget.buildModel(nameController.text, descriptionController.text));
      return null;
    }
  }

  List<Step> getSteps() =>
      [
        Step(
          isActive: _currentStep == 0,
          title: Text(context.l10n.card_name),
          content: Column(
            children: [
              SizedBox(
                width: 650,
                child: TextFormField(
                  focusNode: focusNode,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: nameController,
                  decoration: InputDecoration(labelText: context.l10n.card_name),
                  maxLength: 30,
                  inputFormatters: [FilteringTextInputFormatter.allow(namePattern)],
                  validator: (value) {
                    if (value != null && !namePattern.hasMatch(value)) {
                      return context.l10n.setup_invalid_name;
                    }
                    return null;
                  },
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
                  decoration: InputDecoration(labelText: context.l10n.card_description),
                ),
              ),
              fifteenBox
            ],
          ),
        ),
      ];
}
