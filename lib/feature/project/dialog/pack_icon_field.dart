import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/asset/picker/pick_asset_file.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Opens the file dialog for a pack icon.
Future<PickedAssetFile?> pickPackIcon() => pickAssetFile(accept: '.png');

/// The smallest side a pack icon may have.
const int packIconMinSize = 16;

/// Why a file can't be the pack icon.
enum PackIconProblem { notPng, notSquare, notPowerOfTwo, tooSmall }

/// The width and height a PNG declares in its header, or null when [bytes]
/// are no PNG. Reads only the header, the image isn't decoded.
({int width, int height})? pngSize(Uint8List bytes) {
  const signature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
  // The signature, then the IHDR chunk: length, type, width, height.
  if (bytes.length < 24) return null;
  for (var i = 0; i < signature.length; i++) {
    if (bytes[i] != signature[i]) return null;
  }
  final isHeader =
      bytes[12] == 0x49 &&
      bytes[13] == 0x48 &&
      bytes[14] == 0x44 &&
      bytes[15] == 0x52;
  if (!isHeader) return null;
  final data = ByteData.sublistView(bytes);
  return (width: data.getUint32(16), height: data.getUint32(20));
}

/// What keeps [bytes] from being a pack icon, null if they can be one: a
/// square PNG whose side is a power of two, at least [packIconMinSize].
PackIconProblem? checkPackIcon(Uint8List bytes) {
  final size = pngSize(bytes);
  if (size == null) return PackIconProblem.notPng;
  if (size.width != size.height) return PackIconProblem.notSquare;
  final side = size.width;
  if (side & (side - 1) != 0) return PackIconProblem.notPowerOfTwo;
  if (side < packIconMinSize) return PackIconProblem.tooSmall;
  return null;
}

/// Shows the pack icon and lets the user choose or remove it.
///
/// Only the picked file is kept, in [value]: storing it is not part of this
/// field.
class PackIconField extends StatefulWidget {
  const PackIconField({
    required this.value,
    required this.onChanged,
    this.pickFile = pickPackIcon,
    super.key,
  });

  /// The PNG of the icon, null for none.
  final Uint8List? value;
  final ValueChanged<Uint8List?> onChanged;
  final Future<PickedAssetFile?> Function() pickFile;

  @override
  State<PackIconField> createState() => _PackIconFieldState();
}

class _PackIconFieldState extends State<PackIconField> {
  /// Why the last chosen file was turned down.
  PackIconProblem? _problem;
  bool _reading = false;

  Future<void> _choose() async {
    setState(() => _reading = true);
    PickedAssetFile? picked;
    try {
      picked = await widget.pickFile();
    } catch (error) {
      if (!mounted) return;
      setState(() => _reading = false);
      context.showErrorSnackBar(error);
      return;
    }
    if (!mounted) return;
    setState(() {
      _reading = false;
      if (picked == null) return;
      _problem = checkPackIcon(picked.bytes);
      if (_problem == null) widget.onChanged(picked.bytes);
    });
  }

  void _remove() {
    setState(() => _problem = null);
    widget.onChanged(null);
  }

  String _problemText(PackIconProblem problem) {
    final l10n = context.l10n;
    return switch (problem) {
      PackIconProblem.notPng => l10n.pack_icon_not_png,
      PackIconProblem.notSquare => l10n.pack_icon_not_square,
      PackIconProblem.notPowerOfTwo => l10n.pack_icon_not_power_of_two,
      PackIconProblem.tooSmall => l10n.pack_icon_too_small,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final icon = widget.value;
    final size = icon == null ? null : pngSize(icon);
    final problem = _problem;
    // The preview is as high as the text and buttons beside it, and square.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(aspectRatio: 1, child: _IconPreview(icon: icon)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  size == null
                      ? l10n.pack_icon_none
                      : l10n.pack_icon_size(size.width, size.height),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  problem == null ? l10n.pack_icon_hint : _problemText(problem),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: problem == null
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _reading ? null : _choose,
                      icon: _reading
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.folder_open_outlined),
                      label: Text(
                        icon == null
                            ? l10n.pack_icon_choose
                            : l10n.pack_icon_change,
                      ),
                    ),
                    if (icon != null)
                      TextButton.icon(
                        onPressed: _reading ? null : _remove,
                        icon: const Icon(Icons.delete_outline),
                        label: Text(l10n.pack_icon_remove),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The icon filling its box, its pixels kept sharp, or a placeholder.
class _IconPreview extends StatelessWidget {
  const _IconPreview({required this.icon});

  final Uint8List? icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = this.icon;
    final placeholder = Icon(
      Icons.image_outlined,
      color: colorScheme.onSurfaceVariant,
    );
    return Container(
      key: const Key('pack_icon_preview'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: AppShapes.fieldRadius,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: icon == null
          ? placeholder
          : Image.memory(
              icon,
              key: const Key('pack_icon_image'),
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => placeholder,
            ),
    );
  }
}
