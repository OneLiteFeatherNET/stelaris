import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/state/actions/app_actions.dart';

class ToggleNavigationBar extends StatelessWidget {
  final bool navigationState;

  const ToggleNavigationBar({
    required this.navigationState,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () => StoreProvider.dispatch(
        context,
        UpdateNavigationAction(!navigationState),
      ),
    );
  }
}
