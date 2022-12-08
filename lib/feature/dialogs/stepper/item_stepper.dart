import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/builder/item_builder.dart';

class ItemStepper extends StatefulWidget {
  const ItemStepper({Key? key}) : super(key: key);

  @override
  State<ItemStepper> createState() => _ItemStepperState();
}

class _ItemStepperState extends State<ItemStepper> {
  int _currentStep = 0;

  final ItemBuilder _itemBuilder = ItemBuilder();

  GlobalKey<FormState> key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        backgroundColor: Colors.lightGreen[200],
        title: const SizedBox(
          width: 100,
          height: 20,
          child: Text(
            "Create new item model",
            textAlign: TextAlign.center,
          ),
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
                  onStepContinue: () {
                    setState(() => _currentStep += 1);
                  },
                  onStepCancel: () {
                    _currentStep > 0 ? setState(() => _currentStep -= 1) : "";
                  })),
        ]);
  }

  List<Step> getSteps() => [
        Step(
            isActive: _currentStep == 1,
            title: const Text("Adjust some general values"),
            content: Form(
              key: key,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Material'),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Amount'),
                  ),
                  TextFormField(
                      decoration: const InputDecoration(labelText: 'Modeldata'))
                ],
              ),
            ),
            state: _currentStep >= 2 ? StepState.complete : StepState.disabled)
      ];
}
