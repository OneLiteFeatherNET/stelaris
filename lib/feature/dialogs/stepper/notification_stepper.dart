import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/builder/notification_builder.dart';
import 'package:stelaris_ui/api/model/notification_model.dart';
import 'package:stelaris_ui/api/util/minecraft/frame_type.dart';

import '../../../util/constants.dart';

const List<FrameType> values = FrameType.values;
List<DropdownMenuItem<String>> items =
List.generate(values.length, (index) =>
    DropdownMenuItem(
        alignment: Alignment.center,
        value: values[index].value,
        child: Text(values[index].value))
);


class NotificationStepper extends StatefulWidget {

  const NotificationStepper({Key? key}) : super(key: key);

  @override
  State<NotificationStepper> createState() => _NotificationStepperState();

}

class _NotificationStepperState extends State<NotificationStepper> {

  int _currentStep = 0;

  String _defaultType = FrameType.task.value;

  final NotificationBuilder _notificationBuilder = NotificationBuilder();

  GlobalKey<FormState> key = GlobalKey<FormState>();

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.lightGreen[200],
      title: const SizedBox(
        width: 100,
        height: 20,
        child: notificationStepperTitle,
      ),
      shape: stepperBorder,
      actions: <Widget>[
        SizedBox(
          width: 800,
          height: 400,
          child: Stepper(
            type: StepperType.horizontal,
            currentStep: _currentStep,
            steps: getSteps(),
            onStepContinue: () {
              _continue();
            },
          )
        )
      ],
    );
  }

  _continue() {
    bool isLastStep = _currentStep == getSteps().length - 1;

    if (isLastStep) {
      key.currentState!.save();
      NotificationModel notificationModel = _notificationBuilder.toDTO();

      print(notificationModel.toString());
      return null;
    } else {
      setState(() => _currentStep += 1);
    }
  }

  List<Step> getSteps() => [
    Step(
      title: const Text("Set the name"),
      isActive: _currentStep == 0,
      content: TextFormField(
        maxLength: 30,
        autofocus: false,
        autocorrect: false,
        decoration: const InputDecoration(labelText: "Name"),
        onChanged: (String? value) {
          _notificationBuilder.setName(value ?? "null");
        },

      )
    ),
    Step(
      title: const Text("Title and description"),
      isActive: _currentStep == 1,
      content: Form(
        key: key,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: "Title"),
              onSaved: (String? value) {
                _notificationBuilder.setTitle(value ?? "null");
              },
            ),
            SizedBox(height: 50,),
            TextFormField(
              decoration: const InputDecoration(labelText: "Description"),
              onSaved: (String? value) {
                _notificationBuilder.setDescription(value ?? "null");
              },
              )
          ],
        ),
      )

    ),
    Step(
      title: const Text("Material and FrameType"),
      isActive: _currentStep == 2,
      content: Column(
        children: [
          TextFormField(
              decoration: const InputDecoration(labelText: "Material"),
              onChanged: (String? value) {
                _notificationBuilder.setMaterial(value ?? "null");
              },
          ),
          SizedBox(height: 50,),
          SizedBox(
            height: 50,
            width: 200,
            child: Container(
              //TODO: Add own state
              child: DropdownButton(
                  value: _defaultType,
                  items: items,
                  onChanged: (String? value) {
                    setState(() {
                      _defaultType = value!;
                      _notificationBuilder.setFrameType(value);
                    });
                  },
                isExpanded: true,
              ),
            ),
          )
        ],
      )
    ),
  ];
}