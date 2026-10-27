import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/asset/picker/asset_key.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  group('suggestAssetKey', () {
    test('uses the minecraft namespace when none is given', () {
      expect(suggestAssetKey('ruby.bbmodel'), 'minecraft:item/ruby');
    });

    test('uses the given namespace when it is a valid one', () {
      expect(
        suggestAssetKey('ruby.json', namespace: 'vulpes'),
        'vulpes:item/ruby',
      );
    });

    test('lowercases the given namespace before checking it', () {
      expect(
        suggestAssetKey('ruby.json', namespace: 'Vulpes'),
        'vulpes:item/ruby',
      );
    });

    test('falls back to minecraft when the namespace is not valid', () {
      expect(
        suggestAssetKey('ruby.json', namespace: 'my mod'),
        'minecraft:item/ruby',
      );
    });

    test('falls back to minecraft for an empty namespace', () {
      expect(
        suggestAssetKey('ruby.json', namespace: ''),
        'minecraft:item/ruby',
      );
    });

    test('replaces characters outside the key alphabet with underscores', () {
      expect(
        suggestAssetKey('Ruby Gem (v2).png'),
        'minecraft:item/ruby_gem__v2_',
      );
    });

    test('only drops the last extension', () {
      expect(suggestAssetKey('ruby.v2.json'), 'minecraft:item/ruby.v2');
    });

    test('keeps slashes in the name', () {
      expect(suggestAssetKey('blocks/ruby.json'), 'minecraft:item/blocks/ruby');
    });

    test('takes a name without extension as it is', () {
      expect(suggestAssetKey('ruby'), 'minecraft:item/ruby');
    });
  });

  group('checkAssetKey', () {
    test('accepts a namespaced resource location', () {
      expect(checkAssetKey('vulpes:item/ruby_gem.v2'), isNull);
    });

    test('rejects an empty key', () {
      expect(checkAssetKey(''), AssetKeyProblem.empty);
    });

    test('requires a namespace', () {
      expect(checkAssetKey('item/ruby'), AssetKeyProblem.missingNamespace);
    });

    test('rejects an empty or invalid namespace', () {
      expect(checkAssetKey(':item/ruby'), AssetKeyProblem.invalidNamespace);
      expect(
        checkAssetKey('Vulpes:item/ruby'),
        AssetKeyProblem.invalidNamespace,
      );
    });

    test('rejects an empty or invalid path', () {
      expect(checkAssetKey('vulpes:'), AssetKeyProblem.invalidPath);
      expect(
        checkAssetKey('vulpes:item/Ruby Gem'),
        AssetKeyProblem.invalidPath,
      );
      expect(checkAssetKey('vulpes:item:ruby'), AssetKeyProblem.invalidPath);
    });

    test('accepts every key it suggests', () {
      for (final name in ['Ruby Gem (v2).png', '.png', 'a.b.json', 'x']) {
        expect(checkAssetKey(suggestAssetKey(name)), isNull, reason: name);
      }
    });
  });

  group('assetKindOfFileName', () {
    test('reads the kind from the extension, in any case', () {
      expect(assetKindOfFileName('gem.PNG'), AssetKind.TEXTURE);
      expect(assetKindOfFileName('ruby.json'), AssetKind.MODEL);
      expect(assetKindOfFileName('ruby.bbmodel'), AssetKind.BBMODEL);
    });

    test('is null for other files', () {
      expect(assetKindOfFileName('notes.txt'), isNull);
      expect(assetKindOfFileName('ruby'), isNull);
    });
  });
}
