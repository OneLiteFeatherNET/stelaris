import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
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
}
