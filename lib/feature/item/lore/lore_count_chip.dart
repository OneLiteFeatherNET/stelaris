import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';

class LoreCountChip extends StatelessWidget {
  final int currentIndex;

  const LoreCountChip({required this.currentIndex, super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.l10n.tooltip_line_count,
      child: Chip(
        label: Text('$currentIndex / $maxLoreLines'),
        avatar: const Icon(Icons.numbers_outlined),
      ),
    );
  }
}
