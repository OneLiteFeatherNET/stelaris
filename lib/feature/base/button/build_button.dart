import 'package:flutter/material.dart';
import 'package:stelaris/feature/build/build_dialog.dart';

class BuildButton extends StatelessWidget {
  const BuildButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return const BuildDialog();
              },
            );
          },
          icon: const Icon(Icons.build_outlined),
        );
      },
    );
  }
}
