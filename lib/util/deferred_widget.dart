import 'package:material_ui/material_ui.dart';

typedef LibraryLoader = Future<void> Function();
typedef DeferredWidgetBuilder = Widget Function();

/// Asynchronously loads a Dart module chunk before building and displaying the widget.
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
  late final Future<void> _loadingFuture;

  @override
  void initState() {
    super.initState();
    _loadingFuture = widget.loader();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return widget.builder();
        }
        return widget.placeholder ??
            const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
      },
    );
  }
}
