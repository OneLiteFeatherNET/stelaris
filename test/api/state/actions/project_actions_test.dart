import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/state/actions/project/project_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  group('SelectProjectAction', () {
    test('updates selectedProject and clears all entity caches and selections', () {
      const projectA = Project(
        id: 'proj-a',
        displayName: 'Project A',
        key: 'PROJ_A',
      );
      const projectB = Project(
        id: 'proj-b',
        displayName: 'Project B',
        key: 'PROJ_B',
      );

      const existingItem = ItemModel(uiName: 'Item 1', id: 'i1', projectId: 'proj-a');
      const existingFont = FontModel(uiName: 'Font 1', id: 'f1', projectId: 'proj-a');
      const existingNotification = NotificationModel(uiName: 'Notif 1', id: 'n1', projectId: 'proj-a');
      const existingAttribute = AttributeModel(uiName: 'Attr 1', id: 'a1', projectId: 'proj-a');
      final existingSound = SoundEventModel(uiName: 'Sound 1', id: 's1', projectId: 'proj-a');

      final store = Store<AppState>(
        initialState: AppState(
          projects: const [projectA, projectB],
          selectedProject: projectA,
          items: const PaginatedResult<ItemModel>(
            items: [existingItem],
            totalItems: 1,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
          fonts: const PaginatedResult<FontModel>(
            items: [existingFont],
            totalItems: 1,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
          notifications: const PaginatedResult<NotificationModel>(
            items: [existingNotification],
            totalItems: 1,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
          attributes: const PaginatedResult<AttributeModel>(
            items: [existingAttribute],
            totalItems: 1,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
          soundEvents: PaginatedResult<SoundEventModel>(
            items: [existingSound],
            totalItems: 1,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
          selectedItem: existingItem,
          selectedFont: existingFont,
          selectedNotification: existingNotification,
          selectedAttribute: existingAttribute,
          selectedSoundEvent: existingSound,
        ),
      );

      store.dispatchSync(SelectProjectAction(projectB));

      expect(store.state.selectedProject, projectB);
      expect(store.state.items.items, isEmpty);
      expect(store.state.fonts.items, isEmpty);
      expect(store.state.notifications.items, isEmpty);
      expect(store.state.attributes.items, isEmpty);
      expect(store.state.soundEvents.items, isEmpty);
      expect(store.state.selectedItem, isNull);
      expect(store.state.selectedFont, isNull);
      expect(store.state.selectedNotification, isNull);
      expect(store.state.selectedAttribute, isNull);
      expect(store.state.selectedSoundEvent, isNull);
    });
  });
}
