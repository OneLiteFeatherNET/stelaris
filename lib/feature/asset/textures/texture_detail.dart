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
    this.onOpenModel,
    this.onOpenFont,
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

  /// Opens a model or font the texture is used in; without them the uses
  /// are only named, e.g. in the texture picker.
  final ValueChanged<AssetModel>? onOpenModel;
  final ValueChanged<FontModel>? onOpenFont;

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
                onPressed: switch ((source, onOpenModel)) {
                  (final source?, final open?) => () => open(source),
                  _ => null,
                },
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
      // Red like an error, in the shape of the uses it lacks.
      final colorScheme = Theme.of(context).colorScheme;
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: Chip(
          key: const Key('texture_unused'),
          avatar: Icon(
            Icons.link_off,
            size: 16,
            color: colorScheme.onErrorContainer,
          ),
          label: Text(l10n.asset_textures_usage_count(0)),
          labelStyle: TextStyle(color: colorScheme.onErrorContainer),
          backgroundColor: colorScheme.errorContainer,
          side: BorderSide(color: colorScheme.errorContainer),
        ),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final model in usages.models)
          _use(
            key: ValueKey('texture_used_model_${model.id}'),
            icon: Icons.view_in_ar_outlined,
            label: model.displayName,
            onOpen: switch (onOpenModel) {
              final open? => () => open(model),
              null => null,
            },
          ),
        for (final font in usages.fonts)
          _use(
            key: ValueKey('texture_used_font_${font.id}'),
            icon: Icons.text_fields,
            label: font.uiName,
            onOpen: switch (onOpenFont) {
              final open? => () => open(font),
              null => null,
            },
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

  /// One use: a chip that opens it, or only names it without [onOpen].
  static Widget _use({
    required Key key,
    required IconData icon,
    required String label,
    required VoidCallback? onOpen,
  }) {
    final avatar = Icon(icon, size: 16);
    if (onOpen == null) {
      return Chip(key: key, avatar: avatar, label: Text(label));
    }
    return ActionChip(
      key: key,
      avatar: avatar,
      label: Text(label),
      onPressed: onOpen,
    );
  }
}
