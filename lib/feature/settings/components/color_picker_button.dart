import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerButton extends StatefulWidget {
  const ColorPickerButton({
    required this.color,
    required this.onColorChanged,
    required this.label,
    super.key,
  });

  final Color color;
  final ValueChanged<Color> onColorChanged;
  final String label;

  @override
  State<ColorPickerButton> createState() => _ColorPickerButtonState();
}

class _ColorPickerButtonState extends State<ColorPickerButton> {
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.color;
  }

  @override
  void didUpdateWidget(ColorPickerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      _currentColor = widget.color;
    }
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Pick a ${widget.label}'),
              content: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: _currentColor,
                  onColorChanged: (color) {
                    setState(() => _currentColor = color);
                    widget.onColorChanged(color);
                  },
                  pickerAreaHeightPercent: 0.8,
                  enableAlpha: true,
                  displayThumbColor: true,
                  portraitOnly: true,
                  colorPickerWidth: 300,
                  pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(8)),
                  labelTypes: const [],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Done'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Change ${widget.label} color',
      child: InkWell(
        onTap: () => _showColorPicker(context),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _currentColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
            ),
          ),
        ),
      ),
    );
  }
}
