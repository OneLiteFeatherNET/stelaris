import 'package:material_ui/material_ui.dart';

/// The [TabBar] used by every [ModelDetailShell] body that has sub-sections
/// (e.g. fonts, items, sound events).
///
/// Inset by the same 16px as the [ModelDetailShell]'s back bar and the tab
/// pages' own content, instead of running edge to edge.
class ModelDetailTabBar extends StatelessWidget {
  const ModelDetailTabBar({required this.tabs, super.key});

  final List<Widget> tabs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(tabs: tabs),
    );
  }
}
