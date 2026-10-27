import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/asset/asset_kind_label.dart';
import 'package:stelaris/feature/asset/models/model_textures.dart';
import 'package:stelaris/feature/asset/preview/asset_scene_view.dart';
import 'package:stelaris/feature/asset/upload/asset_upload_form.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/feature/component/component_preview.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/relative_time.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The detail of one model on the Models page: its key, the 3D preview, what
/// it is, which items use it and its textures.
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
        AssetSceneView(
          // Loads again when the model or one of its textures changes.
          key: ValueKey(
            [
              model.sha1,
              for (final slot in textures.slots) slot.texture?.sha1,
            ].join('|'),
          ),
          projectId: projectId,
          asset: model,
          viewportFrame: _darkSurface,
        ),
        const SizedBox(height: 16),
        _Section(
          title: l10n.asset_model_info,
          children: [
            _InfoRow(
              label: l10n.asset_model_kind,
              child: Text(assetKindLabel(l10n, model.kind)),
            ),
            _InfoRow(label: l10n.asset_model_file, child: Text(model.fileName)),
            _InfoRow(
              label: l10n.asset_model_size,
              child: Text(formatFileSize(model.size)),
            ),
            if (model.modificationDate ?? model.creationDate case final date?)
              _InfoRow(
                label: l10n.asset_model_changed,
                child: Text(relativeTime(context, date)),
              ),
            _InfoRow(
              label: l10n.asset_model_used_by,
              child: _UsedBy(usedBy: usedBy, onOpenItem: onOpenItem),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _Section(
          title: l10n.asset_model_textures,
          children: [
            if (textures.slots.isEmpty) Text(l10n.asset_model_textures_none),
            for (final slot in textures.slots)
              _TextureRow(
                key: ValueKey('model_texture_${slot.key}'),
                slot: slot,
                embedded: textures.readOnly,
                onUpload: textures.readOnly || onUploadTexture == null
                    ? null
                    : () => onUploadTexture!(slot),
              ),
          ],
        ),
      ],
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

/// An outlined card with a title over [children].
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// A [label] in a fixed column and its value as [child].
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// The items using the model, each opening that item.
class _UsedBy extends StatelessWidget {
  const _UsedBy({required this.usedBy, required this.onOpenItem});

  final Future<List<ItemModel>> usedBy;
  final ValueChanged<ItemModel> onOpenItem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FutureBuilder<List<ItemModel>>(
      future: usedBy,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text(l10n.asset_model_used_by_failed);
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
        if (items.isEmpty) return Text(l10n.asset_model_used_by_none);
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

/// One texture of the model: present or missing, the other models using it,
/// and an upload when it is missing.
class _TextureRow extends StatelessWidget {
  const _TextureRow({
    required this.slot,
    required this.embedded,
    required this.onUpload,
    super.key,
  });

  final TextureSlot slot;

  /// Whether the texture comes from a Blockbench model.
  final bool embedded;
  final VoidCallback? onUpload;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final subtitle = [
      if (slot.missing) l10n.asset_model_texture_missing,
      if (embedded) l10n.asset_model_texture_embedded,
      if (slot.alsoIn.isNotEmpty)
        l10n.asset_model_texture_also_in(
          slot.alsoIn.map((model) => model.key).join(', '),
        ),
    ].join(' · ');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: slot.missing
          ? Icon(Icons.cancel_outlined, color: colorScheme.error)
          : Icon(Icons.check_circle_outline, color: colorScheme.primary),
      title: Text(slot.key),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      trailing: slot.missing && onUpload != null
          ? FilledButton.tonalIcon(
              key: ValueKey('model_texture_upload_${slot.key}'),
              onPressed: onUpload,
              icon: const Icon(Icons.upload),
              label: Text(l10n.asset_picker_upload_action),
            )
          : null,
    );
  }
}
