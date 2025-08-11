import 'package:flutter/material.dart';

class SwitchesSection extends StatelessWidget {
  final bool streamValue;
  final ValueChanged<bool> onStreamChanged;
  final bool preloadValue;
  final ValueChanged<bool> onPreloadChanged;
  final Color? backgroundColor; // Optional: if you want to customize it

  const SwitchesSection({
    required this.streamValue,
    required this.onStreamChanged,
    required this.preloadValue,
    required this.onPreloadChanged,
    this.backgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor =
        backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest;

    return Container(
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSwitchRow(
            context: context,
            label: 'Stream',
            value: streamValue,
            onChanged: onStreamChanged,
          ),
          const SizedBox(height: 8), // Add some space between switches if desired
          _buildSwitchRow(
            context: context,
            label: 'Preload',
            value: preloadValue,
            onChanged: onPreloadChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required BuildContext context,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
