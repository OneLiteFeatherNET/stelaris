import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/asset/asset_kind_label.dart';
import 'package:stelaris/feature/asset/picker/asset_key.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/feature/asset/preview/texture_preview.dart';
import 'package:stelaris/feature/asset/upload/asset_file_drop_target.dart';
import 'package:stelaris/feature/asset/upload/asset_upload_controller.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Shows the upload of [controller]: a drop zone until a file is chosen,
/// then the file with its kind and size, a texture as it looks, the name it
/// is shown by and the key it is stored under. A new version of an asset
/// keeps its name and key, so it shows neither.
///
/// A file dropped on the page while the form is shown replaces the chosen
/// one. Enter in the name or key field calls [onSubmitted] when the upload
/// can start.
class AssetUploadForm extends StatefulWidget {
  const AssetUploadForm({
    required this.controller,
    this.onSubmitted,
    this.currentPreview,
    super.key,
  });

  final AssetUploadController controller;
  final VoidCallback? onSubmitted;

  /// The texture as it is now. When set, a new version of a texture is shown
  /// beside it, so the two can be compared before the upload.
  final Widget? currentPreview;

  @override
  State<AssetUploadForm> createState() => _AssetUploadFormState();
}

class _AssetUploadFormState extends State<AssetUploadForm> {
  final FocusNode _nameFocus = FocusNode();
  PickedAssetFile? _shownFile;

  @override
  void initState() {
    super.initState();
    _shownFile = widget.controller.file;
    widget.controller.addListener(_focusNameOfNewFile);
  }

