import 'dart:typed_data';

/// The largest file the backend stores as an asset, 8 MiB: its
/// `spring.servlet.multipart.max-file-size`. A larger file is turned down
/// before it is read, the backend would only refuse it after the upload.
const int maxAssetFileBytes = 8 * 1024 * 1024;

/// A file the user chose to upload as an asset: its name and its bytes.
class PickedAssetFile {
  const PickedAssetFile({required this.name, required this.bytes});

  /// The file name as the user's system reports it, e.g. `ruby.bbmodel`.
  final String name;

  final Uint8List bytes;
}

/// A chosen file larger than [maxAssetFileBytes], which was not read.
class AssetFileTooLarge implements Exception {
  const AssetFileTooLarge({required this.name, required this.size});

  final String name;

  /// The size of the file in bytes.
  final int size;

  @override
  String toString() =>
      'AssetFileTooLarge: $name has $size bytes, '
      'at most $maxAssetFileBytes are allowed';
}
