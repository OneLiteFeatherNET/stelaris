import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris_ui/api/util/navigation.dart';
import 'package:stelaris_ui/feature/landing/landing_page.dart';
import 'package:stelaris_ui/feature/login/login_page.dart';

final GoRouter router = GoRouter(routes: [
  GoRoute(
    path: '/',
    builder: (BuildContext context, GoRouterState state) {
      return const LandingPage(
        child: LoginPage(),
      );
    },
  ),
  GoRoute(
    path: '/login',
    pageBuilder: (context, state) => CustomTransitionPage(
        child: const LoginPage(),
        key: state.pageKey,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation,
              child: child,
            )),
  ),
  GoRoute(
    path: NavigationEntry.items.route,
    pageBuilder: (context, state) => CustomTransitionPage(
        child: const LoginPage(),
        key: state.pageKey,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation,
              child: child,
            )),
  ),
  GoRoute(
    path: NavigationEntry.entities.route,
    pageBuilder: (context, state) => CustomTransitionPage(
        child: const LoginPage(),
        key: state.pageKey,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation,
              child: child,
            )),
  ),
  GoRoute(
    path: NavigationEntry.build.route,
    pageBuilder: (context, state) => CustomTransitionPage(
        child: const LoginPage(),
        key: state.pageKey,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation,
              child: child,
            )),
  )
]);
