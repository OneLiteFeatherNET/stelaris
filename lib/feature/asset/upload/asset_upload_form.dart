import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/asset/asset_kind_label.dart';
import 'package:stelaris/feature/asset/picker/asset_key.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/feature/asset/upload/asset_file_drop_target.dart';
import 'package:stelaris/feature/asset/upload/asset_upload_controller.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Shows the upload of [controller]: a drop zone until a file is chosen,
/// then the file with its kind and size, the name it is shown by and the key
/// it is stored under.
///
/// A file dropped on the page while the form is shown replaces the chosen
/// one. Enter in the name or key field calls [onSubmitted] when the upload
/// can start.
class AssetUploadForm extends StatefulWidget {
  const AssetUploadForm({
    required this.controller,
    this.onSubmitted,
    super.key,
  });

  final AssetUploadController controller;
  final VoidCallback? onSubmitted;

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
    if (file != null) {
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
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                const SizedBox(height: 16),
                _buildNameField(context),
                const SizedBox(height: 16),
                _buildKeyField(context),
              ],
              if (_fileProblem(context) case final problem?) ...[
                const SizedBox(height: 8),
                _ErrorText(problem),
              ],
              if (controller.uploadError case final error?) ...[
                const SizedBox(height: 8),
                _ErrorText(error),
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
    final namespace = validNamespaceOr(controller.namespace);
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
            : l10n.asset_upload_key_helper('$namespace:item/ruby'),
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
    if (controller.file != null && controller.fileKind == null) {
      return _unsupported(l10n, controller.kinds);
    }
    return controller.fileError;
  }

  static const _texture = {AssetKind.TEXTURE};
  static const _models = {AssetKind.MODEL, AssetKind.BBMODEL};

  /// The file types [kinds] take, as the drop zone names them.
  static String _formats(AppLocalizations l10n, Set<AssetKind> kinds) {
    if (setEquals(kinds, _texture)) return l10n.asset_upload_formats_texture;
    if (setEquals(kinds, _models)) return l10n.asset_upload_formats_models;
    return l10n.asset_upload_formats;
  }

  /// Why a file of another kind than [kinds] can't be uploaded.
  static String _unsupported(AppLocalizations l10n, Set<AssetKind> kinds) {
    if (setEquals(kinds, _texture)) {
      return l10n.asset_upload_unsupported_texture;
    }
    if (setEquals(kinds, _models)) return l10n.asset_upload_unsupported_models;
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

/// Asks for a file: dropped on the page or chosen in the file dialog.
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return AnimatedContainer(
      key: const Key('asset_upload_drop_zone'),
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: dragging
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppShapes.medium),
        border: Border.all(
          color: dragging ? colorScheme.primary : colorScheme.outlineVariant,
          width: dragging ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.upload_file,
            size: 36,
            color: dragging
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            dragging ? l10n.asset_upload_drop_now : l10n.asset_upload_drop,
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
          const SizedBox(height: 12),
          if (reading)
            const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            OutlinedButton.icon(
              icon: const Icon(Icons.folder_open_outlined),
              label: Text(l10n.asset_upload_choose),
              onPressed: onChoose,
            ),
        ],
      ),
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
