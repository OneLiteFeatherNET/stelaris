import 'package:flutter/material.dart';

class StepPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StepPageState();
  }
}

class StepPageState extends State<StepPage> {
  int _current_step = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Step Page"),
      ),
      body: Stepper(
        steps: createSteps(),
        currentStep: _current_step,
        onStepTapped: (step) => setState(() => _current_step = step),
        onStepContinue: () {
          setState(() {
            if (_current_step < createSteps().length - 1) {
              _current_step++;
            } else {
              print("Complete");
              Navigator.pop(context);
            }
          });
        },
        onStepCancel: () {
          setState((){
            if (_current_step > 0) {
              _current_step--;
            } else {
              Navigator.pop(context);
            }
          });
        },
      ),
    );
  }

  List<Step> createSteps() {
    List<Step> _steps = [
      Step(
        title: Text("name"),
        content: TextField(),
        isActive: _current_step >= 0,

      ),
      Step(
        title: Text("Hp"),
        content: TextField(),
        isActive: _current_step >= 1,
      ),
      Step(
        title: Text("IDK"),
        content: TextField(),
        isActive: _current_step >= 2,
      )
    ];
    return _steps;
  }
}
