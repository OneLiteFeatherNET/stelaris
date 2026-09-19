import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// A back-navigation header for a [ModelPage] detail view.
///
/// Renders an arrow-back button that returns to [parentRoute], with an
/// optional [title] shown next to it. Detail pages reached by tapping a
/// [ModelPage] grid card have no dedicated route parameter to derive a
/// "back" target from, so callers pass [parentRoute] explicitly.
class ModelDetailBackBar extends StatelessWidget {
  const ModelDetailBackBar({
    required this.parentRoute,
    this.title,
    super.key,
  });

  final String parentRoute;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    return Row(
      children: [
        IconButton(
          key: const Key('model_detail_back_button'),
          tooltip: context.l10n.button_back,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(parentRoute),
        ),
        if (title != null) ...[
          const SizedBox(width: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
