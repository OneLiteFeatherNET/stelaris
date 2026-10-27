import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/asset/models/flat_item_model.dart';

void main() {
  test('names the file after the key and draws the texture flat', () {
    final model = flatItemModel('vulpes:item/gems/sapphire');

    expect(model.fileName, 'sapphire.json');
    expect(jsonDecode(utf8.decode(model.bytes)), {
      'parent': 'minecraft:item/generated',
      'textures': {'layer0': 'vulpes:item/gems/sapphire'},
    });
  });
}
