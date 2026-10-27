import 'package:stelaris_models/stelaris_models.dart';

final RegExp _namespacePattern = RegExp(r'^[a-z0-9_.-]+$');
final RegExp _pathPattern = RegExp(r'^[a-z0-9_./-]+$');
final RegExp _pathInvalidChars = RegExp(r'[^a-z0-9_./-]');

/// Suggests the resource key of an uploaded [fileName] as `namespace:item/name`.
///
/// The namespace is [namespace] when it is a valid Minecraft namespace (after
/// lowercasing), otherwise `minecraft`. The name is the file name without its
/// extension, lowercased, with characters outside `[a-z0-9_./-]` replaced by `_`.
String suggestAssetKey(String fileName, {String? namespace}) {
  final resolvedNamespace = validNamespaceOr(namespace);

  final dot = fileName.lastIndexOf('.');
  final baseName = (dot > 0 ? fileName.substring(0, dot) : fileName)
      .toLowerCase();
  final path = baseName.replaceAll(_pathInvalidChars, '_');

  return '$resolvedNamespace:item/$path';
}

/// [namespace] lowercased when it is a valid Minecraft namespace, otherwise
/// `minecraft`.
String validNamespaceOr(String? namespace) {
  final given = namespace?.toLowerCase();
  return given != null && _namespacePattern.hasMatch(given)
      ? given
      : 'minecraft';
}

/// Why a key can't name an asset.
enum AssetKeyProblem { empty, missingNamespace, invalidNamespace, invalidPath }

/// The problem of [key] as a resource location `namespace:path`, or null when
/// it is one. Unlike Minecraft the namespace is required, since items refer
/// to the asset by exactly this key.
AssetKeyProblem? checkAssetKey(String key) {
  if (key.isEmpty) return AssetKeyProblem.empty;
  final colon = key.indexOf(':');
  if (colon < 0) return AssetKeyProblem.missingNamespace;
  if (!_namespacePattern.hasMatch(key.substring(0, colon))) {
    return AssetKeyProblem.invalidNamespace;
  }
  if (!_pathPattern.hasMatch(key.substring(colon + 1))) {
    return AssetKeyProblem.invalidPath;
  }
  return null;
}

/// The kind the backend stores [fileName] as, by its extension, or null when
/// it can't be uploaded.
AssetKind? assetKindOfFileName(String fileName) {
  final dot = fileName.lastIndexOf('.');
  if (dot < 0) return null;
  return switch (fileName.substring(dot + 1).toLowerCase()) {
    'png' => AssetKind.TEXTURE,
    'json' => AssetKind.MODEL,
    'bbmodel' => AssetKind.BBMODEL,
    _ => null,
  };
}
