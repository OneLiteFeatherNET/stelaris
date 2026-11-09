import 'dart:typed_data';

import 'package:stelaris/api/service/client/asset_client_api.dart';
import 'package:stelaris/api/service/sound/sound_file_loader.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Downloads the sound asset a sound file is linked to.
///
/// The backend only stores mono Ogg Vorbis as sounds, so every file is
/// played as `audio/ogg`.
class AssetSoundFileLoader implements SoundFileLoader {
  const AssetSoundFileLoader(this._assets);

  final AssetClientApi _assets;

  @override
  Future<SoundFile> load(String projectId, SoundFileSource source) async {
    final assetId = source.assetId;
    if (assetId == null) throw SoundFileUnavailableException(source.name);
    final bytes = await _assets.content(projectId, assetId);
    return SoundFile(bytes: Uint8List.fromList(bytes), mimeType: 'audio/ogg');
  }
}
