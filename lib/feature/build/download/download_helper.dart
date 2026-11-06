import 'dart:typed_data';

export 'download_helper_stub.dart'
    if (dart.library.js_interop) 'download_helper_web.dart';

/// Saves a downloaded file for the user.
typedef FileSaver = void Function(Uint8List bytes, String filename);
