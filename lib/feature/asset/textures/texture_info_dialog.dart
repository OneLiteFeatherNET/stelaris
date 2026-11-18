import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/asset/preview/texture_preview.dart';
import 'package:stelaris/feature/asset/textures/texture_detail.dart';
import 'package:stelaris/feature/asset/textures/texture_usages.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Shows one texture: a large preview, its key and origin, and where it is
/// used. A jump to a model or font closes the dialog first.
///
/// The uses may still be loading when it opens: [usages] and [usagesFailed]
/// are read again whenever [changes] notifies.
class TextureInfoDialog extends StatelessWidget {
  const TextureInfoDialog({
    required this.projectId,
    required this.texture,
    required this.changes,
    required this.usages,
    required this.usagesFailed,
    required this.onOpenModel,
    required this.onOpenFont,
    this.source,
    this.loadContent,
    super.key,
  });

  final String projectId;
  final AssetModel texture;
  final Listenable changes;
  final TextureUsages? Function() usages;
  final bool Function() usagesFailed;
  final ValueChanged<AssetModel> onOpenModel;
  final ValueChanged<FontModel> onOpenFont;

  /// The Blockbench model the texture was extracted from.
  final AssetModel? source;
  final TextureContentLoader? loadContent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    void close() => Navigator.of(context).pop();
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: dialogPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      texture.displayName,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('texture_info_close'),
                    onPressed: close,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: ListenableBuilder(
                    listenable: changes,
                    builder: (context, _) => TextureDetail(
                      projectId: projectId,
                      texture: texture,
                      usages: usages(),
                      usagesFailed: usagesFailed(),
                      source: source,
                      loadContent: loadContent,
                      onOpenModel: (model) {
                        close();
                        onOpenModel(model);
                      },
                      onOpenFont: (font) {
                        close();
                        onOpenFont(font);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
