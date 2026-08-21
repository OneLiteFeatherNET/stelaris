import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/formatter/min_value_formatter.dart';

class BaseIntegerField extends StatefulWidget {
  final String label;
  final int initialValue;
  final int minValue;
  final ValueChanged<int> onChanged;

  const BaseIntegerField({
    required this.label,
    required this.initialValue,
    required this.minValue,
    required this.onChanged,
    super.key,
  });

  @override
  State<BaseIntegerField> createState() => _BaseIntegerFieldState();
}

class _BaseIntegerFieldState extends State<BaseIntegerField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
      ),
      inputFormatters: [MinValueFormatter(widget.minValue)],
      validator: (v) {
        if (v == null || v.isEmpty) return 'Enter a ${widget.label}';
        final val = int.tryParse(v);
        if (val == null) return 'Enter a valid integer';
        return null;
      },
      onChanged: (v) {
        final parsed = int.tryParse(v);
        if (parsed != null) widget.onChanged(parsed);
      },
    );
  }
}
