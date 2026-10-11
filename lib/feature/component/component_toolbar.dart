import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/component/color_swatch_button.dart';
import 'package:stelaris/feature/component/minimessage_field.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/minimessage_editing.dart';
import 'package:vulpes_data/color.dart';

typedef _Edit = TextEditingValue Function(TextEditingValue value);

/// One row of formatting controls above a MiniMessage field. The style
/// buttons show whether the caret or the selection has their formatting,
/// and every control edits [controller] only through [MiniMessageEditing].
class ComponentToolbar extends StatelessWidget {
  const ComponentToolbar({
    required this.controller,
    required this.focusNode,
    super.key,
  });

  final MiniMessageController controller;
  final FocusNode focusNode;

  void _apply(_Edit edit) {
    controller.value = edit(controller.value);
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Taps in the toolbar count as taps inside the text field, so the field
    // keeps its focus and selection while a control is clicked.
    return TextFieldTapRegion(
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final value = controller.value;
          Widget toggle(String tag, Widget icon, String tooltip) {
            return _ToggleButton(
              key: Key('minimessage_toggle_$tag'),
              icon: icon,
              tooltip: tooltip,
              selected: MiniMessageEditing.isActive(value, tag),
              onPressed: () =>
                  _apply((value) => MiniMessageEditing.toggle(value, tag)),
            );
          }

          return Wrap(
            spacing: 4,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              toggle('b', const Icon(Icons.format_bold), l10n.minimessage_bold),
              toggle(
                'i',
                const Icon(Icons.format_italic),
                l10n.minimessage_italic,
              ),
              toggle(
                'u',
                const Icon(Icons.format_underlined),
                l10n.minimessage_underline,
              ),
              toggle(
                'st',
                const Icon(Icons.format_strikethrough),
                l10n.minimessage_strikethrough,
              ),
              const _Separator(),
              _ColorMenu(
                current:
                    MiniMessageEditing.colorAt(value) ??
                    controller.componentContext.defaultColor,
                onColor: (color) => _apply(
                  (value) => MiniMessageEditing.applyColor(value, color),
                ),
              ),
              _GradientMenu(
                onGradient: (from, to) => _apply(
                  (value) => MiniMessageEditing.applyGradient(value, from, to),
                ),
              ),
              toggle('rainbow', const _RainbowIcon(), l10n.minimessage_rainbow),
              const _Separator(),
              IconButton(
                key: const Key('minimessage_clear'),
                icon: const Icon(Icons.format_clear),
                tooltip: l10n.minimessage_clear,
                onPressed: () => _apply(MiniMessageEditing.stripTags),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A style button that is filled while its formatting applies.
class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.onPressed,
    super.key,
  });

  final Widget icon;
  final String tooltip;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      icon: icon,
      tooltip: tooltip,
      isSelected: selected,
      style: IconButton.styleFrom(
        backgroundColor: selected ? colorScheme.secondaryContainer : null,
        foregroundColor: selected ? colorScheme.onSecondaryContainer : null,
      ),
      onPressed: onPressed,
    );
  }
}

/// A swatch with the rainbow's colors, plainer than any rainbow icon.
class _RainbowIcon extends StatelessWidget {
  const _RainbowIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            for (var hue = 0; hue <= 360; hue += 60)
              HSVColor.fromAHSV(1, hue % 360, 0.8, 1).toColor(),
          ],
        ),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
    );
  }
}

/// The text color icon, its bar in [color].
class _ColorIcon extends StatelessWidget {
  const _ColorIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    // The bar of the glyph spans x 2 to 22 and y 20 to 24 of its 24 px.
    return SizedBox.square(
      dimension: 24,
      child: Stack(
        children: [
          const Icon(Icons.format_color_text),
          Positioned(
            key: const Key('minimessage_color_bar'),
            left: 2,
            right: 2,
            bottom: 0,
            height: 4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                // Black and dark blue would vanish on a dark theme.
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 24, child: VerticalDivider(width: 16));
  }
}

/// The 16 named colors in a grid.
class _Swatches extends StatelessWidget {
  const _Swatches({required this.onPick, this.selected});

  final ValueChanged<NamedTextColor> onPick;
  final NamedTextColor? selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Two rows of eight, Minecraft's order from dark to light.
      width: 8 * 28 + 7 * 8,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final color in minecraftColorOrder)
            ColorSwatchButton(
              color: color,
              size: 28,
              selected: color == selected,
              onTap: () => onPick(color),
            ),
        ],
      ),
    );
  }
}

/// Opens the colors under its button and hands the picked one over.
class _ColorMenu extends StatefulWidget {
  const _ColorMenu({required this.current, required this.onColor});

  /// The color at the caret, shown in the button.
  final Color current;
  final ValueChanged<NamedTextColor> onColor;

  @override
  State<_ColorMenu> createState() => _ColorMenuState();
}

class _ColorMenuState extends State<_ColorMenu> {
  final MenuController _menu = MenuController();

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _menu,
      menuChildren: [
        TextFieldTapRegion(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _Swatches(
              onPick: (color) {
                _menu.close();
                widget.onColor(color);
              },
            ),
          ),
        ),
      ],
      builder: (context, menu, _) => IconButton(
        key: const Key('minimessage_color'),
        icon: _ColorIcon(color: widget.current),
        tooltip: context.l10n.minimessage_color,
        onPressed: () => menu.isOpen ? menu.close() : menu.open(),
      ),
    );
  }
}

/// Opens the colors under its button, takes the first and the second pick
/// as the ends of a gradient and applies it right after the second.
class _GradientMenu extends StatefulWidget {
  const _GradientMenu({required this.onGradient});

  final void Function(NamedTextColor from, NamedTextColor to) onGradient;

  @override
  State<_GradientMenu> createState() => _GradientMenuState();
}

class _GradientMenuState extends State<_GradientMenu> {
  final MenuController _menu = MenuController();

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _menu,
      menuChildren: [
        TextFieldTapRegion(
          child: _GradientPicker(
            onGradient: (from, to) {
              _menu.close();
              widget.onGradient(from, to);
            },
          ),
        ),
      ],
      builder: (context, menu, _) => IconButton(
        key: const Key('minimessage_gradient'),
        icon: const Icon(Icons.gradient),
        tooltip: context.l10n.minimessage_gradient,
        onPressed: () => menu.isOpen ? menu.close() : menu.open(),
      ),
    );
  }
}

/// Lives as long as the menu is open, so every opening starts over.
class _GradientPicker extends StatefulWidget {
  const _GradientPicker({required this.onGradient});

  final void Function(NamedTextColor from, NamedTextColor to) onGradient;

  @override
  State<_GradientPicker> createState() => _GradientPickerState();
}

class _GradientPickerState extends State<_GradientPicker> {
  NamedTextColor? _from;

  void _pick(NamedTextColor color) {
    final from = _from;
    if (from == null) {
      setState(() => _from = color);
    } else {
      widget.onGradient(from, color);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _from == null
                ? l10n.minimessage_gradient_from
                : l10n.minimessage_gradient_to,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          _Swatches(selected: _from, onPick: _pick),
        ],
      ),
    );
  }
}
