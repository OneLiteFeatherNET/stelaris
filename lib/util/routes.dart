import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/auth/auth_sessions.dart';
import 'package:stelaris/auth/auth_state.dart';
import 'package:stelaris/feature/auth/sign_in_page.dart';
import 'package:stelaris/feature/base/base_page.dart';
import 'package:stelaris/feature/base/unsaved/unsaved_changes_guard.dart';
import 'package:stelaris/feature/font/font_detail_page.dart';
import 'package:stelaris/feature/item/item_detail_page.dart';
import 'package:stelaris/feature/notification/notification_detail_page.dart';
import 'package:stelaris/feature/project/project_selection_page.dart';
import 'package:stelaris/feature/sound/sound_detail_page.dart';
import 'package:stelaris/util/deferred_widget.dart';

import 'package:stelaris/feature/attributes/attribute_page.dart'
    deferred as attribute_page;
import 'package:stelaris/feature/font/font_page.dart' deferred as font_page;
import 'package:stelaris/feature/item/item_page.dart' deferred as item_page;
import 'package:stelaris/feature/notification/notification_page.dart'
    deferred as notification_page;
import 'package:stelaris/feature/sound/sound_page.dart' deferred as sound_page;

const String projectSelectionRoute = '/projects';

/// Where an unauthenticated visitor is sent, and the one route the guard below
/// lets through - otherwise signing in would redirect to itself.
const String signInRoute = '/sign-in';

/// Carries the route somebody asked for, so signing in can put them back there
/// instead of on a default page.
const String signInFromParameter = 'from';

/// Sends anyone without a session to [signInRoute], remembering where they were
/// headed.
///
/// Returns null - meaning "no opinion" - in exactly two cases: a deployment
/// that configured no identity provider, where the feature is switched off
/// entirely, and somebody who is already signed in.
///
/// Everything else is sent to [signInRoute], a provider that could not be
/// reached included. That page explains an unreachable provider and offers to
/// retry; letting people through instead would turn a broken provider into a
/// deployment with no authentication at all, which is the one outcome this
/// must never produce.
///
/// This runs ahead of [projectSelectionRedirect]. Order matters: bouncing an
/// unauthenticated visitor to the project list first would throw away the route
/// they actually asked for, which is the one thing they should get back after
/// signing in.
String? authRedirect(BuildContext context, GoRouterState state) {
  final AuthState? auth = AuthSessions.current?.state;
  if (auth == null || !auth.isEnabled || auth.isSignedIn) {
    return null;
  }
  if (state.matchedLocation == signInRoute) {
    return null;
  }
  return Uri(
    path: signInRoute,
    queryParameters: <String, String>{
      signInFromParameter: state.matchedLocation,
    },
  ).toString();
}

/// The two guards, in the order they have to run.
///
/// go_router takes one top-level redirect, so they are composed rather than
/// listed. Authentication first: see [authRedirect].
///
/// [signInRoute] then leaves before the project guard sees it. It has to:
/// signing in happens before a project is chosen, so the project guard would
/// send the visitor to the project list, which the auth guard would send back
/// to sign-in, and go_router would give up on the loop with a blank page.
String? appRedirect(BuildContext context, GoRouterState state) {
  final String? toSignIn = authRedirect(context, state);
  if (toSignIn != null) {
    return toSignIn;
  }
  if (state.matchedLocation == signInRoute) {
    return null;
  }
  return projectSelectionRedirect(context, state);
}

/// Redirects to [projectSelectionRoute] whenever no project is selected.
///
/// Extracted as a standalone function so it can be exercised against an
/// isolated [GoRouter] in tests instead of the app's singleton [router].
String? projectSelectionRedirect(BuildContext context, GoRouterState state) {
  try {
    final appState = StoreProvider.state<AppState>(context);
    final hasProject = appState.selectedProject != null;
    final isAtProjects = state.matchedLocation == projectSelectionRoute;

    if (!hasProject && !isAtProjects) {
      return projectSelectionRoute;
    }
  } on StoreException catch (_) {}
  return null;
}

/// Redirects `/notifications/detail` back to `/notifications` when nothing
/// is selected — reachable by a direct URL visit or a page reload, since the
/// detail route relies entirely on the already-dispatched Redux selection
/// rather than a route parameter.
String? notificationDetailRedirect(BuildContext context, GoRouterState state) {
  try {
    final appState = StoreProvider.state<AppState>(context);
    final isAtNotificationDetail = state.matchedLocation ==
        '${NavigationEntry.notifications.route}/detail';

    if (isAtNotificationDetail && appState.selectedNotification == null) {
      return NavigationEntry.notifications.route;
    }
  } on StoreException catch (_) {}
  return null;
}

/// Redirects `/fonts/detail` back to `/fonts` when nothing is selected —
/// reachable by a direct URL visit or a page reload, since the detail route
/// relies entirely on the already-dispatched Redux selection rather than a
/// route parameter.
String? fontDetailRedirect(BuildContext context, GoRouterState state) {
  try {
    final appState = StoreProvider.state<AppState>(context);
    final isAtFontDetail =
        state.matchedLocation == '${NavigationEntry.font.route}/detail';

    if (isAtFontDetail && appState.selectedFont == null) {
      return NavigationEntry.font.route;
    }
  } on StoreException catch (_) {}
  return null;
}

