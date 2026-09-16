@TestOn('vm')
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:localstorage/localstorage.dart';
import 'package:stelaris/api/state/app_persistor.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

import 'dart:io';

import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('stelaris_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async => tempDir.path,
        );
  });

  tearDownAll(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('AppState persistence tests', () {
    test('selectedProject is transient and NOT serialized to JSON', () {
      const project = Project(
        id: 'proj_123',
        key: 'test_key',
        displayName: 'Test Project',
        description: 'Test Description',
      );

      final state = const AppState().copyWith(selectedProject: project);

      final encoded = jsonEncode(state.toJson());
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;

      expect(decoded.containsKey('selectedProject'), isFalse);

      final restored = AppState.fromJson(decoded);
      expect(restored.selectedProject, isNull);
    });
  });

  group('AppPersistor Resilience Tests', () {
    late AppPersistor persistor;

    setUp(() async {
      await initLocalStorage();
      localStorage.clear();
      persistor = AppPersistor();
    });

    test('readState restores valid persisted state', () async {
      const state = AppState(openNavigation: false);
      await persistor.persistDifference(
        lastPersistedState: null,
        newState: state,
      );

      final loaded = await persistor.readState();
      expect(loaded.openNavigation, isFalse);
    });

    test('readState returns default AppState when localStorage contains malformed JSON', () async {
      localStorage.setItem(AppPersistor.appState, 'this is not valid json{]');

      final loaded = await persistor.readState();
      expect(loaded, const AppState());
      expect(loaded.openNavigation, isTrue);
    });

    test(
      'readState returns default AppState when JSON is not an object',
      () async {
        localStorage.setItem(AppPersistor.appState, '[1, 2, 3]');

        final loaded = await persistor.readState();
        expect(loaded, const AppState());
      },
    );

    test('readState returns default AppState on schema mismatch', () async {
      localStorage.setItem(
        AppPersistor.appState,
        '{"themeSettings": "not-a-map"}',
      );

      final loaded = await persistor.readState();
      expect(loaded, const AppState());
    });
  });
}
