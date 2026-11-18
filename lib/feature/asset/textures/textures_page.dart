import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The insets of the other list pages (see `ModelPage`).
const EdgeInsets _pagePadding = EdgeInsets.fromLTRB(16, 12, 16, 0);

/// Shows the textures of the selected project.
///
/// The selection is [selectedId]; the page reports a new one through
/// [onSelected], so the route can keep it.
class TexturesPage extends StatelessWidget {
  const TexturesPage({this.selectedId, this.onSelected, super.key});

  final String? selectedId;
  final ValueChanged<String?>? onSelected;

  @override
  Widget build(BuildContext context) => Padding(
    padding: _pagePadding,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [PageHeader(title: context.l10n.asset_textures_title)],
    ),
  );
}
