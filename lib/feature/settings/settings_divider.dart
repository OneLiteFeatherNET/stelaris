import 'package:flutter/material.dart';
import 'package:stelaris/util/constants.dart';

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(right: 20),
      child: SizedBox(
        height: fiftyLength,
        width: 2,
        child: VerticalDivider(),
      ),
    );
  }
}
