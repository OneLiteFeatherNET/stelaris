import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/builder/notification_builder.dart';
import 'package:stelaris_ui/api/model/notification_model.dart';
import 'package:stelaris_ui/api/util/minecraft/frame_type.dart';

import '../../../api/api_service.dart';
import '../../../util/constants.dart';

const List<FrameType> values = FrameType.values;
List<DropdownMenuItem<String>> items =
List.generate(values.length, (index) =>
    DropdownMenuItem(
        alignment: Alignment.center,
        value: values[index].value,
        child: Text(values[index].value))
);

typedef FinishStepper = void Function(NotificationModel model);

class NotificationStepper extends StatefulWidget {

  final FinishStepper finishStepper;

  const NotificationStepper({Key? key, required this.finishStepper}) : super(key: key);

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

  _continue() async {
    bool isLastStep = _currentStep == getSteps().length - 1;

    if (isLastStep) {
      NotificationModel notification = _notificationBuilder.toDTO();
      final model = await ApiService().notificationAPI.addNotification(notification);
      widget.finishStepper(model);
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
            child: DropdownButton(
                value: _defaultType,
                items: getItems(),
                onChanged: (String? value) {
                  setState(() {
                    _defaultType = value!;
                    _notificationBuilder.setFrameType(value);
                  });
                },
              isExpanded: true,
            ),
          )
        ],
      )
    ),
  ];
}

List<DropdownMenuItem<String>> getItems() => List.generate(values.length, (index) =>
    DropdownMenuItem(
        alignment: Alignment.center,
        value: values[index].value,
        child: Text(values[index].value))
);