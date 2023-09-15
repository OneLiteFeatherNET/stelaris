import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/data_model.dart';
import 'package:stelaris_ui/util/constants.dart';

import 'stepper/setup_stepper.dart';

class SetUpDialog<T extends DataModel> extends StatelessWidget {
  const SetUpDialog({
    super.key,
    required this.buildModel,
    required this.finishCallback,
  });

  final T Function(String, String) buildModel;
  final Function(T) finishCallback;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Card(
          elevation: cardElevation,
          child: SetupStepper<T>(
            buildModel: buildModel,
            finishCallback: finishCallback,
          ),
        ),
      ),
    );
  }
}
