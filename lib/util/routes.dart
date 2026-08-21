import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/base/base_page.dart';
import 'package:stelaris/feature/project/project_selection_page.dart';
import 'package:stelaris/util/deferred_widget.dart';

import 'package:stelaris/feature/attributes/attribute_page.dart'
    deferred as attribute_page;
import 'package:stelaris/feature/font/font_page.dart' deferred as font_page;
import 'package:stelaris/feature/item/item_page.dart' deferred as item_page;
import 'package:stelaris/feature/notification/notification_page.dart'
    deferred as notification_page;
import 'package:stelaris/feature/sound/sound_page.dart' deferred as sound_page;

const String projectSelectionRoute = '/projects';

final GoRouter router = GoRouter(
  initialLocation: projectSelectionRoute,
  routes: [
    GoRoute(
      path: projectSelectionRoute,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const ProjectSelectionPage(),
        key: state.pageKey,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    ),
    GoRoute(
      path: NavigationEntry.attributes.route,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: BasePage(
          child: DeferredWidget(
            loader: attribute_page.loadLibrary,
            builder: () => attribute_page.AttributePage(),
          ),
        ),
        key: state.pageKey,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    ),
    GoRoute(
      path: NavigationEntry.items.route,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: BasePage(
          child: DeferredWidget(
            loader: item_page.loadLibrary,
            builder: () => item_page.ItemPage(),
          ),
        ),
        key: state.pageKey,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    ),
    GoRoute(
      path: NavigationEntry.notifications.route,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: BasePage(
          child: DeferredWidget(
            loader: notification_page.loadLibrary,
            builder: () => notification_page.NotificationPage(),
          ),
        ),
        key: state.pageKey,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    ),
    GoRoute(
      path: NavigationEntry.font.route,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: BasePage(
          child: DeferredWidget(
            loader: font_page.loadLibrary,
            builder: () => font_page.FontPage(),
          ),
        ),
        key: state.pageKey,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    ),
    GoRoute(
      path: NavigationEntry.sound.route,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: BasePage(
          child: DeferredWidget(
            loader: sound_page.loadLibrary,
            builder: () => sound_page.SoundPage(),
          ),
        ),
        key: state.pageKey,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    ),
  ],
);
