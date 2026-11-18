import 'dart:math' as math;
import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/png_size.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/bytes.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Loads the bytes of the asset [assetId] of [projectId].
typedef TextureContentLoader = Future<List<int>> Function(
  String projectId,
  String assetId,
);

Future<List<int>> _loadFromBackend(String projectId, String assetId) =>
    ApiService().assetApi.content(projectId, assetId);

/// Shows the texture [asset] of [projectId] as pixel art: scaled by a whole
/// factor where it fits, without smoothing, on a checkerboard that shows its
/// transparent pixels.
///
/// [TexturePreview.bytes] shows a file that is not stored yet, e.g. one
/// chosen for an upload.
class TexturePreview extends StatefulWidget {
  const TexturePreview({
    required String this.projectId,
    required AssetModel this.asset,
    this.loadContent = _loadFromBackend,
    super.key,
  }) : bytes = null;

  const TexturePreview.bytes(Uint8List this.bytes, {super.key})
    : projectId = null,
      asset = null,
      loadContent = _loadFromBackend;

  /// The height of the area the texture is shown in.
  static const double height = 160;

  final String? projectId;
  final AssetModel? asset;

  /// The texture itself, shown instead of loading [asset].
  final Uint8List? bytes;

  /// Loads the bytes of the texture, injectable for tests.
  final TextureContentLoader loadContent;

  @override
  State<TexturePreview> createState() => _TexturePreviewState();
}

class _TexturePreviewState extends State<TexturePreview> {
  late Future<Uint8List> _bytes = _load();

  Future<Uint8List> _load() async {
    if (widget.bytes case final bytes?) return bytes;
    return asUint8List(
      await widget.loadContent(widget.projectId!, widget.asset!.id),
    );
  }

