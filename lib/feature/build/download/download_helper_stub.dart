import 'dart:typed_data';

/// Saves [bytes] as [filename]. Only the web app can, so this throws, and
/// the caller shows it as a failed download.
void saveFile(Uint8List bytes, String filename) {
  throw UnsupportedError('Downloads are only supported on the web platform.');
}
