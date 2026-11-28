import 'package:material_ui/material_ui.dart';
import 'package:stelaris/auth/roles.dart';
import 'package:stelaris/feature/auth/role_gate.dart';
import 'package:stelaris/feature/model/model_card_frame.dart';
import 'package:stelaris/feature/sound/playback/sound_waveform.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// One sound file in the grid of a sound event, in the frame of the model
/// cards: the [playButton] of an uploaded file, its name and key, and a
/// footer of type, volume, pitch, weight and, once known, its [length]. A
/// file linked to an asset is titled with the [assetName], its key below;
/// the file itself only knows the key. The file in the player bar is
/// [highlighted]. A tap on the card edits the file.
class SoundFileCard extends StatelessWidget {
  /// Fits the header with its play button and the footer.
  static const double height = 104;

  const SoundFileCard({
    required this.source,
    required this.onEdit,
    required this.onDelete,
    this.playButton,
    this.assetName,
    this.length,
    this.highlighted = false,
    this.loading = false,
    super.key,
  });

  final SoundFileSource source;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// Plays the file; without it an icon says why there is nothing to play.
  final Widget? playButton;

  /// The display name of the linked asset, while it is known.
  final String? assetName;

  /// How long the file plays at pitch 1, once its audio was read.
  final Duration? length;

  final bool highlighted;

  /// Shows only a progress indicator, until the length and the asset name
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
        margin: EdgeInsets.zero,
        color: theme.colorScheme.surfaceContainerLow,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    final assetName = this.assetName;
    final length = this.length;
    final details = l10n.sound_file_card_subtitle(
      _isEvent ? l10n.sound_type_event : l10n.sound_type_file,
      source.volume.toString(),
      source.pitch.toString(),
      source.weight,
    );
    return ModelCardFrame(
      highlighted: highlighted,
      content: Row(
        children: [
          playButton ?? _NothingToPlay(isEvent: _isEvent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  assetName ?? source.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (assetName != null)
                  Text(
                    source.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
      trailing: RoleGate(
        role: Roles.admin,
        child: IconButton(
          tooltip: l10n.tooltip_delete,
          visualDensity: VisualDensity.compact,
          onPressed: onDelete,
          icon: const Icon(Icons.delete_forever),
        ),
      ),
      footerIcon: _isEvent
          ? Icons.subdirectory_arrow_right
          : Icons.audio_file_outlined,
      footerText: length == null
          ? details
          : '$details · ${formatPlayTime(playTimeAt(length, source.pitch))}',
      onTap: onEdit,
    );
  }
}

/// Takes the place of the play button, as large, for a file without audio,
/// and says why.
class _NothingToPlay extends StatelessWidget {
  const _NothingToPlay({required this.isEvent});

  final bool isEvent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Tooltip(
      message: isEvent ? l10n.sound_file_plays_event : l10n.sound_asset_none,
      child: SizedBox.square(
        dimension: 40,
        child: Icon(
          isEvent ? Icons.link : Icons.link_off,
          size: 20,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
