import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/sound/modal/sound_file_modal_helper.dart';

void main() {
  test('a sound is suggested under the first part of the event key', () {
    expect(soundKeyFolder('ui.button.click'), 'ui');
    expect(soundKeyFolder('custom:Entity.player.hurt'), 'entity');
  });

  test('without a usable key it is suggested under sound', () {
    expect(soundKeyFolder(null), 'sound');
    expect(soundKeyFolder(''), 'sound');
    expect(soundKeyFolder('ui/click.wave'), 'sound');
  });
}
