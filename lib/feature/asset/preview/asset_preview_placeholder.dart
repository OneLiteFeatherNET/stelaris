import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Stands in for the 3D viewer where it cannot run: names the asset and says why.
class AssetPreviewPlaceholder extends StatelessWidget {
  const AssetPreviewPlaceholder({required this.assetKey, super.key});

  final String assetKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.view_in_ar, size: 48, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(height: 8),
              Text(assetKey, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(
                context.l10n.asset_preview_unavailable,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
