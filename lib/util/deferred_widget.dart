import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/l10n_ext.dart';

typedef LibraryLoader = Future<void> Function();
typedef DeferredWidgetBuilder = Widget Function();

/// Asynchronously loads a Dart module chunk before building and displaying the widget.
///
/// A chunk that fails to load - a dropped connection, or a deployment that
/// replaced the chunks under an open tab - shows an error with a retry button
/// instead of calling [builder], which would throw on the missing library.
class DeferredWidget extends StatefulWidget {
  const DeferredWidget({
    required this.loader,
    required this.builder,
    this.placeholder,
    super.key,
  });

  final LibraryLoader loader;
  final DeferredWidgetBuilder builder;
  final Widget? placeholder;

  @override
  State<DeferredWidget> createState() => _DeferredWidgetState();
}

class _DeferredWidgetState extends State<DeferredWidget> {
  late Future<void> _loadingFuture;

  @override
  void initState() {
    super.initState();
    _loadingFuture = widget.loader();
  }

  // dart2js forgets a failed chunk, so calling the loader again really
  // fetches it again rather than replaying the cached failure.
  void _retry() {
    setState(() {
      _loadingFuture = widget.loader();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return widget.placeholder ??
              const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _LoadFailed(onRetry: _retry);
        }
        return widget.builder();
      },
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.deferred_load_failed,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: Text(context.l10n.deferred_load_retry),
            ),
          ],
        ),
      ),
    );
  }
}
