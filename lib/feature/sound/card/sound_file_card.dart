import 'package:material_ui/material_ui.dart';
import 'package:stelaris/auth/roles.dart';
import 'package:stelaris/feature/auth/role_gate.dart';
import 'package:stelaris/feature/model/model_card_frame.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// One sound file in the grid of a sound event, in the frame of the model
/// cards: its name, the [player] of an uploaded file, and a footer of type,
/// volume and pitch. A file linked to an asset is titled with the
/// [assetName], its key below; the file itself only knows the key. A tap on
/// the card edits the file.
class SoundFileCard extends StatelessWidget {
  /// Fits the header, the key, the player and the footer.
  static const double height = 176;

  const SoundFileCard({
    required this.source,
    required this.onEdit,
    required this.onDelete,
    this.player,
    this.assetName,
    this.loading = false,
    super.key,
  });

  final SoundFileSource source;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// Plays the file; without it the card says why there is nothing to play.
  final Widget? player;

  /// The display name of the linked asset, while it is known.
  final String? assetName;

  /// Shows only a progress indicator, until the waveform and the asset name
  /// are there, so the card appears whole.
  final bool loading;

  bool get _isEvent => source.type == 'event';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    if (loading) {
      return Card.filled(
        key: const Key('sound_file_card_loading'),
        color: theme.colorScheme.surfaceContainerLow,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    final assetName = this.assetName;
    return ModelCardFrame(
      content: Text(
        assetName ?? source.name,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      summary: assetName == null ? null : source.name,
      trailing: RoleGate(
        role: Roles.admin,
        child: IconButton(
          tooltip: l10n.tooltip_delete,
          visualDensity: VisualDensity.compact,
          onPressed: onDelete,
          icon: const Icon(Icons.delete_forever),
        ),
      ),
      body: player ?? _NothingToPlay(isEvent: _isEvent),
      footerIcon: _isEvent
          ? Icons.subdirectory_arrow_right
          : Icons.audio_file_outlined,
      footerText: l10n.sound_file_card_subtitle(
        _isEvent ? l10n.sound_type_event : l10n.sound_type_file,
        source.volume.toString(),
        source.pitch.toString(),
      ),
      onTap: onEdit,
    );
  }
}

/// Takes the place of the player, as high, for a file without audio.
class _NothingToPlay extends StatelessWidget {
  const _NothingToPlay({required this.isEvent});

  final bool isEvent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Icon(isEvent ? Icons.link : Icons.link_off, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isEvent ? l10n.sound_file_plays_event : l10n.sound_asset_none,
              style: theme.textTheme.bodySmall?.copyWith(color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
