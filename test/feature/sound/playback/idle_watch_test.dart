import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/sound/playback/idle_watch.dart';

void main() {
  const after = Duration(seconds: 15);

  test('calls back once it has been idle for its duration', () {
    fakeAsync((async) {
      var idle = 0;
      final watch = IdleWatch(after: after, onIdle: () => idle++)..idle();

      async.elapse(const Duration(seconds: 14));
      expect(idle, 0);

      async.elapse(const Duration(seconds: 1));
      expect(idle, 1);

      async.elapse(const Duration(minutes: 1));
      expect(idle, 1);
      watch.dispose();
    });
  });

  test('busy before the duration is up calls nothing back', () {
    fakeAsync((async) {
      var idle = 0;
      final watch = IdleWatch(after: after, onIdle: () => idle++)..idle();

      async.elapse(const Duration(seconds: 10));
      watch.busy();
      async.elapse(const Duration(minutes: 1));

      expect(idle, 0);
      watch.dispose();
    });
  });

  test('idle again counts from the start', () {
    fakeAsync((async) {
      var idle = 0;
      final watch = IdleWatch(after: after, onIdle: () => idle++)..idle();

      async.elapse(const Duration(seconds: 10));
      watch.idle();
      async.elapse(const Duration(seconds: 10));
      expect(idle, 0);

      async.elapse(const Duration(seconds: 5));
      expect(idle, 1);
      watch.dispose();
    });
  });
}
