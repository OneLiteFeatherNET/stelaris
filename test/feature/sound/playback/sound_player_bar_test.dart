@Tags(['web'])
library;

import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/service/sound/sound_file_loader.dart';
import 'package:stelaris/feature/sound/playback/sound_decoder.dart';
import 'package:stelaris/feature/sound/playback/sound_playback_controller.dart';
import 'package:stelaris/feature/sound/playback/sound_player.dart';
import 'package:stelaris/feature/sound/playback/sound_player_bar.dart';
import 'package:stelaris/feature/sound/playback/sound_waveform.dart';
import 'package:stelaris/feature/sound/playback/sound_waveform_painter.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/l10n/app_localizations_delegates.dart';
import 'package:stelaris_models/stelaris_models.dart';

SoundFileSource _source(String id, {int weight = 1}) => SoundFileSource(
  id: id,
  name: 'vulpes:step/$id',
  volume: 1,
  pitch: 1,
  attenuationDistance: 16,
  preload: false,
  type: 'file',
  weight: weight,
  assetId: 'asset-$id',
);

class _Loader implements SoundFileLoader {
  @override
  Future<SoundFile> load(String projectId, SoundFileSource source) async =>
      SoundFile(bytes: Uint8List(0), mimeType: 'audio/ogg');
}

class _Decoder implements SoundDecoder {
  @override
  Future<SoundWaveform> waveform(SoundFile file, {int buckets = 64}) async =>
      const SoundWaveform(peaks: [0.2, 1, 0.5], duration: Duration(seconds: 4));
}

class _Player implements SoundPlayer {
  Completer<void>? playing;
  final List<double> pitches = [];
  final List<Duration> seeks = [];
  final List<Duration> playedFrom = [];
  int pauses = 0;

  @override
  Duration position = Duration.zero;

  @override
  Future<void> play(
    SoundFile file, {
    required double volume,
    required double pitch,
    Duration from = Duration.zero,
  }) {
    playedFrom.add(from);
    return (playing = Completer<void>()).future;
  }

  @override
  void stop() {
    final current = playing;
    playing = null;
    if (current != null && !current.isCompleted) current.complete();
  }

  @override
  void pause() => pauses++;

  @override
  void resume() {}

  @override
  void seek(Duration position) => seeks.add(position);

  @override
  void adjust({required double volume, required double pitch}) =>
      pitches.add(pitch);
}

/// Always rolls [roll].
class _Random implements Random {
  _Random(this.roll);

  final int roll;

  @override
  int nextInt(int max) => roll;

  @override
  double nextDouble() => throw UnimplementedError();

  @override
  bool nextBool() => throw UnimplementedError();
}

