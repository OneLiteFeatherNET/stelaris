import 'dart:typed_data';

/// The width and height a PNG declares in its header, or null when [bytes]
/// are no PNG. Reads only the header, the image isn't decoded.
({int width, int height})? pngSize(Uint8List bytes) {
  const signature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
  // The signature, then the IHDR chunk: length, type, width, height.
  if (bytes.length < 24) return null;
  for (var i = 0; i < signature.length; i++) {
    if (bytes[i] != signature[i]) return null;
  }
  final isHeader =
      bytes[12] == 0x49 &&
      bytes[13] == 0x48 &&
      bytes[14] == 0x44 &&
      bytes[15] == 0x52;
  if (!isHeader) return null;
  final data = ByteData.sublistView(bytes);
  return (width: data.getUint32(16), height: data.getUint32(20));
}
