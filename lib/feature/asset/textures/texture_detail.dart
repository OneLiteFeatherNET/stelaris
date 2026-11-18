import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/asset/preview/texture_preview.dart';
import 'package:stelaris/feature/asset/textures/texture_usages.dart';
import 'package:stelaris/feature/base/chips/info_chip.dart';
import 'package:stelaris/feature/base/dialog/notice_box.dart';
import 'package:stelaris/feature/base/edit_card/edit_section_heading.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The label of the pack whose icon a texture is.
String packIconLabel(AppLocalizations l10n, PackType type) => switch (type) {
  PackType.resource => l10n.asset_textures_used_resource_icon,
  PackType.data => l10n.asset_textures_used_data_icon,
};

/// One opened texture: a large preview, its key and origin, and where it is
/// used.
///
/// [usages] is null while they load; [usagesFailed] says they could not be
/// loaded.
class TextureDetail extends StatelessWidget {
  const TextureDetail({
    required this.projectId,
    required this.texture,
    required this.usages,
    required this.onOpenModel,
    required this.onOpenFont,
    this.usagesFailed = false,
    this.onRetryUsages,
    this.source,
    this.loadContent,
    super.key,
  });

  final String projectId;
  final AssetModel texture;
  final TextureUsages? usages;
  final bool usagesFailed;

  /// Loads the uses again after they failed; no retry button when null.
  final VoidCallback? onRetryUsages;

  /// The Blockbench model the texture was extracted from.
  final AssetModel? source;

  /// Loads the bytes of the preview, the backend when null.
  final TextureContentLoader? loadContent;
  final ValueChanged<AssetModel> onOpenModel;
  final ValueChanged<FontModel> onOpenFont;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final source = this.source;
    final loadContent = this.loadContent;
    final sameKeyAs = usages?.sameKeyAs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (loadContent == null)
          TexturePreview(projectId: projectId, asset: texture)
        else
          TexturePreview(
            projectId: projectId,
            asset: texture,
            loadContent: loadContent,
          ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            InfoChip(icon: Icons.vpn_key_outlined, text: texture.key),
            if (texture.sourceAssetId != null)
              ActionChip(
                key: const Key('texture_source'),
                avatar: const Icon(Icons.view_in_ar_outlined, size: 16),
                label: Text(
                  l10n.asset_textures_extracted_from(
                    source?.displayName ?? texture.sourceAssetId!,
                  ),
                ),
                onPressed: source == null ? null : () => onOpenModel(source),
              ),
          ],
        ),
        if (sameKeyAs != null) ...[
          const SizedBox(height: 16),
          NoticeBox(
            icon: Icons.info_outline,
            content: Text(l10n.asset_textures_same_key(sameKeyAs.displayName)),
          ),
        ],
        const SizedBox(height: 24),
        EditSectionHeading(title: l10n.asset_textures_used_in),
        const SizedBox(height: 8),
        _usages(context),
      ],
    );
  }

  Widget _usages(BuildContext context) {
    final l10n = context.l10n;
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    if (usagesFailed) {
      final onRetry = onRetryUsages;
      return Row(
        children: [
          Flexible(
            child: Text(l10n.asset_textures_usages_failed, style: textStyle),
          ),
          if (onRetry != null)
            TextButton(
              key: const Key('texture_usages_retry'),
              onPressed: onRetry,
              child: Text(l10n.asset_textures_usages_retry),
            ),
        ],
      );
    }
    final usages = this.usages;
    if (usages == null) {
      return const Align(
        key: Key('texture_usages_loading'),
        alignment: AlignmentDirectional.centerStart,
        child: SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (usages.isEmpty) {
      return Text(l10n.asset_textures_unused, style: textStyle);
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final model in usages.models)
          ActionChip(
            key: ValueKey('texture_used_model_${model.id}'),
            avatar: const Icon(Icons.view_in_ar_outlined, size: 16),
            label: Text(model.displayName),
            onPressed: () => onOpenModel(model),
          ),
        for (final font in usages.fonts)
          ActionChip(
            key: ValueKey('texture_used_font_${font.id}'),
            avatar: const Icon(Icons.text_fields, size: 16),
            label: Text(font.uiName),
            onPressed: () => onOpenFont(font),
          ),
        for (final type in usages.packIcons)
          Chip(
            key: ValueKey('texture_used_pack_${type.name}'),
            avatar: const Icon(Icons.inventory_2_outlined, size: 16),
            label: Text(packIconLabel(l10n, type)),
          ),
      ],
    );
  }
}
