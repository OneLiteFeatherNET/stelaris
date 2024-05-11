import 'package:flutter/material.dart';

/// The [EmptyDataWidget] is a widget that displays a message if the model has no data.
/// It is only used when the selected model has no data
class EmptyDataWidget extends StatelessWidget {
  const EmptyDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No data available. Use the add button to add new data!'),
    );
  }
}
