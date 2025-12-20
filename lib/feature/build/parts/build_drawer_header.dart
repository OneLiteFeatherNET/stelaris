import 'package:flutter/material.dart';
import 'package:stelaris/util/constants.dart';

class BuildDrawerHeader extends StatelessWidget {
  const BuildDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: sizeFifty,
      child: ListTile(
        title: Text(
          'Vulpes Build',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
