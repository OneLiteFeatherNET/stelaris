import 'dart:typed_data';

/// A file the user chose to upload as an asset: its name and its bytes.
class PickedAssetFile {
  const PickedAssetFile({required this.name, required this.bytes});

  /// The file name as the user's system reports it, e.g. `ruby.bbmodel`.
  final String name;

  final Uint8List bytes;
}
