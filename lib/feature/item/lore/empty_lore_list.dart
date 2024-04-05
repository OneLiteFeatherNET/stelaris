import 'package:flutter/material.dart';

/// The [EmptyLoreList] is a widget that displays a message if the lore list is empty.
/// It is only used when the selected model has no lore lines set.
class EmptyLoreList extends StatelessWidget {
  const EmptyLoreList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Nothing to display. Use the add button to add a new lore.'),
    );
  }
}
