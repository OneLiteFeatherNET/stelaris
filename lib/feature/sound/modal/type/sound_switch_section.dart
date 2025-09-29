import 'package:flutter/material.dart';
import 'package:stelaris/feature/sound/modal/section/base_section.dart';

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
    return BaseSection(
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