  @override
  void didUpdateWidget(AssetUploadForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_focusNameOfNewFile);
      widget.controller.addListener(_focusNameOfNewFile);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_focusNameOfNewFile);
    _nameFocus.dispose();
    super.dispose();
  }

  /// A new file comes with a suggested name and key, which is what the user
  /// checks next, the name first.
  void _focusNameOfNewFile() {
    final file = widget.controller.file;
    if (identical(file, _shownFile)) return;
    _shownFile = file;
    if (file != null && widget.controller.replaces == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _nameFocus.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => AssetFileDropTarget(
        enabled: !controller.uploading,
        onDrop: controller.drop,
        builder: (context, dragging) {
          final file = controller.file;
          final replaces = controller.replaces;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (replaces != null) ...[
                Text(context.l10n.asset_upload_replace_hint(replaces.key)),
                const SizedBox(height: 16),
              ],
              if (file == null)
                _DropZone(
                  formats: _formats(context.l10n, controller.kinds),
                  dragging: dragging,
                  reading: controller.reading,
                  onChoose: controller.choose,
                )
              else ...[
                _FileCard(
                  file: file,
                  kind: controller.fileKind,
                  dragging: dragging,
                  enabled: !controller.uploading && !controller.reading,
                  onChange: controller.choose,
                  onRemove: controller.clear,
                ),
                if (controller.fileKind == AssetKind.TEXTURE) ...[
                  const SizedBox(height: 16),
                  if (widget.currentPreview case final current?)
                    _Comparison(
                      current: current,
                      next: TexturePreview.bytes(
                        file.bytes,
                        key: ObjectKey(file),
                      ),
                    )
                  else
                    TexturePreview.bytes(file.bytes, key: ObjectKey(file)),
                ],
                if (replaces == null) ...[
                  const SizedBox(height: 16),
                  _buildNameField(context),
                  const SizedBox(height: 16),
                  _buildKeyField(context),
                ],
              ],
              if (_fileProblem(context) case final problem?) ...[
                const SizedBox(height: 8),
                _ErrorText(problem),
              ],
              if (replaces != null && controller.conflict) ...[
                const SizedBox(height: 8),
                _ErrorText(
                  context.l10n.asset_upload_replace_conflict(
                    replaces.displayName,
                  ),
                ),
              ],
              if (controller.uploadError case final error?) ...[
                const SizedBox(height: 8),
                _ErrorText(error),
              ],
              if (controller.uploading) ...[
                const SizedBox(height: 16),
                _UploadProgress(
                  progress: controller.progress,
                  onCancel: controller.cancelUpload,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildNameField(BuildContext context) {
    final l10n = context.l10n;
    final controller = widget.controller;
    return TextField(
      key: const Key('asset_upload_name'),
      controller: controller.nameController,
      focusNode: _nameFocus,
      enabled: !controller.uploading,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: l10n.asset_upload_name,
        helperText: l10n.asset_upload_name_helper,
        errorText:
            controller.nameError ??
            (controller.nameMissing ? l10n.asset_upload_name_empty : null),
        errorMaxLines: 3,
      ),
      onSubmitted: (_) {
        if (controller.canUpload) widget.onSubmitted?.call();
      },
    );
  }

  Widget _buildKeyField(BuildContext context) {
    final l10n = context.l10n;
    final controller = widget.controller;
    final namespace = controller.keyNamespace;
    return TextField(
      key: const Key('asset_upload_key'),
      controller: controller.keyController,
      enabled: !controller.uploading,
      readOnly: controller.fixedKey != null,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: l10n.asset_picker_key,
        helperText: controller.fixedKey != null
            ? l10n.asset_upload_key_fixed
            : l10n.asset_upload_key_helper('${controller.keyFolder}/ruby'),
        prefixText: controller.fixedKey == null ? '$namespace:' : null,
        suffixIcon: controller.fixedKey != null
            ? const Icon(Icons.lock_outline, size: 18)
            : null,
        errorText:
            controller.keyError ??
            switch (controller.keyProblem) {
              final problem? => _keyProblemText(l10n, problem, namespace),
              null => null,
            },
        errorMaxLines: 3,
      ),
      onSubmitted: (_) {
        if (controller.canUpload) widget.onSubmitted?.call();
      },
    );
  }

  String? _fileProblem(BuildContext context) {
    final l10n = context.l10n;
    final controller = widget.controller;
    if (controller.readFailed) return l10n.asset_upload_read_failed;
    if (controller.tooLarge case final file?) {
      return l10n.asset_upload_too_large(
        file.name,
        formatFileSize(file.size),
        formatFileSize(maxAssetFileBytes),
      );
    }
    if (controller.file != null && controller.fileKind == null) {
      return _unsupported(l10n, controller.kinds);
    }
    return controller.fileError;
  }

  static const _texture = {AssetKind.TEXTURE};
  static const _models = {AssetKind.MODEL, AssetKind.BBMODEL};
  static const _sound = {AssetKind.SOUND};

  /// The file types [kinds] take, as the drop zone names them.
  static String _formats(AppLocalizations l10n, Set<AssetKind> kinds) {
    if (setEquals(kinds, _texture)) return l10n.asset_upload_formats_texture;
    if (setEquals(kinds, _models)) return l10n.asset_upload_formats_models;
    if (setEquals(kinds, _sound)) return l10n.asset_upload_formats_sound;
    return l10n.asset_upload_formats;
  }

  /// Why a file of another kind than [kinds] can't be uploaded.
  static String _unsupported(AppLocalizations l10n, Set<AssetKind> kinds) {
    if (setEquals(kinds, _texture)) {
      return l10n.asset_upload_unsupported_texture;
    }
    if (setEquals(kinds, _models)) return l10n.asset_upload_unsupported_models;
    if (setEquals(kinds, _sound)) return l10n.asset_upload_unsupported_sound;
    return l10n.asset_upload_unsupported_file;
  }

  static String _keyProblemText(
    AppLocalizations l10n,
    AssetKeyProblem problem,
    String namespace,
  ) => switch (problem) {
    AssetKeyProblem.empty => l10n.asset_upload_key_empty,
    AssetKeyProblem.missingNamespace => l10n.asset_upload_key_no_namespace(
      namespace,
    ),
    AssetKeyProblem.invalidNamespace => l10n.asset_upload_key_bad_namespace,
    AssetKeyProblem.invalidPath => l10n.asset_upload_key_bad_path,
  };
}

/// Asks for a file: dropped on the page or chosen in the file dialog, which
/// a click anywhere on the zone opens, like Enter or Space when it has focus.
class _DropZone extends StatelessWidget {
  const _DropZone({
    required this.formats,
    required this.dragging,
    required this.reading,
    required this.onChoose,
  });

  /// The file types the upload takes.
  final String formats;
  final bool dragging;
  final bool reading;
  final VoidCallback onChoose;

  /// Stands in for the browse link while the sentence around it is split.
  static const _browseMarker = '\u{E000}';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final radius = BorderRadius.circular(AppShapes.medium);
    final [before, after] = l10n
        .asset_upload_drop(_browseMarker)
        .split(_browseMarker);
    return Semantics(
      button: true,
      enabled: !reading,
      label: '${l10n.asset_upload_drop(l10n.asset_upload_browse)}, $formats',
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          key: const Key('asset_upload_drop_zone'),
          borderRadius: radius,
          onTap: reading ? null : onChoose,
          child: CustomPaint(
            painter: _DashedBorderPainter(
              color: dragging || reading
                  ? colorScheme.primary
                  : colorScheme.outline,
              width: dragging ? 2 : 1,
              radius: AppShapes.medium,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              decoration: BoxDecoration(
                color: dragging
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerLow,
                borderRadius: radius,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox.square(
                    dimension: 36,
                    child: reading
                        ? const Padding(
                            padding: EdgeInsets.all(6),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.upload_file,
                            size: 36,
                            color: dragging
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurfaceVariant,
                          ),
                  ),
                  const SizedBox(height: 12),
                  if (dragging)
                    Text(
                      l10n.asset_upload_drop_now,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    )
                  else
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: before),
                          TextSpan(
                            text: l10n.asset_upload_browse,
                            style: TextStyle(
                              color: colorScheme.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: colorScheme.primary,
                            ),
                          ),
                          TextSpan(text: after),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    formats,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A dashed rounded border, which marks a place to drop a file on.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.width,
    required this.radius,
  });

  final Color color;
  final double width;
  final double radius;

  static const double _dash = 6;
  static const double _gap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = width / 2;
    final border = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(inset),
          Radius.circular(radius - inset),
        ),
      );
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;
    for (final metric in border.computeMetrics()) {
      for (var start = 0.0; start < metric.length; start += _dash + _gap) {
        canvas.drawPath(metric.extractPath(start, start + _dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color ||
      width != oldDelegate.width ||
      radius != oldDelegate.radius;
}

/// The texture as it is now beside the chosen new version.
class _Comparison extends StatelessWidget {
  const _Comparison({required this.current, required this.next});

  final Widget current;
  final Widget next;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      key: const Key('asset_upload_compare'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _labelled(context, l10n.asset_upload_now, current)),
        const Padding(
          padding: EdgeInsets.fromLTRB(12, 48, 12, 0),
          child: Icon(Icons.arrow_forward),
        ),
        Expanded(child: _labelled(context, l10n.asset_upload_new, next)),
      ],
    );
  }

  Widget _labelled(BuildContext context, String label, Widget child) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

/// The chosen file with its kind and size, to change or remove it.
class _FileCard extends StatelessWidget {
  const _FileCard({
    required this.file,
    required this.kind,
    required this.dragging,
    required this.enabled,
    required this.onChange,
    required this.onRemove,
  });

  final PickedAssetFile file;

  /// What the file is stored as, null when it can't be uploaded.
  final AssetKind? kind;

  /// Whether a file is dragged over the page, which would replace this one.
  final bool dragging;
  final bool enabled;
  final VoidCallback onChange;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final kind = this.kind;
    final size = formatFileSize(file.bytes.length);
    return AnimatedContainer(
      key: const Key('asset_upload_file'),
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: dragging ? colorScheme.primaryContainer : null,
        borderRadius: BorderRadius.circular(AppShapes.medium),
        border: Border.all(
          color: dragging ? colorScheme.primary : colorScheme.outlineVariant,
          width: dragging ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            kind == null ? Icons.block : assetKindIcon(kind),
            color: kind == null
                ? colorScheme.error
                : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  kind == null
                      ? size
                      : l10n.asset_upload_file_details(
                          assetKindLabel(l10n, kind),
                          size,
                        ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.asset_upload_change,
            icon: const Icon(Icons.swap_horiz),
            onPressed: enabled ? onChange : null,
          ),
          IconButton(
            tooltip: l10n.asset_upload_remove,
            icon: const Icon(Icons.close),
            onPressed: enabled ? onRemove : null,
          ),
        ],
      ),
    );
  }
}

/// How much of the file went up, with a button to stop the upload. Before
/// the first bytes are sent the bar runs without a value.
class _UploadProgress extends StatelessWidget {
  const _UploadProgress({required this.progress, required this.onCancel});

  final double? progress;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final progress = this.progress;
    return Row(
      key: const Key('asset_upload_progress'),
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 4),
              Text(
                progress == null
                    ? l10n.asset_upload_starting
                    : l10n.asset_upload_progress((progress * 100).floor()),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        TextButton(onPressed: onCancel, child: Text(l10n.asset_upload_cancel)),
      ],
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.error,
      ),
    );
  }
}

/// [bytes] in B, KB or MB, with one decimal from KB on.
String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kilobytes = bytes / 1024;
  if (kilobytes < 1024) return '${kilobytes.toStringAsFixed(1)} KB';
  return '${(kilobytes / 1024).toStringAsFixed(1)} MB';
}