/// Redirects `/sound/detail` back to `/sound` when nothing is selected —
/// reachable by a direct URL visit or a page reload, since the detail route
/// relies entirely on the already-dispatched Redux selection rather than a
/// route parameter.
String? soundDetailRedirect(BuildContext context, GoRouterState state) {
  try {
    final appState = StoreProvider.state<AppState>(context);
    final isAtSoundDetail =
        state.matchedLocation == '${NavigationEntry.sound.route}/detail';

    if (isAtSoundDetail && appState.selectedSoundEvent == null) {
      return NavigationEntry.sound.route;
    }
  } on StoreException catch (_) {}
  return null;
}

/// Redirects `/items/detail` back to `/items` when nothing is selected —
/// reachable by a direct URL visit or a page reload, since the detail route
/// relies entirely on the already-dispatched Redux selection rather than a
/// route parameter.
String? itemDetailRedirect(BuildContext context, GoRouterState state) {
  try {
    final appState = StoreProvider.state<AppState>(context);
    final isAtItemDetail =
        state.matchedLocation == '${NavigationEntry.items.route}/detail';

    if (isAtItemDetail && appState.selectedItem == null) {
      return NavigationEntry.items.route;
    }
  } on StoreException catch (_) {}
  return null;
}

/// The transition used when navigating from a model grid page to its
/// detail route and back: the detail page slides in from the right (and
/// back out on pop) with a matching fade, while the grid underneath stays
/// put — a drill-down feel distinct from the plain cross-fade used between
/// top-level nav tabs.
Widget buildDetailSlideTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final slideCurve = CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic);
  // Delayed relative to the slide: full opacity is reached only at the very
  // end, in sync with the slide settling, instead of the content looking
  // fully "arrived" while it's still visibly moving.
  final fadeCurve = CurvedAnimation(
    parent: animation,
    curve: const Interval(0.3, 1, curve: Curves.easeOut),
  );
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(slideCurve),
    child: FadeTransition(opacity: fadeCurve, child: child),
  );
}

/// Re-runs the guards whenever the session changes.
///
/// Without this a session that expires while the app is open would leave the
/// person on a page they can no longer use: go_router only consults its
/// redirect on a navigation, and nothing navigates when a token quietly runs
/// out.
class AuthRouterRefresh extends ChangeNotifier {
  AuthRouterRefresh() {
    _changes = AuthSessions.current?.states.listen((_) => notifyListeners());
  }

  StreamSubscription<AuthState>? _changes;

  @override
  void dispose() {
    _changes?.cancel();
    super.dispose();
  }
}

final GoRouter router = GoRouter(
  initialLocation: projectSelectionRoute,
  redirect: appRedirect,
  refreshListenable: AuthRouterRefresh(),
  routes: [
    GoRoute(
      path: signInRoute,
      builder: (context, state) => SignInPage(
        returnTo: state.uri.queryParameters[signInFromParameter],
      ),
    ),
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
    ShellRoute(
      builder: (context, state, child) => BasePage(child: child),
      routes: [
        GoRoute(
          path: NavigationEntry.attributes.route,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: DeferredWidget(
              loader: attribute_page.loadLibrary,
              builder: () => attribute_page.AttributePage(),
            ),
            key: state.pageKey,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
        ),
        GoRoute(
          path: NavigationEntry.items.route,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: DeferredWidget(
              loader: item_page.loadLibrary,
              builder: () => item_page.ItemPage(),
            ),
            key: state.pageKey,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
          routes: [
            GoRoute(
              path: 'detail',
              redirect: itemDetailRedirect,
              onExit: detailExitGuard,
              pageBuilder: (context, state) => CustomTransitionPage(
                child: const ItemDetailPage(),
                key: state.pageKey,
                transitionsBuilder: buildDetailSlideTransition,
              ),
            ),
          ],
        ),
        GoRoute(
          path: NavigationEntry.notifications.route,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: DeferredWidget(
              loader: notification_page.loadLibrary,
              builder: () => notification_page.NotificationPage(),
            ),
            key: state.pageKey,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
          routes: [
            GoRoute(
              path: 'detail',
              redirect: notificationDetailRedirect,
              onExit: detailExitGuard,
              pageBuilder: (context, state) => CustomTransitionPage(
                child: const NotificationDetailPage(),
                key: state.pageKey,
                transitionsBuilder: buildDetailSlideTransition,
              ),
            ),
          ],
        ),
        GoRoute(
          path: NavigationEntry.font.route,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: DeferredWidget(
              loader: font_page.loadLibrary,
              builder: () => font_page.FontPage(),
            ),
            key: state.pageKey,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
          routes: [
            GoRoute(
              path: 'detail',
              redirect: fontDetailRedirect,
              onExit: detailExitGuard,
              pageBuilder: (context, state) => CustomTransitionPage(
                child: const FontDetailPage(),
                key: state.pageKey,
                transitionsBuilder: buildDetailSlideTransition,
              ),
            ),
          ],
        ),
        GoRoute(
          path: NavigationEntry.sound.route,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: DeferredWidget(
              loader: sound_page.loadLibrary,
              builder: () => sound_page.SoundPage(),
            ),
            key: state.pageKey,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
          routes: [
            GoRoute(
              path: 'detail',
              redirect: soundDetailRedirect,
              onExit: detailExitGuard,
              pageBuilder: (context, state) => CustomTransitionPage(
                child: const SoundDetailPage(),
                key: state.pageKey,
                transitionsBuilder: buildDetailSlideTransition,
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
