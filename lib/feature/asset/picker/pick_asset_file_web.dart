import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'picked_asset_file.dart';

/// Opens the browser's file dialog for an asset file. Resolves to the chosen
/// file, or null when the dialog is cancelled.
Future<PickedAssetFile?> pickAssetFile() {
  final completer = Completer<PickedAssetFile?>();
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = '.png,.json,.bbmodel'
    ..style.display = 'none';

  void finish(PickedAssetFile? picked) {
    if (!completer.isCompleted) completer.complete(picked);
    input.remove();
  }

  input.onchange = ((web.Event _) {
    final file = input.files?.item(0);
    if (file == null) {
      finish(null);
      return;
    }
    file.arrayBuffer().toDart.then(
      (buffer) => finish(
        PickedAssetFile(name: file.name, bytes: buffer.toDart.asUint8List()),
      ),
      onError: (Object _) => finish(null),
    );
  }).toJS;
  input.oncancel = ((web.Event _) => finish(null)).toJS;

  // Some browsers only open the dialog for an input that is in the page.
  web.document.body?.append(input);
  input.click();
  return completer.future;
}
