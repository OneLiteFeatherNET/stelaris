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
  /// Loaders whose library has already loaded in this session.
  ///
  /// A [FutureBuilder] reports `waiting` for its first frame even when the
  /// future has long completed, so without this every revisit of a page would
  /// flash the placeholder for one frame — right in the middle of the route
  /// transition. `prefix.loadLibrary` tear-offs compare equal, so the set
  /// recognises a library across widget instances.
  static final Set<LibraryLoader> _loaded = {};

  /// Decided once per instance: switching between the direct build and the
  /// [FutureBuilder] later would change the tree above the page and throw
  /// away its state.
  late final bool _loadedBefore = _loaded.contains(widget.loader);

  late Future<void> _loadingFuture;

  @override
  void initState() {
    super.initState();
    if (!_loadedBefore) _loadingFuture = _load();
  }

  Future<void> _load() async {
    final loader = widget.loader;
    await loader();
    _loaded.add(loader);
  }

  // dart2js forgets a failed chunk, so calling the loader again really
  // fetches it again rather than replaying the cached failure.
  void _retry() {
    setState(() {
      _loadingFuture = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadedBefore) return widget.builder();
    return FutureBuilder<void>(
      future: _loadingFuture,
      builder: (context, snapshot) {
        final Widget content;
        if (snapshot.connectionState != ConnectionState.done) {
          content =
              widget.placeholder ??
              const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          content = _LoadFailed(onRetry: _retry);
        } else {
          content = widget.builder();
        }
        // A first load finishes after the route transition has settled, so
        // fade the page in instead of letting it pop in over the spinner.
        return AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : Durations.short4,
          // The default layout centres its children with loose constraints;
          // the page has to get the parent's constraints unchanged, just as a
          // direct build would.
          layoutBuilder: (current, previous) => Stack(
            fit: StackFit.passthrough,
            children: [...previous, ?current],
          ),
          child: KeyedSubtree(
            key: ValueKey(
              snapshot.connectionState == ConnectionState.done
                  ? (snapshot.hasError ? 'failed' : 'loaded')
                  : 'loading',
            ),
            child: content,
          ),
        );
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