void main() {
  late _Player player;
  late SoundPlaybackController controller;
  late List<SoundFileSource> applied;

  final a = _source('a');
  final b = _source('b', weight: 3);
  final c = _source('c');

  setUp(() {
    player = _Player();
    applied = [];
    controller = SoundPlaybackController(
      loader: _Loader(),
      player: player,
      decoder: _Decoder(),
    );
  });

  tearDown(() => controller.dispose());

  Future<void> pumpBar(
    WidgetTester tester, {
    Random? random,
    bool shortcutsEnabled = true,
    Widget? above,
  }) async {
    tester.view.physicalSize = const Size(1400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ?above,
              SoundPlayerBar(
                controller: controller,
                projectId: 'p1',
                sources: [a, b, c],
                titleOf: (source) => 'Step ${source.id}',
                onPlay: (source, {from = Duration.zero}) =>
                    controller.play('p1', source, from: from),
                onApply: (updated) async => applied.add(updated),
                random: random,
                shortcutsEnabled: shortcutsEnabled,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Lets loads and waveforms arrive. Not pumpAndSettle: the bar ticks
  /// every frame while a file plays.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  /// Plays [source] as a card would, and lets it start.
  Future<void> start(WidgetTester tester, SoundFileSource source) async {
    controller.play('p1', source).ignore();
    await settle(tester);
  }

  testWidgets('stays hidden until a file is played', (tester) async {
    await pumpBar(tester);
    expect(find.byKey(const Key('sound_player_bar')), findsNothing);

    await start(tester, b);

    expect(find.byKey(const Key('sound_player_bar')), findsOneWidget);
    expect(find.text('Step b'), findsOneWidget);
    expect(find.text('vulpes:step/b'), findsNothing);
  });

  testWidgets('keeps the waveform in the middle', (tester) async {
    await pumpBar(tester);
    await start(tester, a);

    final bar = tester.getRect(find.byKey(const Key('sound_player_bar')));
    final waveform = tester.getRect(
      find
          .ancestor(
            of: find.byKey(const Key('sound_player_waveform')),
            matching: find.byType(ConstrainedBox),
          )
          .first,
    );
    expect(waveform.center.dx, closeTo(bar.center.dx, 1));
  });

  testWidgets('pauses and plays on', (tester) async {
    await pumpBar(tester);
    await start(tester, a);

    await tester.tap(find.byKey(const Key('sound_player_play_pause')));
    await tester.pump();
    expect(controller.status, SoundPlaybackStatus.paused);
    expect(player.pauses, 1);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    await tester.tap(find.byKey(const Key('sound_player_play_pause')));
    await tester.pump();
    expect(controller.status, SoundPlaybackStatus.playing);
    expect(find.byIcon(Icons.pause), findsOneWidget);
  });

  testWidgets('plays an ended file again', (tester) async {
    await pumpBar(tester);
    await start(tester, a);
    player.playing!.complete();
    await settle(tester);
    expect(controller.status, SoundPlaybackStatus.idle);

    await tester.tap(find.byKey(const Key('sound_player_play_pause')));
    await settle(tester);

    expect(controller.status, SoundPlaybackStatus.playing);
    expect(controller.current, a);
  });

  testWidgets('steps to the next and the previous file', (tester) async {
    await pumpBar(tester);
    await start(tester, b);

    await tester.tap(find.byKey(const Key('sound_player_next')));
    await settle(tester);
    expect(controller.current, c);

    await tester.tap(find.byKey(const Key('sound_player_previous')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('sound_player_previous')));
    await settle(tester);
    expect(controller.current, a);
  });

  testWidgets('has no previous before the first, no next after the last', (
    tester,
  ) async {
    await pumpBar(tester);
    await start(tester, a);

    IconButton button(String key) =>
        tester.widget<IconButton>(find.byKey(Key(key)));
    expect(button('sound_player_previous').onPressed, isNull);

    await start(tester, c);
    expect(button('sound_player_next').onPressed, isNull);
  });

  testWidgets('the dice plays a file picked by weight', (tester) async {
    // Rolls 0..4 over the weights 1, 3, 1: a 3 lands on b.
    await pumpBar(tester, random: _Random(3));
    await start(tester, a);

    await tester.tap(find.byKey(const Key('sound_player_random')));
    await settle(tester);

    expect(controller.current, b);
  });

  testWidgets('a tap in the waveform jumps there', (tester) async {
    await pumpBar(tester);
    await start(tester, a);

    final waveform = find.byKey(const Key('sound_player_waveform'));
    final box = tester.getRect(waveform);
    await tester.tapAt(Offset(box.left + box.width * 0.75, box.center.dy));
    await tester.pump();

    expect(player.seeks, [const Duration(seconds: 3)]);
  });

  testWidgets('a tap in the waveform of an ended file plays from there', (
    tester,
  ) async {
    await pumpBar(tester);
    await start(tester, a);
    player.playing!.complete();
    await settle(tester);

    final box = tester.getRect(find.byKey(const Key('sound_player_waveform')));
    await tester.tapAt(Offset(box.left + box.width / 2, box.center.dy));
    await settle(tester);

    expect(player.playedFrom.last, const Duration(seconds: 2));
  });

  testWidgets('a drag along the waveform seeks once where it lets go', (
    tester,
  ) async {
    await pumpBar(tester);
    await start(tester, a);

    final box = tester.getRect(find.byKey(const Key('sound_player_waveform')));
    final gesture = await tester.startGesture(
      Offset(box.left + box.width * 0.25, box.center.dy),
    );
    for (final at in [0.4, 0.5, 0.6, 0.75]) {
      await gesture.moveTo(Offset(box.left + box.width * at, box.center.dy));
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(player.seeks, isEmpty);
    expect(find.text('0:03 / 0:04'), findsOneWidget);

    await gesture.up();
    await tester.pump();

    expect(player.seeks, [const Duration(seconds: 3)]);
  });

  testWidgets('the sliders of the tune menu start at the same place', (
    tester,
  ) async {
    await pumpBar(tester);
    await start(tester, a);

    await tester.tap(find.byKey(const Key('sound_player_tune')));
    await settle(tester);

    double sliderLeft(String key) => tester
        .getRect(
          find.descendant(
            of: find.byKey(Key(key)),
            matching: find.byType(Slider),
          ),
        )
        .left;
    expect(sliderLeft('sound_player_pitch'), sliderLeft('sound_player_volume'));
  });

  testWidgets('a line follows the mouse over the waveform', (tester) async {
    await pumpBar(tester);
    await start(tester, a);

    double? hover() => (tester
                .widget<CustomPaint>(
                  find.descendant(
                    of: find.byKey(const Key('sound_player_waveform')),
                    matching: find.byType(CustomPaint),
                  ),
                )
                .painter!
            as SoundWaveformPainter)
        .hover!
        .value;

    final box = tester.getRect(find.byKey(const Key('sound_player_waveform')));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(Offset(box.left + box.width / 4, box.center.dy));
    await tester.pump();
    expect(hover(), closeTo(0.25, 0.01));

    await mouse.moveTo(Offset.zero);
    await tester.pump();
    expect(hover(), isNull);
  });

  testWidgets('the tune menu ends where its button ends', (tester) async {
    await pumpBar(tester);
    await start(tester, a);

    await tester.tap(find.byKey(const Key('sound_player_tune')));
    await settle(tester);

    expect(
      tester.getRect(find.byKey(const Key('sound_player_tune_menu'))).right,
      closeTo(
        tester.getRect(find.byKey(const Key('sound_player_tune'))).right,
        1,
      ),
    );
  });

  SoundWaveformPainter waveformPainter(WidgetTester tester) =>
      tester
              .widget<CustomPaint>(
                find.descendant(
                  of: find.byKey(const Key('sound_player_waveform')),
                  matching: find.byType(CustomPaint),
                ),
              )
              .painter!
          as SoundWaveformPainter;

  testWidgets('the bars grow out of the flat line once they are read', (
    tester,
  ) async {
    await pumpBar(tester);
    await start(tester, a);

    final growing = waveformPainter(tester).shownPeaks;
    expect(growing, hasLength(3));
    for (final (i, peak) in growing.indexed) {
      expect(peak, lessThan([0.2, 1.0, 0.5][i]));
    }

    await tester.pump(const Duration(milliseconds: 300));

    expect(waveformPainter(tester).shownPeaks, [0.2, 1, 0.5]);
  });

  testWidgets('the bars show at once with animations turned off', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpBar(tester);
    await start(tester, a);

    expect(waveformPainter(tester).shownPeaks, [0.2, 1, 0.5]);
  });

  testWidgets('the tune menu keeps a gap to the bar', (tester) async {
    await pumpBar(tester);
    await start(tester, a);

    await tester.tap(find.byKey(const Key('sound_player_tune')));
    await settle(tester);

    final bar = tester.getRect(find.byKey(const Key('sound_player_bar')));
    expect(
      tester.getRect(find.byKey(const Key('sound_player_tune_menu'))).bottom,
      closeTo(bar.top - 8, 1),
    );
  });

  testWidgets('the tune menu closes on escape and on a tap outside', (
    tester,
  ) async {
    await pumpBar(tester);
    await start(tester, a);
    final menu = find.byKey(const Key('sound_player_tune_menu'));

    await tester.tap(find.byKey(const Key('sound_player_tune')));
    await settle(tester);
    expect(menu, findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await settle(tester);
    expect(menu, findsNothing);

    await tester.tap(find.byKey(const Key('sound_player_tune')));
    await settle(tester);
    expect(menu, findsOneWidget);
    await tester.tapAt(const Offset(20, 20));
    await settle(tester);
    expect(menu, findsNothing);
  });

  testWidgets('the time and the slider values fit their room in one line', (
    tester,
  ) async {
    await pumpBar(tester);
    await start(tester, a);
    await tester.tap(find.byKey(const Key('sound_player_tune')));
    await settle(tester);

    void expectFits(Finder text) {
      final paragraph = tester.renderObject<RenderParagraph>(text);
      expect(
        paragraph.getMaxIntrinsicWidth(double.infinity),
        lessThanOrEqualTo(paragraph.size.width),
      );
    }

    expectFits(find.byKey(const Key('sound_player_time')));
    expectFits(find.text('1.00').last);
  });

  testWidgets('the pitch is tried out live, then applied or reset', (
    tester,
  ) async {
    await pumpBar(tester);
    await start(tester, a);

    await tester.tap(find.byKey(const Key('sound_player_tune')));
    await settle(tester);

    FilledButton applyButton() => tester.widget<FilledButton>(
      find.byKey(const Key('sound_player_apply')),
    );
    expect(applyButton().onPressed, isNull);

    final slider = find.descendant(
      of: find.byKey(const Key('sound_player_pitch')),
      matching: find.byType(Slider),
    );
    tester.widget<Slider>(slider).onChanged!(1.5000000001);
    await tester.pump();

    expect(controller.pitchOf(a), 1.5);
    expect(player.pitches, [1.5]);
    expect(find.text('1.50'), findsOneWidget);

    await tester.tap(find.byKey(const Key('sound_player_apply')));
    await tester.pump();
    expect(applied.single.pitch, 1.5);
    expect(applied.single.id, 'a');

    await tester.tap(find.byKey(const Key('sound_player_reset')));
    await tester.pump();
    expect(controller.hasPreview, isFalse);
    expect(controller.pitchOf(a), 1);
  });

  testWidgets('closing stops and hides the bar', (tester) async {
    await pumpBar(tester);
    await start(tester, a);

    await tester.tap(find.byKey(const Key('sound_player_close')));
    await settle(tester);

    expect(controller.current, isNull);
    expect(find.byKey(const Key('sound_player_bar')), findsNothing);
  });

  group('keys', () {
    testWidgets('space starts the first file, then pauses it', (tester) async {
      await pumpBar(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await settle(tester);
      expect(controller.current, a);
      expect(controller.status, SoundPlaybackStatus.playing);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(controller.status, SoundPlaybackStatus.paused);
    });

    testWidgets('the arrows step through the files', (tester) async {
      await pumpBar(tester);
      await start(tester, a);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await settle(tester);
      expect(controller.current, c);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await settle(tester);
      expect(controller.current, b);
    });

    testWidgets('do nothing while turned off', (tester) async {
      await pumpBar(tester, shortcutsEnabled: false);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await settle(tester);

      expect(controller.current, isNull);
    });

    testWidgets('do nothing while typing in a text field', (tester) async {
      await pumpBar(tester, above: const TextField());
      await tester.tap(find.byType(TextField));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await settle(tester);

      expect(controller.current, isNull);
    });

    testWidgets('do nothing with a modifier held', (tester) async {
      await pumpBar(tester);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await settle(tester);

      expect(controller.current, isNull);
    });

    testWidgets('do nothing under a dialog', (tester) async {
      await pumpBar(tester);
      final context = tester.element(find.byType(SoundPlayerBar));
      showDialog<void>(
        context: context,
        builder: (_) => const AlertDialog(content: Text('dialog')),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await settle(tester);

      expect(controller.current, isNull);
    });
  });
}
