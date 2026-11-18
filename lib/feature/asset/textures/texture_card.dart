import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/asset/preview/texture_preview.dart';
import 'package:stelaris/feature/asset/textures/texture_usages.dart';
import 'package:stelaris/feature/base/button/card_actions_menu.dart';
import 'package:stelaris/feature/base/chips/info_chip.dart';
import 'package:stelaris/feature/model/model_card_frame.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// One texture of a grid: its thumbnail, name and key, and in the footer
/// where it comes from.
///
/// [menu] adds the card's ⋮ menu, none when empty. A [selected] card is
/// framed in the primary color, e.g. in the texture picker.
class TextureCard extends StatelessWidget {
  const TextureCard({
    required this.texture,
    required this.usages,
    required this.source,
    required this.bytes,
    required this.onTap,
    this.menu = const [],
    this.selected = false,
    super.key,
  });

  final AssetModel texture;
  final List<CardMenuEntry> menu;

  /// Where the texture is used, null while that loads.
  final TextureUsages? usages;

  /// The Blockbench model the texture was extracted from.
  final AssetModel? source;
  final Future<Uint8List> bytes;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final source = this.source;
    final card = ModelCardFrame(
      content: Row(
        children: [
          TextureThumbnail(asset: texture, bytes: bytes),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  texture.displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                InfoChip(icon: Icons.vpn_key_outlined, text: texture.key),
              ],
            ),
          ),
        ],
      ),
      trailing: menu.isEmpty ? null : CardActionsMenu(entries: menu),
      // An extracted texture says where it comes from, its model is what
      // uses it; an uploaded one how often it is used, once that is known.
      footerIcon: switch ((texture.sourceAssetId, usages)) {
        (_?, _) => Icons.view_in_ar_outlined,
        (null, final usages?) when usages.isEmpty => Icons.link_off,
        (null, _?) => Icons.link,
        (null, null) => null,
      },
      footerText: switch ((texture.sourceAssetId, usages)) {
        (final sourceId?, _) => l10n.asset_textures_extracted_from(
          source?.displayName ?? sourceId,
        ),
        (null, final usages?) => l10n.asset_textures_usage_count(usages.count),
        (null, null) => null,
      },
      onTap: onTap,
    );
    if (!selected) return card;
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.primary, width: 2),
        borderRadius: BorderRadius.circular(AppShapes.medium),
      ),
      child: card,
    );
  }
}
