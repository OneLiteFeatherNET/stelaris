import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/notice_box.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/relative_time.dart';

/// A read-only dialog showing details about a model that don't otherwise
/// fit on its [ModelGridCard]/[ModelCard]: its id, full namespaced key, and
/// (only when relevant for that model type) whether it carries relationship
/// data.
class ModelInfoDialog extends StatelessWidget {
  const ModelInfoDialog({
    required this.name,
    required this.namespacedKey,
    required this.id,
    required this.creationDate,
    required this.modificationDate,
    this.hasRelationshipData,
    super.key,
  });

  final String name;
  final String namespacedKey;
  final String? id;
  final DateTime? creationDate;
  final DateTime? modificationDate;

  /// Null when this model type never carries relationship data — the row
  /// is omitted entirely rather than shown as "No".
  final bool? hasRelationshipData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: dialogPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    splashRadius: 20,
                  ),
                ],
              ),
              const Divider(height: 24),
              NoticeBox(
                icon: Icons.vpn_key_outlined,
                content: Text(
                  namespacedKey,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              verticalSpacing10,
              _InfoRow(
                label: context.l10n.dialog_model_info_id_label,
                value: id ?? '—',
                copyValue: id,
                monospace: true,
              ),
              if (creationDate != null)
                _InfoRow(
                  label: context.l10n.dialog_model_info_created_label,
                  value: relativeTime(context, creationDate!),
                  copyValue: creationDate!.toIso8601String(),
                ),
              if (modificationDate != null)
                _InfoRow(
                  label: context.l10n.dialog_model_info_modified_label,
                  value: relativeTime(context, modificationDate!),
                  copyValue: modificationDate!.toIso8601String(),
                ),
              if (hasRelationshipData != null)
                _InfoRow(
                  label: context.l10n.dialog_model_info_relationships_label,
                  value: hasRelationshipData!
                      ? context.l10n.dialog_model_info_relationships_yes
                      : context.l10n.dialog_model_info_relationships_no,
                ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.l10n.button_close),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.copyValue,
    this.monospace = false,
  });

  final String label;
  final String value;

  /// The exact value copied to the clipboard, which may differ from
  /// [value] (e.g. an ISO timestamp instead of "5 min ago"). Null hides
  /// the copy button — there's nothing meaningful to copy.
  final String? copyValue;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final copyValue = this.copyValue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontFamily: monospace ? 'monospace' : null,
              ),
            ),
          ),
          if (copyValue != null)
            SizedBox(
              width: 28,
              height: 28,
              child: IconButton(
                icon: const Icon(Icons.copy_outlined, size: 15),
                padding: EdgeInsets.zero,
                tooltip: context.l10n.tooltip_copy_to_clipboard,
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: copyValue));
                  if (!context.mounted) return;
                  context.showSuccessSnackBar(
                    context.l10n.snackbar_copied_to_clipboard,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
