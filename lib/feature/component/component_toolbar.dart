import 'package:stelaris/util/minimessage_parser.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/component/color_swatch_button.dart';
import 'package:stelaris/feature/component/minimessage_field.dart';
import 'package:stelaris/feature/component/syntax_guide_dialog.dart';
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
    Widget toggle(String tag, Widget icon, String tooltip) {
      return ListenableBuilder(
        key: Key('minimessage_toggle_$tag'),
        listenable: controller,
        builder: (context, _) => _ToggleButton(
          icon: icon,
          tooltip: tooltip,
          selected: MiniMessageEditing.isActive(controller.value, tag),
          onPressed: () =>
              _apply((value) => MiniMessageEditing.toggle(value, tag)),
        ),
      );
    }

    // Taps in the toolbar count as taps inside the text field, so the field
    // keeps its focus and selection while a control is clicked.
    return TextFieldTapRegion(
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          toggle('b', const Icon(Icons.format_bold), l10n.minimessage_bold),
          toggle('i', const Icon(Icons.format_italic), l10n.minimessage_italic),
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
          _MenuButton(
            key: const Key('minimessage_color'),
            tooltip: l10n.minimessage_color,
            icon: ListenableBuilder(
              listenable: controller,
              builder: (context, _) => _ColorIcon(
                color:
                    MiniMessageEditing.colorAt(controller.value) ??
                    controller.componentContext.defaultColor,
              ),
            ),
            menu: (close) {
              void pick(String tag) {
                close();
                _apply((value) => MiniMessageEditing.applyColorTag(value, tag));
              }

              return Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Swatches(onPick: (color) => pick(color.key)),
                    const SizedBox(height: 12),
                    _HexInput(onColor: pick),
                  ],
                ),
              );
            },
          ),
          _MenuButton(
            key: const Key('minimessage_gradient'),
            tooltip: l10n.minimessage_gradient,
            icon: const Icon(Icons.gradient),
            menu: (close) => _GradientPicker(
              onGradient: (stops) {
                close();
                _apply(
                  (value) =>
                      MiniMessageEditing.applyGradientStops(value, stops),
                );
              },
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
          IconButton(
            key: const Key('minimessage_guide'),
            icon: const Icon(Icons.help_outline),
            tooltip: l10n.minimessage_guide_title,
            onPressed: () => SyntaxGuideDialog.show(
              context,
              componentContext: controller.componentContext,
            ),
          ),
        ],
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
  const _Swatches({required this.onPick});

  final ValueChanged<NamedTextColor> onPick;

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
              onTap: () => onPick(color),
            ),
        ],
      ),
    );
  }
}

/// An icon button that opens [menu] under itself and closes it again on a
/// second click. [menu] gets a callback that closes it.
class _MenuButton extends StatefulWidget {
  const _MenuButton({
    required this.icon,
    required this.tooltip,
    required this.menu,
    super.key,
  });

  final Widget icon;
  final String tooltip;
  final Widget Function(VoidCallback close) menu;

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  final MenuController _menu = MenuController();

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _menu,
      menuChildren: [
        // The menu lies in the overlay, outside the toolbar's region.
        TextFieldTapRegion(child: widget.menu(_menu.close)),
      ],
      builder: (context, menu, _) => IconButton(
        icon: widget.icon,
        tooltip: widget.tooltip,
        onPressed: () => menu.isOpen ? menu.close() : menu.open(),
      ),
    );
  }
}

/// Lives as long as the menu is open, so every opening starts over. Takes
/// two or three colors, each a named one or a hex color, and applies the
/// gradient right after the last.
class _GradientPicker extends StatefulWidget {
  const _GradientPicker({required this.onGradient});

  /// The color tags of the gradient, e.g. `gold` or `#ff00aa`.
  final ValueChanged<List<String>> onGradient;

  @override
  State<_GradientPicker> createState() => _GradientPickerState();
}

class _GradientPickerState extends State<_GradientPicker> {
  int _count = 2;
  final List<String> _stops = [];

  void _pick(String tag) {
    final stops = [..._stops, tag];
    if (stops.length == _count) {
      widget.onGradient(stops);
    } else {
      setState(() => _stops.add(tag));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<int>(
            key: const Key('minimessage_gradient_count'),
            showSelectedIcon: false,
            segments: [
              for (final count in [2, 3])
                ButtonSegment(
                  value: count,
                  label: Text(l10n.minimessage_gradient_colors(count)),
                ),
            ],
            selected: {_count},
            // Fewer colors than picked would apply at once, start over.
            onSelectionChanged: (counts) => setState(() {
              _count = counts.single;
              _stops.clear();
            }),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                l10n.minimessage_gradient_pick(_stops.length + 1, _count),
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(width: 8),
              // The colors picked so far.
              for (final stop in _stops)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: _Dot(color: MiniMessageParser.colorOf(stop)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _Swatches(onPick: (color) => _pick(color.key)),
          const SizedBox(height: 12),
          _HexInput(onColor: _pick),
        ],
      ),
    );
  }
}

/// A small round color, outlined so black shows on a dark menu.
class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
    );
  }
}

/// Takes a hex color, with or without its `#`, and hands it on as a color
/// tag like `#ff00aa`. Shows the color while it is typed.
class _HexInput extends StatefulWidget {
  const _HexInput({required this.onColor});

  final ValueChanged<String> onColor;

  @override
  State<_HexInput> createState() => _HexInputState();
}

class _HexInputState extends State<_HexInput> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// The tag for the typed text, null when it is no hex color.
  String? get _tag {
    var text = _controller.text.trim().toLowerCase();
    if (!text.startsWith('#')) text = '#$text';
    return MiniMessageEditing.isColorTag(text) && text.startsWith('#')
        ? text
        : null;
  }

  void _submit() {
    final tag = _tag;
    if (tag == null) {
      setState(() => _error = context.l10n.minimessage_hex_invalid);
      return;
    }
    widget.onColor(tag);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tag = _tag;
    return SizedBox(
      width: 8 * 28 + 7 * 8,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 8),
            child: _Dot(
              color: tag == null ? null : MiniMessageParser.colorOf(tag),
            ),
          ),
          Expanded(
            child: TextField(
              key: const Key('minimessage_hex'),
              controller: _controller,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[#0-9a-fA-F]')),
                LengthLimitingTextInputFormatter(7),
              ],
              decoration: InputDecoration(
                isDense: true,
                hintText: l10n.minimessage_hex_hint,
                errorText: _error,
              ),
              onChanged: (_) => setState(() => _error = null),
              onSubmitted: (_) => _submit(),
            ),
          ),
          IconButton(
            key: const Key('minimessage_hex_apply'),
            icon: const Icon(Icons.check),
            tooltip: l10n.minimessage_hex_apply,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
