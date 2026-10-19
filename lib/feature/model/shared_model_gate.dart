import 'package:async_redux/async_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/feature/model/detail_tabs.dart';
import 'package:stelaris/util/dispatch_ext.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Opens the model a shared link points to before showing its detail page.
///
/// Without a [ref], or when the model is open already, [child] shows right
/// away. Otherwise [open] is dispatched once and a spinner shows until the
/// model is selected; when that fails the person is sent back to [listRoute]
/// with a notice, since the link points to something gone or out of reach.
class SharedModelGate extends StatefulWidget {
  const SharedModelGate({
    required this.ref,
    required this.open,
    required this.isOpen,
    required this.listRoute,
    required this.child,
    super.key,
  });

  final SharedModelRef? ref;
  final ReduxAction<AppState> Function(String projectId, String id) open;
  final bool Function(AppState state, String id) isOpen;
  final String listRoute;
  final Widget child;

  @override
  State<SharedModelGate> createState() => _SharedModelGateState();
}

class _SharedModelGateState extends State<SharedModelGate> {
  @override
  void initState() {
    super.initState();
    final SharedModelRef? ref = widget.ref;
    if (ref == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _open(ref));
  }

  Future<void> _open(SharedModelRef ref) async {
    if (!mounted) return;
    if (widget.isOpen(StoreProvider.state<AppState>(context), ref.id)) return;
    final outcome = await context.dispatchAndCatch(
      widget.open(ref.projectId, ref.id),
    );
    if (!mounted || outcome.ok) return;
    context.showWarningSnackBar(context.l10n.snackbar_shared_model_not_found);
    context.go(widget.listRoute);
  }

  @override
  Widget build(BuildContext context) {
    final SharedModelRef? ref = widget.ref;
    if (ref == null) return widget.child;
    return StoreConnector<AppState, bool>(
      converter: (store) => widget.isOpen(store.state, ref.id),
      builder: (context, isOpen) => isOpen
          ? widget.child
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
