import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/input/registry_autocomplete.dart';
import 'package:stelaris/feature/sound/modal/section/base_integer_section_field.dart';
import 'package:stelaris/feature/sound/modal/section/sound_slider.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/validators.dart';
import 'package:stelaris/feature/base/input/length_counter.dart';

/// The client clamps the pitch to this range when it plays a sound.
const double minPitch = 0.5;
const double maxPitch = 2;

/// Builds the content that lets the user choose or upload a sound asset,
/// shown in place of the modal's own; [selectedKey] is the key of the linked
/// one. [onPicked] gets the chosen sound, [onBack] returns without one.
typedef SoundAssetPicker = Widget Function(
  BuildContext context,
  String? selectedKey,
  ValueChanged<AssetModel> onPicked,
  VoidCallback onBack,
);

class SoundFileModal extends StatefulWidget {
  const SoundFileModal({
    required this.create,
    required this.onSave,
    this.initialData,
    this.pickSound,
    super.key,
  });

  final void Function(SoundFileSource soundFile)? onSave;
  final bool create;
  final SoundFileSource? initialData;

  /// Chooses the uploaded sound a file plays. Without it a file can only be
  /// named, not linked.
  final SoundAssetPicker? pickSound;

  @override
  State<SoundFileModal> createState() => _SoundFileModalState();
}

class _SoundFileModalState extends State<SoundFileModal> {
  late final TextEditingController _nameController;
  final FocusNode _nameFocus = FocusNode();
  late double _volume;
  late double _pitch;
  late int _weight;
  late int _attenuationDistance;
  late bool _preload;
  late String _type;

  /// The sound asset the file plays and its key, which the name equals while
  /// it is linked.
  String? _assetId;
  String? _assetKey;

  /// Whether the sound picker is shown in place of the form.
  bool _picking = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _nameController = TextEditingController(text: data?.name ?? '');
    _volume = data?.volume ?? 1;
    _pitch = (data?.pitch ?? 1).clamp(minPitch, maxPitch);
    _weight = data?.weight ?? 1;
    _attenuationDistance = data?.attenuationDistance ?? 16;
    _preload = data?.preload ?? false;
    _type = data?.type ?? 'file';
    if (data?.assetId case final assetId?) {
      _assetId = assetId;
      _assetKey = data!.name;
    }
    _nameController.addListener(_onNameChanged);
  }

  /// The backend links a file only under the key of its sound, so another
  /// name ends the link.
  void _onNameChanged() {
    if (_assetKey != null && _nameController.text.trim() != _assetKey) {
      setState(_unlink);
    }
  }

  void _unlink() {
    _assetId = null;
    _assetKey = null;
  }

  void _onSoundPicked(AssetModel asset) {
    setState(() {
      _picking = false;
      _assetId = asset.id;
      _assetKey = asset.key;
    });
    _nameController.text = asset.key;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final headingStyle = Theme.of(context).textTheme.titleSmall;

    if (widget.pickSound case final pick? when _picking) {
      return pick(
        context,
        _assetKey,
        _onSoundPicked,
        () => setState(() => _picking = false),
      );
    }

    return FormDialog(
      title: widget.create ? l10n.sound_create : l10n.sound_edit,
      actionIcon: widget.create ? Icons.add : Icons.save_outlined,
      actionLabel: widget.create ? l10n.button_add : l10n.button_save,
      minWidth: 400,
      onSubmit: _handleSave,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _nameField(context),
            if (widget.pickSound != null && _type == 'file') ...[
              const SizedBox(height: 8),
              _soundRow(context),
            ],
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'file', label: Text(l10n.sound_type_file)),
                ButtonSegment(
                  value: 'event',
                  label: Text(l10n.sound_type_event),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (selection) =>
                  setState(() => _type = selection.first),
            ),
            const SizedBox(height: 24),
            Text(l10n.sound_section_volume_pitch, style: headingStyle),
            const SizedBox(height: 8),
            SoundSliderRow(
              label: l10n.sound_volume,
              value: _volume,
              onChanged: (v) => setState(() => _volume = v),
            ),
            SoundSliderRow(
              label: l10n.sound_pitch,
              value: _pitch,
              min: minPitch,
              max: maxPitch,
              divisions: 30,
              onChanged: (v) => setState(() => _pitch = v),
            ),
            const SizedBox(height: 16),
            Text(l10n.sound_section_weight_attenuation, style: headingStyle),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: BaseIntegerField(
                    label: l10n.sound_weight,
                    initialValue: _weight,
                    minValue: 1,
                    onChanged: (v) => _weight = v,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: BaseIntegerField(
                    label: l10n.sound_attenuation_distance,
                    initialValue: _attenuationDistance,
                    minValue: 1,
                    onChanged: (v) => _attenuationDistance = v,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.sound_preload),
              value: _preload,
              onChanged: (v) => setState(() => _preload = v),
            ),
          ],
        ),
      ),
    );
  }

  /// The name of an event is the key of a sound event, so it suggests them;
  /// the name of a file is a path and stays plain text. Both share the
  /// controller, so switching the type keeps what was typed.
  Widget _nameField(BuildContext context) {
    final l10n = context.l10n;
    Widget field({VoidCallback? onSubmitted}) => TextFormField(
      controller: _nameController,
      focusNode: _nameFocus,
      autofocus: widget.create,
      maxLength: maxTextLength,
      buildCounter: nearLimitCounter,
      decoration: InputDecoration(
        labelText: l10n.sound_name,
        hintText: l10n.sound_name_hint,
      ),
      validator: Validators.required(
        l10n.validation_field_required(l10n.sound_name),
      ),
      onFieldSubmitted: onSubmitted == null ? null : (_) => onSubmitted(),
    );
    if (_type != 'event') return field();
    return RegistryAutocomplete(
      registry: 'sound_event',
      controller: _nameController,
      focusNode: _nameFocus,
      // A picked key is already in the controller.
      onSelected: (_) {},
      fieldBuilder: (context, controller, focusNode, onSubmitted) =>
          field(onSubmitted: onSubmitted),
    );
  }

  /// Whether the file plays an uploaded sound, and the button to choose one.
  Widget _soundRow(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          _assetId == null ? Icons.link_off : Icons.audio_file_outlined,
          size: 20,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _assetId == null ? l10n.sound_asset_none : l10n.sound_asset_linked,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (_assetId != null)
          IconButton(
            tooltip: l10n.sound_asset_unlink,
            onPressed: () => setState(_unlink),
            icon: const Icon(Icons.link_off),
          ),
        TextButton.icon(
          onPressed: () => setState(() => _picking = true),
          icon: const Icon(Icons.library_music_outlined),
          label: Text(l10n.sound_asset_choose),
        ),
      ],
    );
  }

  void _handleSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onSave?.call(
      SoundFileSource(
        id: widget.initialData?.id,
        name: _nameController.text.trim(),
        volume: _volume,
        pitch: _pitch,
        weight: _weight,
        attenuationDistance: _attenuationDistance,
        preload: _preload,
        type: _type,
        // An event names another sound event, it plays no file of its own.
        assetId: _type == 'file' ? _assetId : null,
      ),
    );
    Navigator.pop(context);
  }
}
