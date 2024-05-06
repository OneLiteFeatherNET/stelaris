import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris_ui/api/util/navigation.dart';
import 'package:stelaris_ui/feature/attributes/attribute_page.dart';
import 'package:stelaris_ui/feature/base/base_page.dart';
import 'package:stelaris_ui/feature/font/font_page.dart';
import 'package:stelaris_ui/feature/item/item_page.dart';
import 'package:stelaris_ui/feature/notification/notification_page.dart';

final GoRouter router = GoRouter(
  initialLocation: NavigationEntry.attributes.route,
  routes: [
    GoRoute(
      path: NavigationEntry.attributes.route,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const BasePage(child: AttributePage()),
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
        child: const BasePage(child: ItemPage()),
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
        child: const BasePage(child: NotificationPage()),
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
        child: const BasePage(child: FontPage()),
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
