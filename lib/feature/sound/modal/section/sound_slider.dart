import 'package:flutter/material.dart';

/// A widget that combines a descriptive [Text] label with a [Slider].
///
/// `LabeledSlider` simplifies creating rows where a slider controls a value,
/// and that value is clearly labeled. It's designed for contexts like settings
/// screens or forms where users adjust parameters like volume, brightness, etc.
///
/// The widget handles the common layout of placing the label to the left
/// and the slider to the right, expanding to fill available horizontal space.
///
class SoundSliderRow extends StatelessWidget {
  const SoundSliderRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.labelWidth = 100.0, // Default label width
    this.labelStyle,
    this.valueDecimalPlaces = 2,
    super.key, // For the Slider's own label
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>?
  onChangeEnd; // Optional: if you need to act on slider release
  final double min;
  final double max;
  final int? divisions;
  final double labelWidth;
  final TextStyle? labelStyle;
  final int valueDecimalPlaces;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: labelWidth,
          child: Text(
            label,
            style: labelStyle ?? Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: value.toStringAsFixed(valueDecimalPlaces),
            onChanged: onChanged,
            onChangeEnd: onChangeEnd, // Pass it through
          ),
        ),
      ],
    );
  }
}
