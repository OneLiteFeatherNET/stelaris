import 'package:material_ui/material_ui.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The icon an asset of [kind] is shown with.
IconData assetKindIcon(AssetKind kind) => switch (kind) {
  AssetKind.TEXTURE => Icons.image_outlined,
  AssetKind.BBMODEL => Icons.view_in_ar,
  AssetKind.MODEL => Icons.category_outlined,
};

/// The name of [kind] as the user reads it.
String assetKindLabel(AppLocalizations l10n, AssetKind kind) => switch (kind) {
  AssetKind.TEXTURE => l10n.asset_library_kind_texture,
  AssetKind.BBMODEL => l10n.asset_picker_kind_bbmodel,
  AssetKind.MODEL => l10n.asset_picker_kind_model,
};
