import 'dart:convert';
import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/feature/base/edit_card/edit_section_heading.dart';
import 'package:stelaris/feature/component/minimessage_editor.dart';
import 'package:stelaris/feature/project/dialog/pack_icon_field.dart';
import 'package:stelaris/util/component_context.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/minimessage_json.dart';
import 'package:stelaris/util/validators.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The editable state of the resource pack's `pack.mcmeta`, owned by the
/// dialog so it survives switching tabs.
class PackMetaFormController {
  final minFormatMajor = TextEditingController();
  final minFormatMinor = TextEditingController();
  final maxFormatMajor = TextEditingController();
  final maxFormatMinor = TextEditingController();

  /// The PNG of the pack icon, null for none. The dialog stores it as a
  /// texture asset the pack meta refers to.
  Uint8List? icon;

  /// The description as MiniMessage, stored as a vanilla JSON text
  /// component.
  String description = '';

  /// The description as loaded, in both forms: its JSON is kept as it is
  /// while the MiniMessage is unchanged, a round trip could write it
  /// differently.
  String _loadedDescription = '';
  String? _loadedDescriptionJson;

  List<TextEditingController> get _formats => [
    minFormatMajor,
    minFormatMinor,
    maxFormatMajor,
    maxFormatMinor,
  ];

  /// Whether every field is empty, which means the project has no pack meta.
  /// An icon counts as a field: it is stored with the pack meta.
  bool get isEmpty =>
      icon == null &&
      description.trim().isEmpty &&
      _formats.every((field) => field.text.trim().isEmpty);

  /// The description as a JSON text component.
  String get descriptionJson {
    final loaded = _loadedDescriptionJson;
    if (loaded != null && description == _loadedDescription) return loaded;
    return jsonEncode(MiniMessageJson.encode(description.trim()));
  }

  /// Fills the fields with [meta] and its [icon], or clears them when there is
  /// none.
  void fill(PackMeta? meta, {Uint8List? icon}) {
    this.icon = icon;
    _loadedDescriptionJson = meta?.description;
    description = _loadedDescription = meta == null
        ? ''
        : _miniMessageOf(meta.description);
    minFormatMajor.text = meta?.minFormatMajor.toString() ?? '';
    minFormatMinor.text = meta?.minFormatMinor.toString() ?? '';
    maxFormatMajor.text = meta?.maxFormatMajor.toString() ?? '';
    maxFormatMinor.text = meta?.maxFormatMinor?.toString() ?? '';
  }

  /// The pack meta the fields describe, based on [existing] so id, dates and
  /// enabled features are kept. Only call this after the form validated.
  PackMeta toMeta(PackMeta? existing) {
    final base =
        existing ??
        const PackMeta(
          packType: PackType.resource,
          description: '',
          minFormatMajor: 0,
          maxFormatMajor: 0,
        );
    return base.copyWith(
      description: descriptionJson,
      minFormatMajor: int.parse(minFormatMajor.text.trim()),
      minFormatMinor: int.tryParse(minFormatMinor.text.trim()) ?? 0,
      maxFormatMajor: int.parse(maxFormatMajor.text.trim()),
      maxFormatMinor: int.tryParse(maxFormatMinor.text.trim()),
    );
  }

  /// The MiniMessage of a stored description. One that isn't JSON is taken
  /// as plain text.
  static String _miniMessageOf(String description) {
    try {
      return MiniMessageJson.decode(jsonDecode(description));
    } on FormatException {
      return description;
    }
  }

  void dispose() {
    for (final field in _formats) {
      field.dispose();
    }
  }
}

/// The fields of the resource pack's `pack.mcmeta` in sections.
///
/// Expects to sit inside a [Form]. While every field is empty nothing is
/// required, as the project then has no pack meta.
class PackMetaForm extends StatelessWidget {
  const PackMetaForm({
    required this.controller,
    this.pickIcon = pickPackIcon,
    super.key,
  });

