import 'package:flutter/material.dart';
import 'package:stelaris_ui/util/constants.dart';

class LoreCountChip extends StatelessWidget {
  final int currentIndex;

  const LoreCountChip({required this.currentIndex, super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Current line count',
      child: Chip(
          label: Text('$currentIndex / $maxLoreLines'),
          avatar: const Icon(Icons.numbers_outlined),
      ),
    );
  }
}
