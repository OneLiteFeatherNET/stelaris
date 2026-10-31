import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/asset/asset_kind_label.dart';
import 'package:stelaris/feature/asset/models/model_textures.dart';
import 'package:stelaris/feature/asset/preview/asset_scene_view.dart';
import 'package:stelaris/feature/asset/upload/asset_upload_form.dart';
import 'package:stelaris/feature/base/edit_card/edit_card.dart';
import 'package:stelaris/feature/base/edit_card/edit_card_grid.dart';
import 'package:stelaris/feature/base/dialog/notice_box.dart';
import 'package:stelaris/feature/base/edit_card/edit_section_heading.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/feature/component/component_preview.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/relative_time.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The detail of one model on the Models page: its key, a warning when
/// textures are missing, what it is, which
/// items use it and its textures, with the 3D preview to the right of them on
/// a wide page and above them on a narrow one.
class ModelDetail extends StatelessWidget {
  const ModelDetail({
    required this.projectId,
    required this.model,
    required this.textures,
    required this.usedBy,
    required this.onOpenItem,
    this.onUploadTexture,
    super.key,
  });

  final String projectId;
  final AssetModel model;
  final ModelTextures textures;

  /// The items whose item model is this model, loaded after the detail shows.
  final Future<List<ItemModel>> usedBy;
  final ValueChanged<ItemModel> onOpenItem;

  /// Uploads the missing texture of a slot, null hides the upload.
  final ValueChanged<TextureSlot>? onUploadTexture;

