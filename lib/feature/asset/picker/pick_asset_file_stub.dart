import 'picked_asset_file.dart';

/// Outside the web build there is no file dialog, so nothing is picked.
Future<PickedAssetFile?> pickAssetFile({
  String accept = '.png,.json,.bbmodel',
}) async => null;
