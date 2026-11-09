import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/service/sound/asset_sound_file_loader.dart';
import 'package:stelaris/api/service/sound/sound_file_loader.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_asset_client_api.dart';

SoundFileSource _source({String? assetId}) => SoundFileSource(
  name: 'vulpes:ui/click',
  volume: 1,
  pitch: 1,
  attenuationDistance: 16,
  preload: false,
  type: 'file',
  weight: 1,
  assetId: assetId,
);

void main() {
  final bytes = Uint8List.fromList([0x4f, 0x67, 0x67, 0x53]);
  late FakeAssetClientApi assets;
  late AssetSoundFileLoader loader;

  setUp(() {
    assets = FakeAssetClientApi(
      stored: {FakeAssetClientApi.texture('a-1'): bytes},
    );
    loader = AssetSoundFileLoader(assets);
  });

  test('downloads the linked asset as Ogg', () async {
    final file = await loader.load('p1', _source(assetId: 'a-1'));

    expect(file.bytes, bytes);
    expect(file.mimeType, 'audio/ogg');
  });

  test('a source without an asset has no audio', () async {
    await expectLater(
      loader.load('p1', _source()),
      throwsA(
        isA<SoundFileUnavailableException>().having(
          (e) => e.key,
          'key',
          'vulpes:ui/click',
        ),
      ),
    );
  });
}
