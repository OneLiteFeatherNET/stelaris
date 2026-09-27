import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';

/// Shows [child] only to somebody whose session grants [role].
///
/// Presentation, not enforcement: the backend decides what is permitted and
/// refuses the rest, so this only decides what is worth putting on screen. A
/// deployment with no identity provider grants everything, because there are no
/// roles to withhold and hiding every gated action would break it.
class RoleGate extends StatelessWidget {
  const RoleGate({required this.role, required this.child, this.fallback, super.key});

  final String role;
  final Widget child;

  /// What to show instead. Nothing, by default.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, bool>(
      converter: (store) => store.state.auth.hasRole(role),
      builder: (context, granted) =>
          granted ? child : (fallback ?? const SizedBox.shrink()),
    );
  }
}
