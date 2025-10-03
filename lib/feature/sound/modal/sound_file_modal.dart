import 'package:flutter/material.dart';
import 'package:stelaris/feature/base/button/cancel_button.dart';
import 'package:stelaris/feature/sound/modal/section/base_section.dart';
import 'package:stelaris/feature/sound/modal/type/integer_fields_section.dart';
import 'package:stelaris/feature/sound/modal/type/sound_switch_section.dart';
import 'package:stelaris/feature/sound/modal/type/volume_section.dart';

import 'section/string_field_section.dart';

class SoundFileModal extends StatefulWidget {
  final void Function({
    required String name,
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
  String _name = '';
  double _volume = 1;
  double _pitch = 1;
  int _weight = 1;
  bool _stream = true;
  int _attenuationDistance = 16;
  bool _preload = false;
  String _type = 'file';

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isDense = media.size.height < 500;
    final smallGap = isDense ? 12.0 : 16.0;
    final largeGap = isDense ? 20.0 : 32.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 400,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                  const StringInputSection(),
                  const SizedBox(height: 16),
                  VolumeSection(
                    initialPitch: _pitch,
                    initialVolume: _volume,
                    onPitchFinalized: (v) => setState(() => _pitch = v),
                    onVolumeFinalized: (v) => setState(() => _volume = v),
                  ),
                  SizedBox(height: smallGap),
                  IntegerFieldsSection(
                    weight: _weight,
                    attenuation: _attenuationDistance,
                    onWeightChanged: (v) => setState(() => _weight = v),
                    onAttenuationChanged: (v) =>
                        setState(() => _attenuationDistance = v),
                    dense: isDense,
                  ),
                  SizedBox(height: smallGap),
                  // Combined Section: Switches + Type dropdown
                  BaseSection(
                    title: 'Options',
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final horizontal = constraints.maxWidth >= 420;
                            return SwitchesSection(
                              streamValue: _stream,
                              onStreamChanged: (v) => setState(() => _stream = v),
                              preloadValue: _preload,
                              onPreloadChanged: (v) => setState(() => _preload = v),
                              wrapInBaseSection: false,
                              vertical: !horizontal,
                            );
                          },
                        ),
                        SizedBox(height: smallGap),
                        const Divider(height: 1),
                        SizedBox(height: smallGap),
                        DropdownButtonFormField<String>(
                          initialValue: _type,
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
                      ],
                    ),
                  ),
                  SizedBox(height: largeGap),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CancelButton(callback: () => Navigator.pop(context)),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            widget.onSave?.call(
                              name: _name,
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
      ),
    );
  }
}
