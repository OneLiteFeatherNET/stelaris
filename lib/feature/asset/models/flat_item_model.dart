import 'dart:convert';

/// The model JSON of a flat item drawn from the texture [textureKey], stored
/// under the same key: `item/generated` with the texture as `layer0`.
({String fileName, List<int> bytes}) flatItemModel(String textureKey) {
  final name = textureKey.split(RegExp('[:/]')).last;
  final json = {
    'parent': 'minecraft:item/generated',
    'textures': {'layer0': textureKey},
  };
  return (fileName: '$name.json', bytes: utf8.encode(jsonEncode(json)));
}
