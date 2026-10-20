import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/chips/info_chip.dart';

/// The primary content of a model card on a `ModelPage`: the model's [name]
/// plus its namespaced key (e.g. `manis:test`), derived client-side from
/// [projectKey] and the model's local [modelKey]. Without a key only the
/// name is shown.
class ModelCardContent extends StatelessWidget {
  const ModelCardContent({
    required this.name,
    required this.modelKey,
    required this.projectKey,
    super.key,
  });

  final String name;
  final String? modelKey;
  final String projectKey;

  @override
  Widget build(BuildContext context) {
    final key = modelKey;
    final namespacedKey = key != null && key.isNotEmpty
        ? '$projectKey:$key'
        : null;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (namespacedKey != null) ...[
          const SizedBox(height: 6),
          InfoChip(icon: Icons.vpn_key_outlined, text: namespacedKey),
        ],
      ],
    );
  }
}
