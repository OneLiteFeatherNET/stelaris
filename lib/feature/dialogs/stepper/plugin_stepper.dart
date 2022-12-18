import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/builder/plugin_builder.dart';
import 'package:stelaris_ui/api/model/plugin_model.dart';

typedef FinishStepper = void Function(PluginModel model);

class PluginStepper extends StatefulWidget {

  final FinishStepper finishCallback;

  const PluginStepper({Key? key, required this.finishCallback}) : super(key: key);

  @override
  State<PluginStepper> createState() => _PluginStepperState();
}

class _PluginStepperState extends State<PluginStepper> {

  int _currentStep = 0;

  final PluginBuilder _pluginBuilder = PluginBuilder();

  TextEditingController editingController = TextEditingController();

  @override
  void dispose() {
    editingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text("Plugin builder"),
        actions: <Widget>[
          SizedBox(
              width: 600,
              height: 250,
              child: Stepper(
                  physics: const ScrollPhysics(),
                  type: StepperType.horizontal,
                  currentStep: _currentStep,
                  steps: getSteps(),
                  onStepContinue: () {
                    _continue();
                  },
                  onStepCancel: () {
                    editingController.text = "";
                    _onBack();
                  })),
        ]
    );
  }

  _continue() async {
    _handleDataInput();
    bool isLastStep = _currentStep == getSteps().length - 1;

    if (isLastStep) {
      PluginModel pluginModel = _pluginBuilder.toDTO();
      final plugin = await ApiService().pluginAPI.addPlugin(pluginModel);
      widget.finishCallback(plugin);
      return null;
    } else {
      setState(() => _currentStep += 1);
    }
  }

  _onBack() {
    _currentStep == 0 ? null : setState(() => _currentStep -= 1);
  }

  _handleDataInput() {
    switch(_currentStep) {
      case 0:
        _pluginBuilder.setName(editingController.text);
        break;
      case 1:
        _pluginBuilder.setDescription(editingController.text);
        break;
      case 2:
        _pluginBuilder.setVersion(editingController.text);
        break;
      case 3:
        _pluginBuilder.setRef(editingController.text);
        break;
    }
    editingController.text = "";
  }

  List<Step> getSteps() => [
    Step(
        title: const Text("Name"),
        isActive: _currentStep == 0,
        content: TextFormField(
          controller: editingController,
          decoration: const InputDecoration(labelText: "Enter a name"),
        )
    ),
    Step(
        title: const Text("Description"),
        isActive: _currentStep == 1,
        content: TextFormField(
          controller: editingController,
          decoration: const InputDecoration(labelText: "Enter a description"),
        )
    ),
    Step(
        title: const Text("Version"),
        isActive: _currentStep == 2,
        content: TextFormField(
          controller: editingController,
          decoration: const InputDecoration(labelText: "Enter a version"),
        )
    ),
    Step(
        title: const Text("Revision"),
        isActive: _currentStep == 3,
        content: TextFormField(
          controller: editingController,
          decoration: const InputDecoration(labelText: "Enter a revision"),
        ),
        state: _currentStep >= 4 ?
        StepState.complete : StepState.disabled,
    )
  ];
}
