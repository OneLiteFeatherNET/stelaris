import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/asset_model.dart';
import 'package:stelaris/feature/asset/item_model_asset_preview.dart';
import 'package:stelaris/feature/asset/loading/asset_library.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/item/components/component_dialogs.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// From this width on there is room for the model preview next to the cards.
const double itemModelPreviewBreakpoint = 840;

/// The state of the model preview on the components tab, kept by the page.
class ItemModelPreviewController {
  /// Whether the preview is shown next to the cards. Not kept across app
  /// starts, the app doesn't store settings locally yet.
  bool shown = true;

  /// The model lookup of the last item model key, so rebuilds don't look it
  /// up again.
  ({String projectId, String key, Future<AssetModel?> model})? _lookup;

  void toggle() => shown = !shown;

  /// Drops the lookup, so the next [modelOf] asks the backend again.
  void refresh() => _lookup = null;

  /// The model the item model key names in the project, null without a key
  /// or a project. The same lookup is kept while the key stays.
  Future<AssetModel?>? modelOf(ComponentProject? project, String? key) {
    if (project == null || key == null) return null;
    final last = _lookup;
    if (last == null || last.projectId != project.id || last.key != key) {
      _lookup = (
        projectId: project.id,
        key: key,
        model: AssetLibrary.shared.findModelByKey(project.id, key),
      );
    }
    return _lookup!.model;
  }
}

/// The value of the item model component, null when the item has none.
String? itemModelKeyOf(List<ItemComponentDto> components) {
  for (final component in components) {
    final value = component.value;
    if (component.componentKey == itemModelComponent && value is String) {
      return value;
    }
  }
  return null;
}

/// Shows and hides the model preview next to the cards, or opens it as a
/// bottom sheet when there is no room for it.
class ItemModelPreviewToggle extends StatelessWidget {
  const ItemModelPreviewToggle({
    required this.controller,
    required this.project,
    required this.itemModelKey,
    required this.wide,
    required this.onToggle,
    super.key,
  });

  final ItemModelPreviewController controller;
  final ComponentProject? project;
  final String? itemModelKey;

  /// Whether there is room next to the cards, else the preview is a sheet.
  final bool wide;

  /// Flips whether the preview is shown next to the cards.
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final projectId = project?.id;
    return FutureBuilder<AssetModel?>(
      future: controller.modelOf(project, itemModelKey),
      builder: (context, snapshot) {
        // Without a project there is no model to show, whatever the key.
        final asset = projectId == null ? null : snapshot.data;
        return PageHeaderAction(
          key: const Key('item_model_preview_toggle'),
          // The icon tells what a press does.
          icon: Icon(
            wide && controller.shown
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          label: context.l10n.item_model_preview_title,
          // Only offered while there is a model to show.
          onPressed: asset == null
              ? null
              : () =>
                    wide ? onToggle() : _openSheet(context, projectId!, asset),
        );
      },
    );
  }

  /// Without room next to the cards, the model preview opens as a bottom
  /// sheet.
  static void _openSheet(
    BuildContext context,
    String projectId,
    AssetModel asset,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: 420,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: ItemModelPreview(projectId: projectId, asset: asset),
        ),
      ),
    );
  }
}

/// Wraps the card grid in [child] and shows the model preview in a slot next
/// to it, when the page is wide enough and the preview is shown.
class ItemModelPreviewSlot extends StatelessWidget {
  const ItemModelPreviewSlot({
    required this.controller,
    required this.project,
    required this.itemModelKey,
    required this.child,
    super.key,
  });

  final ItemModelPreviewController controller;
  final ComponentProject? project;
  final String? itemModelKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final projectId = project?.id;
    return Expanded(
      child: FutureBuilder<AssetModel?>(
        future: controller.modelOf(project, itemModelKey),
        builder: (context, snapshot) {
          // Without a project there is no model to show, whatever the key.
          final asset = projectId == null ? null : snapshot.data;
          return LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= itemModelPreviewBreakpoint;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: child),
                  // Slides and fades in from the right edge, the cards give
                  // way.
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) => SizeTransition(
                      sizeFactor: animation,
                      axis: Axis.horizontal,
                      // Top, the transition fills the height and would center
                      // it.
                      alignment: AlignmentDirectional.topStart,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: wide && controller.shown && asset != null
                        ? Padding(
                            key: const ValueKey('item_model_preview_slot'),
                            padding: const EdgeInsets.only(left: 16),
                            child: SizedBox(
                              width: (constraints.maxWidth * 0.35).clamp(
                                280,
                                420,
                              ),
                              child: ItemModelPreview(
                                projectId: projectId!,
                                asset: asset,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
