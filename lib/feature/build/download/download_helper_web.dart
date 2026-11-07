import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Saves [bytes] as [filename] through the browser.
///
/// A Blob behind an object URL instead of a base64 `data:` URI, which would
/// hold a large zip in memory twice over.
void saveFile(Uint8List bytes, String filename) {
  final web.Blob blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'application/zip'),
  );
  final String url = web.URL.createObjectURL(blob);
  try {
    web.HTMLAnchorElement()
      ..href = url
      ..download = filename
      ..click();
  } finally {
    web.URL.revokeObjectURL(url);
  }
}
