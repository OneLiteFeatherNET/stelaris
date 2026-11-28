import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/sound/playback/pick_by_weight.dart';
import 'package:stelaris_models/stelaris_models.dart';

SoundFileSource _source(String name, int weight) => SoundFileSource(
  name: name,
  volume: 1,
  pitch: 1,
  attenuationDistance: 16,
  preload: false,
  type: 'file',
  weight: weight,
);

/// Rolls [roll], and remembers the bound it was asked for.
class _Random implements Random {
  _Random(this.roll);

  final int roll;
  int? max;

  @override
  int nextInt(int max) {
    this.max = max;
    return roll;
  }

  @override
  double nextDouble() => throw UnimplementedError();

  @override
  bool nextBool() => throw UnimplementedError();
}

void main() {
  final a = _source('a', 1);
  final b = _source('b', 3);
  final c = _source('c', 2);

  test('rolls over the sum of the weights', () {
    final random = _Random(0);
    pickByWeight([a, b, c], random);
    expect(random.max, 6);
  });

  test('each source takes as many rolls as its weight', () {
    expect(pickByWeight([a, b, c], _Random(0)), a);
    expect(pickByWeight([a, b, c], _Random(1)), b);
    expect(pickByWeight([a, b, c], _Random(3)), b);
    expect(pickByWeight([a, b, c], _Random(4)), c);
    expect(pickByWeight([a, b, c], _Random(5)), c);
  });

  test('a source without weight is never picked', () {
    final none = _source('none', 0);
    expect(pickByWeight([none, a], _Random(0)), a);
  });

  test('without any weight each source is as likely', () {
    final x = _source('x', 0);
    final y = _source('y', 0);
    final random = _Random(1);
    expect(pickByWeight([x, y], random), y);
    expect(random.max, 2);
  });

  test('picks none from no sources', () {
    expect(pickByWeight([], _Random(0)), isNull);
  });
}