  final PackMetaFormController controller;
  final Future<PickedAssetFile?> Function() pickIcon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hintStyle = Theme.of(context).textTheme.bodySmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Rebuilds the field with the chosen icon, the controller doesn't
        // notify.
        StatefulBuilder(
          builder: (context, setState) => PackIconField(
            value: controller.icon,
            onChanged: (icon) => setState(() => controller.icon = icon),
            pickFile: pickIcon,
          ),
        ),
        verticalSpacing25,
        EditSectionHeading(title: '${l10n.pack_meta_description} *'),
        const SizedBox(height: 8),
        MiniMessageEditor(
          value: controller.description,
          onChanged: (text) => controller.description = text,
          // Not shown in game in one of the known places, white reads best.
          componentContext: ComponentContext.itemName,
          validator: _unlessEmpty(
            Validators.required(l10n.validation_pack_meta_description_required),
          ),
        ),
        verticalSpacing25,
        EditSectionHeading(title: l10n.pack_meta_formats),
        const SizedBox(height: 4),
        Text(l10n.pack_meta_formats_hint, style: hintStyle),
        verticalSpacing10,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _FormatField(
                controller: controller.minFormatMajor,
                label: '${l10n.pack_meta_min_format_major} *',
                validator: _unlessEmpty(_format(context, required: true)),
              ),
            ),
            const _Separator('.'),
            Expanded(
              flex: 2,
              child: _FormatField(
                controller: controller.minFormatMinor,
                label: l10n.pack_meta_format_minor,
                hint: '0',
                validator: _format(context),
              ),
            ),
            const _Separator('–'),
            Expanded(
              flex: 3,
              child: _FormatField(
                controller: controller.maxFormatMajor,
                label: '${l10n.pack_meta_max_format_major} *',
                validator: _unlessEmpty(
                  Validators.compose([
                    _format(context, required: true),
                    _range(l10n.validation_pack_meta_format_range),
                  ]),
                ),
              ),
            ),
            const _Separator('.'),
            Expanded(
              flex: 2,
              child: _FormatField(
                controller: controller.maxFormatMinor,
                label: l10n.pack_meta_format_minor,
                hint: l10n.pack_meta_format_minor_any,
                validator: _format(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Skips [validator] while the whole form is empty.
  FormValidator<String> _unlessEmpty(FormValidator<String> validator) =>
      (value) => controller.isEmpty ? null : validator(value);

  /// Accepts a non-negative whole number, or nothing unless [required].
  static FormValidator<String> _format(
    BuildContext context, {
    bool required = false,
  }) {
    final l10n = context.l10n;
    return (value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) {
        return required ? l10n.validation_pack_meta_format_required : null;
      }
      final number = int.tryParse(text);
      if (number == null || number < 0) {
        return l10n.validation_pack_meta_format_number;
      }
      return null;
    };
  }

  /// Rejects a max format below the min format, the check the backend runs
  /// before it stores a pack meta. Only runs once both majors are numbers.
  FormValidator<String> _range(String message) {
    return (_) {
      final minMajor = int.tryParse(controller.minFormatMajor.text.trim());
      final maxMajor = int.tryParse(controller.maxFormatMajor.text.trim());
      if (minMajor == null || maxMajor == null) return null;
      final valid = PackMeta(
        packType: PackType.resource,
        description: '',
        minFormatMajor: minMajor,
        minFormatMinor:
            int.tryParse(controller.minFormatMinor.text.trim()) ?? 0,
        maxFormatMajor: maxMajor,
        maxFormatMinor: int.tryParse(controller.maxFormatMinor.text.trim()),
      ).isFormatRangeValid;
      return valid ? null : message;
    };
  }
}

class _FormatField extends StatelessWidget {
  const _FormatField({
    required this.controller,
    required this.label,
    required this.validator,
    this.hint,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final FormValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorMaxLines: 2,
      ),
      validator: validator,
    );
  }
}

/// The dot between major and minor, or the dash between min and max, at
/// the height of the field's text.
class _Separator extends StatelessWidget {
  const _Separator(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 16, 6, 0),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
