import 'dart:typed_data';

import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/service/sound/sound_file_loader.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/sound/playback/sound_decoder.dart';
import 'package:stelaris/feature/sound/playback/sound_playback_controller.dart';
import 'package:stelaris/feature/sound/playback/sound_player.dart';
import 'package:stelaris/feature/sound/playback/sound_waveform.dart';
import 'package:stelaris/feature/sound/sound_file_entries.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

class _Loader implements SoundFileLoader {
  @override
  Future<SoundFile> load(String projectId, SoundFileSource source) async =>
      SoundFile(bytes: Uint8List(0), mimeType: 'audio/ogg');
}

class _Decoder implements SoundDecoder {
  @override
  Future<SoundWaveform> waveform(SoundFile file, {int buckets = 64}) async =>
      const SoundWaveform(peaks: [1], duration: Duration(seconds: 1));
}

class _Player implements SoundPlayer {
  @override
  Duration get position => Duration.zero;

  @override
  Future<void> play(
    SoundFile file, {
    required double volume,
    required double pitch,
  }) async {}

  @override
  void stop() {}
}

void main() {
  testWidgets('switching tabs away and back keeps the loaded files', (
    tester,
  ) async {
    const click = SoundFileSource(
      id: 's-1',
      name: 'vulpes:ui/click',
      volume: 1,
      pitch: 1,
      attenuationDistance: 16,
      preload: false,
      type: 'file',
      weight: 1,
      assetId: 'a-1',
    );
    final store = Store<AppState>(
      initialState: const AppState().copyWith(
        selectedProject: const Project(
          displayName: 'P',
          id: 'proj-1',
          key: 'vulpes',
        ),
        selectedSoundEvent: SoundEventModel(
          id: 'e-1',
          uiName: 'Click',
          files: const PaginatedResult(
            items: [click],
            totalItems: 1,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
        ),
      ),
    );
    final playback = SoundPlaybackController(
      loader: _Loader(),
      player: _Player(),
      decoder: _Decoder(),
    );
    addTearDown(playback.dispose);
    var nameReads = 0;

    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: DefaultTabController(
              length: 2,
              initialIndex: 1,
              child: Column(
                children: [
                  const TabBar(tabs: [Tab(text: 'A'), Tab(text: 'B')]),
                  Expanded(
                    child: TabBarView(
                      children: [
                        const Text('general'),
                        SoundFileEntryPage(
                          playback: playback,
                          soundAssetNames: (_) async {
                            nameReads++;
                            return {'a-1': 'Click'};
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(nameReads, 1);
    expect(find.text('Click'), findsWidgets);

    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('B'));
    await tester.pump();

    // Shown at once while the tab slides in, without reading the names
    // again.
    expect(
      find.byKey(const Key('sound_file_card_loading'), skipOffstage: false),
      findsNothing,
    );
    expect(find.text('Click', skipOffstage: false), findsWidgets);
    await tester.pumpAndSettle();
    expect(nameReads, 1);
  });
}
