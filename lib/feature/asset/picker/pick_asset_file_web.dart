import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'picked_asset_file.dart';

/// Opens the browser's file dialog for an asset file. Resolves to the chosen
/// file, or null when the dialog is cancelled. Fails when the chosen file
/// can't be read.
Future<PickedAssetFile?> pickAssetFile() {
  final completer = Completer<PickedAssetFile?>();
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = '.png,.json,.bbmodel'
    ..style.display = 'none';

  void finish(Future<PickedAssetFile?> picked) {
    if (!completer.isCompleted) completer.complete(picked);
    input.remove();
  }

  input.onchange = ((web.Event _) {
    final file = input.files?.item(0);
    finish(file == null ? Future.value() : readAssetFile(file));
  }).toJS;
  input.oncancel = ((web.Event _) => finish(Future.value())).toJS;

  // Some browsers only open the dialog for an input that is in the page.
  web.document.body?.append(input);
  input.click();
  return completer.future;
}

/// Reads the name and the bytes of [file].
Future<PickedAssetFile> readAssetFile(web.File file) async {
  final buffer = await file.arrayBuffer().toDart;
  return PickedAssetFile(name: file.name, bytes: buffer.toDart.asUint8List());
}