  @override
  void didUpdateWidget(TexturePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.bytes, widget.bytes) ||
        oldWidget.asset?.id != widget.asset?.id ||
        oldWidget.asset?.sha1 != widget.asset?.sha1) {
      _bytes = _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppShapes.medium),
      child: SizedBox(
        height: TexturePreview.height,
        child: CustomPaint(
          painter: _CheckerboardPainter(
            light: colorScheme.surfaceContainerLowest,
            dark: colorScheme.surfaceContainerHigh,
          ),
          child: FutureBuilder<Uint8List>(
            future: _bytes,
            // Bytes at hand need no loading indicator.
            initialData: widget.bytes,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(context.l10n.texture_preview_failed));
              }
              final bytes = snapshot.data;
              if (bytes == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return LayoutBuilder(
                builder: (context, constraints) =>
                    Center(child: _texture(bytes, constraints.biggest)),
              );
            },
          ),
        ),
      ),
    );
  }

  /// The texture in its scaled size within [space], or fitted into it when
  /// its size is unknown.
  Widget _texture(Uint8List bytes, Size space) => _pixelArt(
    bytes,
    space,
    width: widget.asset?.width,
    height: widget.asset?.height,
    errorBuilder: (context) => Text(context.l10n.texture_preview_failed),
    tooLargeBuilder: (context, width, height) => Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        context.l10n.texture_preview_too_large(width, height),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

/// The most pixels a texture may have to be shown, 4096 × 4096. A larger
/// one isn't decoded: the full image would take hundreds of megabytes before
/// it is shrunk, and freeze the page while it is decoded.
const int maxPreviewPixels = 4096 * 4096;

/// The texture of [bytes] without smoothing. Of a known size it is scaled
/// into [space] by a whole factor, which keeps every pixel the same size. A
/// larger texture is only shrunk to fit, one of unknown size fitted.
///
/// The image is decoded no larger than it is shown, so a large texture takes
/// no more memory than the space it fills. One of more than
/// [maxPreviewPixels], as stated or as its PNG header says, shows
/// [tooLargeBuilder] instead.
Widget _pixelArt(
  Uint8List bytes,
  Size space, {
  required int? width,
  required int? height,
  required WidgetBuilder errorBuilder,
  required Widget Function(BuildContext context, int width, int height)
  tooLargeBuilder,
}) => Builder(
  builder: (context) {
    var pixelsWide = width;
    var pixelsHigh = height;
    if (pixelsWide == null ||
        pixelsHigh == null ||
        pixelsWide == 0 ||
        pixelsHigh == 0) {
      final header = pngSize(bytes);
      pixelsWide = header?.width;
      pixelsHigh = header?.height;
    }
    if (pixelsWide != null &&
        pixelsHigh != null &&
        pixelsWide * pixelsHigh > maxPreviewPixels) {
      return tooLargeBuilder(context, pixelsWide, pixelsHigh);
    }

    // The size the texture takes on the screen, from the stated size only:
    // the header may lie about a file that isn't a PNG after all.
    Size? shown;
    if (width != null && height != null && width != 0 && height != 0) {
      final fit = math.min(space.width / width, space.height / height);
      final scale = fit >= 1 ? fit.floorToDouble() : fit;
      shown = Size(width * scale, height * scale);
    }

    final target = shown ?? space;
    final pixelRatio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
    ImageProvider provider = MemoryImage(bytes);
    if (target.isFinite && !target.isEmpty) {
      provider = ResizeImage(
        provider,
        width: (target.width * pixelRatio).ceil(),
        height: (target.height * pixelRatio).ceil(),
        policy: ResizeImagePolicy.fit,
      );
    }
    final image = Image(
      image: provider,
      filterQuality: FilterQuality.none,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      errorBuilder: (context, _, _) => errorBuilder(context),
    );
    if (shown == null) return image;
    return SizedBox(width: shown.width, height: shown.height, child: image);
  },
);

/// Shows the texture [asset] small, e.g. in the row of a list, on the
/// checkerboard of [TexturePreview]. Whoever lists the textures loads their
/// [bytes], to keep them while the rows come and go. Until they are there
/// only the checkerboard shows, the icon of a texture if they can't be shown.
///
/// Without [checkerboard] the texture stands on what is behind it, for a
/// place that shows it as a picture and not to judge its transparency.
class TextureThumbnail extends StatelessWidget {
  const TextureThumbnail({
    required this.asset,
    required this.bytes,
    this.checkerboard = true,
    super.key,
  });

  /// The width and height of the thumbnail.
  static const double size = 40;

  final AssetModel asset;
  final Future<Uint8List> bytes;

  /// Whether the squares that show transparent pixels are painted.
  final bool checkerboard;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Widget failed(BuildContext context) =>
        Icon(Icons.image_outlined, color: colorScheme.onSurfaceVariant);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppShapes.extraSmall),
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: checkerboard
              ? _CheckerboardPainter(
                  light: colorScheme.surfaceContainerLowest,
                  dark: colorScheme.surfaceContainerHigh,
                  square: 5,
                )
              : null,
          child: FutureBuilder<Uint8List>(
            future: bytes,
            builder: (context, snapshot) {
              if (snapshot.hasError) return failed(context);
              final bytes = snapshot.data;
              if (bytes == null) return const SizedBox.shrink();
              return Center(
                child: _pixelArt(
                  bytes,
                  const Size.square(size),
                  width: asset.width,
                  height: asset.height,
                  errorBuilder: failed,
                  tooLargeBuilder: (context, _, _) => failed(context),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Paints squares of [light] and [dark], the usual backdrop of transparency.
class _CheckerboardPainter extends CustomPainter {
  const _CheckerboardPainter({
    required this.light,
    required this.dark,
    this.square = 8,
  });

  final Color light;
  final Color dark;

  /// The side of a square.
  final double square;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = light);
    final paint = Paint()..color = dark;
    for (var y = 0; y * square < size.height; y++) {
      for (var x = y.isEven ? 1 : 0; x * square < size.width; x += 2) {
        canvas.drawRect(
          Rect.fromLTWH(x * square, y * square, square, square),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerboardPainter oldDelegate) =>
      oldDelegate.light != light ||
      oldDelegate.dark != dark ||
      oldDelegate.square != square;
}
