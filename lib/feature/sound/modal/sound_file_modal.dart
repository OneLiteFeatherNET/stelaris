import 'package:flutter/material.dart';
import 'package:stelaris/api/model/sound/sound_file_source.dart';
import 'package:stelaris/feature/base/button/cancel_button.dart';
import 'package:stelaris/feature/sound/modal/section/base_section.dart';
import 'package:stelaris/feature/sound/modal/type/integer_fields_section.dart';
import 'package:stelaris/feature/sound/modal/type/sound_switch_section.dart';
import 'package:stelaris/feature/sound/modal/type/volume_section.dart';

import 'section/string_field_section.dart';

class SoundFileModal extends StatefulWidget {

  const SoundFileModal({
    required this.create,
    required this.onSave,
    this.initialData,
    super.key,
  });

  final void Function(SoundFileSource soundFile)? onSave;
  final bool create;
  final SoundFileSource? initialData;

  @override
  State<SoundFileModal> createState() => _SoundFileModalState();
}


class _SoundFileModalState extends State<SoundFileModal> {
  late String _name;
  late double _volume;
  late double _pitch;
  late int _weight;
  late bool _stream;
  late int _attenuationDistance;
  late bool _preload;
  late String _type;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    debugPrint('Read data from');
    if (widget.initialData != null) {
      debugPrint('Exsts');
      debugPrint(widget.initialData!.toString());
    }
    final data = widget.initialData;
    _name = data?.name ?? '';
    _volume = data?.volume ?? 1;
    _pitch = data?.pitch ?? 1;
    _weight = data?.weight ?? 1;
    _stream = true;
    _attenuationDistance = data?.attenuationDistance ?? 16;
    _preload = data?.preload ?? false;
    _type = data?.type ?? 'file';
  }

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
                  StringInputSection(
                    initialValue: _name,
                    onUpdate: (value) => _name = value,
                  ),
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
                      const CancelButton(),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            widget.onSave?.call(
                              SoundFileSource(
                                id: widget.initialData?.id,
                                name: _name,
                                volume: _volume,
                                pitch: _pitch,
                                weight: _weight,
                                attenuationDistance: _attenuationDistance,
                                preload: _preload,
                                type: _type,
                              ),
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
