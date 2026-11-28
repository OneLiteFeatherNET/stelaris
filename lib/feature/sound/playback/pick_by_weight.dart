import 'dart:math';

import 'package:stelaris_models/stelaris_models.dart';

/// One of [sources], picked like the game picks the file a sound event
/// plays: each as likely as its weight. Without any weight above zero each
/// is as likely as the others; without sources there is none.
SoundFileSource? pickByWeight(List<SoundFileSource> sources, Random random) {
  if (sources.isEmpty) return null;
  final weights = [for (final source in sources) max(source.weight, 0)];
  final total = weights.fold(0, (sum, weight) => sum + weight);
  if (total == 0) return sources[random.nextInt(sources.length)];

  var roll = random.nextInt(total);
  for (var i = 0; i < sources.length; i++) {
    roll -= weights[i];
    if (roll < 0) return sources[i];
  }
  return sources.last;
}