  /// From this width on the preview stands to the right of the cards.
  static const double _sideBySideWidth = 960;
  static const double _previewWidth = 420;
  static const double _previewGap = 24;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                model.key,
                key: const Key('model_detail_title'),
                style: theme.textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              key: const Key('model_detail_copy'),
              tooltip: l10n.asset_model_copy_key,
              icon: const Icon(Icons.copy_outlined, size: 18),
              onPressed: () => _copyKey(context),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_missingCount case final missing when missing > 0) ...[
          NoticeBox(
            key: const Key('model_missing_notice'),
            icon: Icons.warning_amber_rounded,
            color: theme.colorScheme.error,
            content: Text(l10n.asset_model_missing_notice(missing)),
          ),
          const SizedBox(height: 16),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            if (width < _sideBySideWidth) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _preview(),
                  const SizedBox(height: 24),
                  _buildSections(context, EditCardGrid.cardWidthIn(width)),
                ],
              );
            }
            final sectionsWidth = width - _previewWidth - _previewGap;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: sectionsWidth,
                  child: _buildSections(
                    context,
                    EditCardGrid.cardWidthIn(sectionsWidth),
                  ),
                ),
                const SizedBox(width: _previewGap),
                SizedBox(width: _previewWidth, child: _preview()),
              ],
            );
          },
        ),
      ],
    );
  }

  int get _missingCount => textures.slots.where((slot) => slot.missing).length;

  Widget _preview() => AssetSceneView(
    // Loads again when the model or one of its textures changes.
    key: ValueKey(
      [model.sha1, for (final slot in textures.slots) slot.texture?.sha1].join('|'),
    ),
    projectId: projectId,
    asset: model,
    viewportFrame: _darkSurface,
  );

  /// The general facts and the textures, as cards under headings like the
  /// fields of the other detail pages. Each card is [cardWidth] wide.
  Widget _buildSections(BuildContext context, double cardWidth) {
    final l10n = context.l10n;
    Widget card(Widget child) => SizedBox(width: cardWidth, child: child);
    final date = model.modificationDate ?? model.creationDate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditSectionHeading(title: l10n.asset_model_info),
        const SizedBox(height: 8),
        Wrap(
          spacing: EditCardGrid.spacing,
          runSpacing: EditCardGrid.spacing,
          children: [
            card(
              EditCard(
                icon: assetKindIcon(model.kind),
                label: l10n.asset_model_kind,
                value: assetKindLabel(l10n, model.kind),
              ),
            ),
            card(
              EditCard(
                icon: Icons.insert_drive_file_outlined,
                label: l10n.asset_model_file,
                value: model.fileName,
              ),
            ),
            card(
              EditCard(
                icon: Icons.data_usage,
                label: l10n.asset_model_size,
                value: formatFileSize(model.size),
              ),
            ),
            if (date != null)
              card(
                EditCard(
                  icon: Icons.schedule,
                  label: l10n.asset_model_changed,
                  value: relativeTime(context, date),
                ),
              ),
            card(
              EditCard(
                icon: Icons.inventory_2_outlined,
                label: l10n.asset_model_used_by,
                value: '',
                preview: _UsedBy(usedBy: usedBy, onOpenItem: onOpenItem),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        EditSectionHeading(title: l10n.asset_model_textures),
        const SizedBox(height: 8),
        if (textures.slots.isEmpty)
          Text(l10n.asset_model_textures_none)
        else
          Wrap(
            spacing: EditCardGrid.spacing,
            runSpacing: EditCardGrid.spacing,
            children: [
              for (final slot in textures.slots)
                card(_textureCard(context, slot)),
            ],
          ),
      ],
    );
  }

  /// One texture: present, embedded or missing, with the other models using
  /// it. A tap on a missing texture uploads it.
  Widget _textureCard(BuildContext context, TextureSlot slot) {
    final l10n = context.l10n;
    final upload = onUploadTexture;
    final canUpload = slot.missing && !textures.readOnly && upload != null;
    final footer = [
      if (canUpload) l10n.asset_model_texture_upload_hint,
      if (slot.alsoIn.isNotEmpty)
        l10n.asset_model_texture_also_in(
          slot.alsoIn.map((model) => model.key).join(', '),
        ),
    ].join(' · ');
    return EditCard(
      key: ValueKey(
        canUpload
            ? 'model_texture_upload_${slot.key}'
            : 'model_texture_${slot.key}',
      ),
      icon: slot.missing ? Icons.cancel_outlined : Icons.check_circle_outline,
      label: slot.missing
          ? l10n.asset_model_texture_missing
          : textures.readOnly
          ? l10n.asset_model_texture_embedded
          : l10n.asset_model_texture_present,
      value: slot.key,
      footer: footer.isEmpty ? null : footer,
      onTap: canUpload ? () => upload(slot) : null,
    );
  }

  Future<void> _copyKey(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = context.l10n.asset_model_key_copied(model.key);
    await Clipboard.setData(ClipboardData(text: model.key));
    messenger.showSnackBar(InfoBarFactory().create(message));
  }

  /// Puts the viewport on the dark preview surface; the controls stay on the page.
  Widget _darkSurface(Widget viewport) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: previewBackground,
      borderRadius: BorderRadius.circular(AppShapes.extraSmall),
      border: Border.all(color: previewBorder),
    ),
    child: viewport,
  );
}

/// The items using the model as chips, each opening that item.
class _UsedBy extends StatelessWidget {
  const _UsedBy({required this.usedBy, required this.onOpenItem});

  final Future<List<ItemModel>> usedBy;
  final ValueChanged<ItemModel> onOpenItem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textStyle = Theme.of(context).textTheme.titleMedium;
    return FutureBuilder<List<ItemModel>>(
      future: usedBy,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(l10n.asset_model_used_by_failed, style: textStyle);
        }
        final items = snapshot.data;
        if (items == null) {
          return const Align(
            alignment: AlignmentDirectional.centerStart,
            child: SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        if (items.isEmpty) {
          return Text(l10n.asset_model_used_by_none, style: textStyle);
        }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in items)
              ActionChip(
                key: ValueKey('model_used_by_${item.id}'),
                avatar: const Icon(Icons.open_in_new, size: 16),
                label: Text(item.uiName),
                onPressed: () => onOpenItem(item),
              ),
          ],
        );
      },
    );
  }
}
