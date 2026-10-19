import 'package:async_redux/async_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/util/dispatch_ext.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Opens the model a detail location names before showing its detail page.
///
/// When the model is open already, [child] shows right away. Otherwise
/// [open] is dispatched once and a spinner shows until the model is
/// selected; when that fails the person is sent back to [listLocation] with
/// a notice, since the link points to something gone or out of reach.
class SharedModelGate extends StatefulWidget {
  const SharedModelGate({
    required this.projectId,
    required this.id,
    required this.open,
    required this.isOpen,
    required this.listLocation,
    required this.child,
    super.key,
  });

  final String projectId;
  final String id;
  final ReduxAction<AppState> Function(String projectId, String id) open;
  final bool Function(AppState state, String id) isOpen;
  final String listLocation;
  final Widget child;

  @override
  State<SharedModelGate> createState() => _SharedModelGateState();
}

class _SharedModelGateState extends State<SharedModelGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _open());
  }

  @override
  void didUpdateWidget(SharedModelGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId != widget.projectId || oldWidget.id != widget.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _open());
    }
  }

  Future<void> _open() async {
    if (!mounted) return;
    if (widget.isOpen(StoreProvider.state<AppState>(context), widget.id)) {
      return;
    }
    final outcome = await context.dispatchAndCatch(
      widget.open(widget.projectId, widget.id),
    );
    if (!mounted || outcome.ok) return;
    context.showWarningSnackBar(context.l10n.snackbar_shared_model_not_found);
    context.go(widget.listLocation);
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, bool>(
      converter: (store) => widget.isOpen(store.state, widget.id),
      builder: (context, isOpen) => isOpen
          ? widget.child
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
