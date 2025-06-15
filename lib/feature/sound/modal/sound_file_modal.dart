import 'package:flutter/material.dart';

class SoundFileModal extends StatefulWidget {
  final void Function({
    required double volume,
    required double pitch,
    required int weight,
    required bool stream,
    required int attenuationDistance,
    required bool preload,
    required String type,
  })?
  onSave;

  final bool create;

  const SoundFileModal({required this.create, required this.onSave, super.key});

  @override
  State<SoundFileModal> createState() => _SoundFileModalState();
}

class _SoundFileModalState extends State<SoundFileModal> {
  double _volume = 1.0;
  double _pitch = 1.0;
  int _weight = 1;
  bool _stream = true;
  int _attenuationDistance = 16;
  bool _preload = false;
  String _type = 'file';

  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController(text: '1');
  final _attenuationController = TextEditingController(text: '16');

  @override
  void dispose() {
    _weightController.dispose();
    _attenuationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surfaceVariant = Theme.of(context).colorScheme.surfaceVariant;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.create ? 'Create Sound' : 'Edit Sound',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                // Section 1: Volume & Pitch
                Container(
                  decoration: BoxDecoration(
                    color: surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _sliderRow(
                        'Volume',
                        _volume,
                        (v) => setState(() => _volume = v),
                        min: 0,
                        max: 2,
                        divisions: 100,
                      ),
                      const SizedBox(height: 12),
                      _sliderRow(
                        'Pitch',
                        _pitch,
                        (v) => setState(() => _pitch = v),
                        min: 0,
                        max: 2,
                        divisions: 100,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Section 2: Integer fields
                Container(
                  decoration: BoxDecoration(
                    color: surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Weight',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter a weight';
                          final val = int.tryParse(v);
                          if (val == null) return 'Enter a valid integer';
                          return null;
                        },
                        onChanged: (v) =>
                            setState(() => _weight = int.tryParse(v) ?? 1),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _attenuationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Attenuation Distance',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter a distance';
                          final val = int.tryParse(v);
                          if (val == null) return 'Enter a valid integer';
                          return null;
                        },
                        onChanged: (v) => setState(
                          () => _attenuationDistance = int.tryParse(v) ?? 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Section 3: Switches
                Container(
                  decoration: BoxDecoration(
                    color: surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Stream',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          Switch(
                            value: _stream,
                            onChanged: (v) => setState(() => _stream = v),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Preload',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          Switch(
                            value: _preload,
                            onChanged: (v) => setState(() => _preload = v),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Section 4: Type dropdown
                Container(
                  decoration: BoxDecoration(
                    color: surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    value: _type,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'file', child: Text('File')),
                      DropdownMenuItem(value: 'event', child: Text('Event')),
                    ],
                    onChanged: (v) => setState(() => _type = v ?? 'file'),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          widget.onSave?.call(
                            volume: _volume,
                            pitch: _pitch,
                            weight: _weight,
                            stream: _stream,
                            attenuationDistance: _attenuationDistance,
                            preload: _preload,
                            type: _type,
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sliderRow(
    String label,
    double value,
    ValueChanged<double> onChanged, {
    double min = 0,
    double max = 1,
    int? divisions,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: value.toStringAsFixed(2),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
