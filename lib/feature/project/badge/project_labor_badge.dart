import 'package:material_ui/material_ui.dart';

class ProjectLaborBadge extends StatelessWidget {
  final double fontSize;

  const ProjectLaborBadge({
    super.key,
    this.fontSize = 9,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Labor',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: colorScheme.onTertiaryContainer,
        ),
      ),
    );
  }
}
