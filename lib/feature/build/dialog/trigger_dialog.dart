import 'package:flutter/material.dart';

class TriggerDialog extends StatelessWidget {
  const TriggerDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Trigger new build", textAlign: TextAlign.center,),
      contentPadding: const EdgeInsets.all(20.0),
      children: [
        TextButton(
            onPressed: () {},
            child: const Text("Go!")
        )
      ],
    );
  }
}
