import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/command_palette/delete_specs.dart';
import 'package:stelaris/feature/font/font_detail_page.dart';
import 'package:stelaris/feature/item/item_detail_page.dart';
import 'package:stelaris/feature/model/model_detail_actions.dart';
import 'package:stelaris/feature/notification/notification_detail_page.dart';
import 'package:stelaris/feature/sound/sound_detail_page.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Renders [page] as its detail route does and returns the delete title and
/// warning it hands to its header's [ModelDetailActions].
Future<(String, String?)> _detailPageDelete(
  WidgetTester tester,
  Widget page,
  AppState state,
) async {
  final router = GoRouter(
    initialLocation: '/detail',
    routes: [
      GoRoute(
        path: '/detail',
        builder: (_, _) => Scaffold(body: page),
      ),
    ],
  );
  await tester.pumpWidget(
    StoreProvider<AppState>(
      store: Store<AppState>(
        initialState: state,
        globalErrorObserver: (_) => SwallowGlobalErrorObserver<AppState>(),
      ),
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pump();
  final dynamic actions = tester.widget(
    find.byWidgetPredicate((widget) => widget is ModelDetailActions),
  );
  return (actions.deleteTitle as String, actions.deleteWarning as String?);
}

void main() {
  final AppLocalizations l10n = lookupAppLocalizations(const Locale('en'));

  // The palette deletes through its own table; the detail pages configure
  // their delete button inline. This keeps the two saying the same thing.
  final cases = <String, (Widget, AppState, DeleteSpec)>{
    'item': (
      const ItemDetailPage(),
      const AppState(
        selectedItem: ItemModel(uiName: 'Sword', id: 'i1'),
      ),
      itemDelete,
    ),
    'font': (
      const FontDetailPage(),
      const AppState(
        selectedFont: FontModel(uiName: 'Rune', id: 'f1'),
      ),
      fontDelete,
    ),
    'sound': (
      const SoundDetailPage(),
      AppState(
        selectedSoundEvent: SoundEventModel(uiName: 'Bang', id: 's1'),
      ),
      soundDelete,
    ),
    'notification': (
      const NotificationDetailPage(),
      const AppState(
        selectedNotification: NotificationModel(uiName: 'Done', id: 'n1'),
      ),
      notificationDelete,
    ),
  };

  for (final MapEntry(key: kind, value: (page, state, spec)) in cases.entries) {
    testWidgets('$kind: same delete title and warning as its detail page', (
      tester,
    ) async {
      final (title, warning) = await _detailPageDelete(tester, page, state);

      expect(spec.title(l10n), title);
      expect(spec.warning?.call(l10n), warning);
    });
  }
}
