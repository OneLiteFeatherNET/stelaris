import 'package:flutter/material.dart';

class BuildButton extends StatelessWidget {
  const BuildButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return IconButton(
          onPressed: () => Scaffold.of(context).openEndDrawer(),
          icon: const Icon(Icons.build_outlined),
        );
      },
    );
  }
}
