import 'package:flutter/foundation.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The audio of one sound file, as the browser should play it.
@immutable
class SoundFile {
  const SoundFile({required this.bytes, required this.mimeType});

  final Uint8List bytes;

  /// The type the browser decodes [bytes] as, e.g. `audio/ogg`.
  final String mimeType;
}

/// Thrown when the project stores no audio for a sound key.
class SoundFileUnavailableException implements Exception {
  SoundFileUnavailableException(this.key);

  final String key;

  @override
  String toString() => 'SoundFileUnavailableException: no audio for $key';
}

/// Fetches the audio a sound file of a sound event plays.
///
/// Throws a [SoundFileUnavailableException] if the project stores none for
/// it, e.g. for a vanilla sound.
abstract interface class SoundFileLoader {
  Future<SoundFile> load(String projectId, SoundFileSource source);
}
