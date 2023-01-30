import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris_ui/api/util/navigation.dart';
import 'package:stelaris_ui/feature/base/base_page.dart';
import 'package:stelaris_ui/feature/block/block_page.dart';
import 'package:stelaris_ui/feature/build/build_page.dart';
import 'package:stelaris_ui/feature/font/font_page.dart';
import 'package:stelaris_ui/feature/item/item_page.dart';
import 'package:stelaris_ui/feature/notification/notification_page.dart';

final GoRouter router = GoRouter(routes: [
  GoRoute(
    path: '/',
    builder: (BuildContext context, GoRouterState state) {
      return const BasePage(child: NotificationPage());
    },
  ),
  GoRoute(
    path: NavigationEntry.items.route,
    pageBuilder: (context, state) => CustomTransitionPage(
        child: const BasePage(child: ItemPage()),
        key: state.pageKey,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation,
              child: child,
            )),
  ),
  /*GoRoute(
    path: NavigationEntry.blocks.route,
    pageBuilder: (context, state) => CustomTransitionPage(
        child: const BasePage(child: BlockPage()),
        key: state.pageKey,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation,
              child: child,
            )),
  ),*/
  GoRoute(
    path: NavigationEntry.notifications.route,
    pageBuilder: (context, state) => CustomTransitionPage(
        child:  const BasePage(child: NotificationPage()),
        key: state.pageKey,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation,
              child: child,
            )
    ),
  ),
  GoRoute(
    path: NavigationEntry.font.route,
    pageBuilder: (context, state) => CustomTransitionPage(
        child: const BasePage(child: FontPage()),
        key: state.pageKey,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation,
              child: child,
            )),
  ),
  /*GoRoute(
    path: NavigationEntry.plugins.route,
    pageBuilder: (context, state) => CustomTransitionPage(
        child:  const BasePage(child: PluginPage()),
        key: state.pageKey,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation,
              child: child,
            )),
  )*/
  GoRoute(
    path: NavigationEntry.build.route,
    pageBuilder: (context, state) => CustomTransitionPage(
        child: const BasePage(child: BuildPage()),
        key: state.pageKey,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation,
              child: child,
            )),
  ),
]);
