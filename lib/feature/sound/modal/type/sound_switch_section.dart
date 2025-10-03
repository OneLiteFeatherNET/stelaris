import 'package:flutter/material.dart';
import 'package:stelaris/feature/sound/modal/section/base_section.dart';

/// A section that exposes the Stream and Preload switches.
///
/// By default it stacks both controls vertically (each rendered as a single
/// row with label + switch) and wraps the content inside a `BaseSection`.
/// You can disable the wrapper to embed this widget inside another section.
class SwitchesSection extends StatelessWidget {
  final bool streamValue;
  final ValueChanged<bool> onStreamChanged;
  final bool preloadValue;
  final ValueChanged<bool> onPreloadChanged;

  /// When true, the content is wrapped inside a `BaseSection`.
  final bool wrapInBaseSection;

  /// If true, renders the two controls stacked vertically in a Column.
  /// If false, renders them side-by-side in a Row.
  final bool vertical;

  const SwitchesSection({
    required this.streamValue,
    required this.onStreamChanged,
    required this.preloadValue,
    required this.onPreloadChanged,
    this.wrapInBaseSection = true,
    this.vertical = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final content = vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabeledSwitchRow(
                context: context,
                label: 'Stream',
                value: streamValue,
                onChanged: onStreamChanged,
              ),
              const SizedBox(height: 12),
              _buildLabeledSwitchRow(
                context: context,
                label: 'Preload',
                value: preloadValue,
                onChanged: onPreloadChanged,
              ),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: _buildLabeledSwitchRow(
                  context: context,
                  label: 'Stream',
                  value: streamValue,
                  onChanged: onStreamChanged,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildLabeledSwitchRow(
                  context: context,
                  label: 'Preload',
                  value: preloadValue,
                  onChanged: onPreloadChanged,
                ),
              ),
            ],
          );

    if (wrapInBaseSection) {
      return BaseSection(child: content);
    }
    return content;
  }

  /// Renders a single line with a text label on the left and the switch on the
  /// right to use vertical space efficiently.
  Widget _buildLabeledSwitchRow({
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
