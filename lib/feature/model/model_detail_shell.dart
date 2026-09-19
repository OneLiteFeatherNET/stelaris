import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/model/model_detail_back_bar.dart';

/// The shared shell for every [ModelPage] detail route: a [ModelDetailBackBar]
/// (arrow + optional model name) on its own row at the top, with [body]
/// filling the remaining space below it.
///
/// [body] is whatever the detail route actually shows — a single form for
/// models with no sub-sections (e.g. notifications), or a `TabBar`/
/// `TabBarView` for models with several (e.g. fonts, items, sound events).
/// Keeping the back row identical across both shapes is the whole point:
/// the back button always lives in the same place, regardless of what's
/// underneath it.
class ModelDetailShell extends StatelessWidget {
  const ModelDetailShell({
    required this.parentRoute,
    required this.body,
    this.title,
    super.key,
  });

  final String parentRoute;
  final String? title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: ModelDetailBackBar(parentRoute: parentRoute, title: title),
        ),
        Expanded(child: body),
      ],
    );
  }
}
