import 'package:async_redux/async_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/base/button/build_button.dart';
import 'package:stelaris/feature/base/button/settings_button.dart';
import 'package:stelaris/feature/base/button/toggle_navigation_button.dart';
import 'package:stelaris/feature/base/stelaris_loader.dart';
import 'package:stelaris/feature/navigation/navigation_side_bar.dart';
import 'package:stelaris/feature/project/badge/project_app_bar_badge.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/routes.dart';

/// A base page layout that provides a consistent structure across the application.
///
/// This widget implements the main layout structure including:
/// - An app bar with navigation toggle, title, and action buttons
/// - A side navigation bar
/// - A main content area
/// - An end drawer for build-related functionality
class BasePage extends StatelessWidget {
  const BasePage({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, String?>(
      converter: (store) => store.state.selectedProject?.id,
      builder: (context, selectedProjectId) {
        if (selectedProjectId == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go(projectSelectionRoute);
            }
          });
          return const Scaffold(
            body: Center(child: StelarisLoader()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            leading: const ToggleNavigationBar(),
            elevation: 0,
            title: appTitle,
            centerTitle: true,
            actions: const [
              ProjectAppBarBadge(),
              horizontalSpacing10,
              BuildButton(),
              SettingsButton(),
            ],
          ),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const NavigationSideBar(),
              Expanded(
                child: KeyedSubtree(
                  key: ValueKey(selectedProjectId),
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
