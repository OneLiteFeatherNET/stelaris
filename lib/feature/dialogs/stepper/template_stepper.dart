import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/builder/template_builder.dart';

import '../../../util/constants.dart';

class TemplateStepper extends StatefulWidget {
  const TemplateStepper({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TemplateStepper();
  }
}

class _TemplateStepper extends State<TemplateStepper> {
  int _currentStep = 0;

  bool switched = false;

  TemplateBuilder _templateBuilder = new TemplateBuilder();
  TextEditingController editingController = TextEditingController();

  @override
  void dispose() {
    editingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        backgroundColor: Colors.lightGreen[200],
        title: const Text(templateStepperTitle),
        actions: <Widget>[
          SizedBox(
              width: 600,
              height: 250,
              child: Stepper(
                  type: StepperType.horizontal,
                  currentStep: _currentStep,
                  steps: getSteps(),
                  onStepContinue: () {
                    setState(() => _currentStep += 1);
                  },
                  onStepCancel: () {
                    setState(() => _currentStep -= 1);
                  })),
        ]);
  }

  List<Step> getSteps() => [
        Step(
          isActive: _currentStep == 0,
          title: const Text("Set a name"),
          content: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Enter a name'),
              )
            ],
          ),
        ),
        Step(
          isActive: _currentStep == 1,
          title: const Text("Add plugins"),
          content: Container(
            height: 100,
            child: ListView(
              children: [
                Card(
                    child: ListTile(
                  trailing: Switch(
                    value: switched,
                    onChanged: (value) => {
                      setState(() {
                        switched = !switched;
                      })
                    },
                    activeColor: Colors.amber,
                  ),
                  title: const Text("YOLO"),
                )),
              ],
            ),
          ),
        ),
        Step(
            isActive: _currentStep == 2,
            title: const Text("Finish template"),
            content: Column(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Enter a name'),
                  controller: editingController,
                )
              ],
            ))
      ];
}
