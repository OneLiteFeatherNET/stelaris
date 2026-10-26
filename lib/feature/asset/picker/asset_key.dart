final RegExp _namespacePattern = RegExp(r'^[a-z0-9_.-]+$');
final RegExp _pathInvalidChars = RegExp(r'[^a-z0-9_./-]');

/// Suggests the resource key of an uploaded [fileName] as `namespace:item/name`.
///
/// The namespace is [namespace] when it is a valid Minecraft namespace (after
/// lowercasing), otherwise `minecraft`. The name is the file name without its
/// extension, lowercased, with characters outside `[a-z0-9_./-]` replaced by `_`.
String suggestAssetKey(String fileName, {String? namespace}) {
  final given = namespace?.toLowerCase();
  final resolvedNamespace = given != null && _namespacePattern.hasMatch(given)
      ? given
      : 'minecraft';

  final dot = fileName.lastIndexOf('.');
  final baseName = (dot > 0 ? fileName.substring(0, dot) : fileName)
      .toLowerCase();
  final path = baseName.replaceAll(_pathInvalidChars, '_');

  return '$resolvedNamespace:item/$path';
}
