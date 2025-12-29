import 'package:flutter/material.dart';

class StelarisLoader extends StatelessWidget {
  const StelarisLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 25,
        width: 25,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
