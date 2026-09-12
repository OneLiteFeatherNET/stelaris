import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/functions.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/minimessage_parser.dart';
import 'package:stelaris/util/typedefs.dart';
import 'package:vulpes_data/color/named_text_color.dart';

class ItemLoreDialog extends StatefulWidget {
  const ItemLoreDialog({
    required this.title,
    required this.valueUpdate,
    this.data,
    super.key,
  });

  final String title;
  final ValueUpdate<String> valueUpdate;
  final String? data;

  @override
  State<ItemLoreDialog> createState() => _ItemLoreDialogState();
}

class _ItemLoreDialogState extends State<ItemLoreDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _normalController = TextEditingController();
  final TextEditingController _miniMessageController = TextEditingController();
  final GlobalKey<FormState> _normalFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _miniMessageFormKey = GlobalKey<FormState>();

  NamedTextColor? _selectedColor;

  @override
  void initState() {
    super.initState();
    int initialTab = 0;

    final raw = widget.data;
    if (raw != null && raw.isNotEmpty) {
      final match = RegExp(r'^<([a-z_]+)>(.*)$').firstMatch(raw);
      if (match != null) {
        final colorName = match.group(1);
        final rest = match.group(2) ?? '';
        final matchedColor = NamedTextColor.values
            .where((c) => c.name == colorName)
            .firstOrNull;

        if (matchedColor != null && !rest.contains('<')) {
          _selectedColor =
              matchedColor == NamedTextColor.white ? null : matchedColor;
          _normalController.text = rest;
          _miniMessageController.text = raw;
          initialTab = 0;
        } else {
          _miniMessageController.text = raw;
          initialTab = 1;
        }
      } else if (!raw.contains('<')) {
        _normalController.text = raw;
        _miniMessageController.text = raw;
        initialTab = 0;
      } else {
        _miniMessageController.text = raw;
        initialTab = 1;
      }
    }

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialTab,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    _normalController.addListener(() {
      setState(() {});
    });
    _miniMessageController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _normalController.dispose();
    _miniMessageController.dispose();
    super.dispose();
  }

  Color _toFlutterColor(NamedTextColor color) {
    return Color(color.color.value | 0xFF000000);
  }

  void _onSave() {
    if (_tabController.index == 0) {
      if (!_normalFormKey.currentState!.validate()) return;
      final text = _normalController.text.trim();
      if (text.isEmpty) return;
      final result = _selectedColor != null
          ? '<${_selectedColor!.name}>$text'
          : text;
      widget.valueUpdate(result);
    } else {
      if (!_miniMessageFormKey.currentState!.validate()) return;
      final text = _miniMessageController.text.trim();
      if (text.isEmpty) return;
      widget.valueUpdate(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title, textAlign: TextAlign.center),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TabBar(
              controller: _tabController,
              onTap: (_) => setState(() {}),
              tabs: [
                Tab(
                  icon: const Icon(Icons.format_paint_outlined),
                  text: context.l10n.lore_tab_normal,
                ),
                Tab(
                  icon: const Icon(Icons.code),
                  text: context.l10n.lore_tab_minimessage,
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 280,
              child: _tabController.index == 0
                  ? _buildNormalTab()
                  : _buildMiniMessageTab(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.button_cancel),
        ),
        FilledButton(
          onPressed: _onSave,
          child: Text(context.l10n.button_save),
        ),
      ],
    );
  }

  BoxDecoration _getPreviewDecoration({
    required BuildContext context,
    Color? textColor,
    InlineSpan? span,
  }) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    bool hasDark = false;
    bool hasBright = false;

    if (textColor != null) {
      final lum = textColor.computeLuminance();
      hasDark = lum < 0.15;
      hasBright = lum > 0.45;
    }

    if (span != null) {
      span.visitChildren((child) {
        if (child is TextSpan && child.style?.color != null) {
          final lum = child.style!.color!.computeLuminance();
          if (lum < 0.15) hasDark = true;
          if (lum > 0.45) hasBright = true;
        }
        return true;
      });
    }

    final needsLightBg = isDarkTheme && hasDark;
    final needsDarkBg = !isDarkTheme && hasBright;

    if (needsLightBg) {
      return BoxDecoration(
        color: const Color(0xFFE4E4EE),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFFB8B8CC),
          width: 1.5,
        ),
      );
    } else if (needsDarkBg) {
      return BoxDecoration(
        color: const Color(0xFF1E1F28),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF3F3F52),
          width: 1.5,
        ),
      );
    }

    return BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: theme.colorScheme.outlineVariant,
        width: 1,
      ),
    );
  }

  Widget _buildNormalTab() {
    final previewText = _normalController.text.isEmpty
        ? 'Lore Preview'
        : _normalController.text;
    final flutterColor = _selectedColor != null
        ? _toFlutterColor(_selectedColor!)
        : Colors.white;

    final decoration = _getPreviewDecoration(
      textColor: flutterColor,
      context: context,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 10, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: _normalFormKey,
            child: TextFormField(
              controller: _normalController,
              autofocus: true,
              validator: (value) =>
                  checkIfEmptyAndReturnErrorString(value ?? '', context),
              decoration: InputDecoration(
                labelText: context.l10n.card_lore,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          verticalSpacing10,
          Text(
            context.l10n.lore_color_palette_title,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNoneChip(),
              _buildColorChip(NamedTextColor.yellow),
              _buildColorChip(NamedTextColor.aqua),
              _buildColorChip(NamedTextColor.blue),
              _buildColorChip(NamedTextColor.green),
              _buildColorChip(NamedTextColor.lightPurple),
              _buildColorChip(NamedTextColor.red),
              _buildColorChip(NamedTextColor.gray),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildColorChip(NamedTextColor.black),
              _buildColorChip(NamedTextColor.gold),
              _buildColorChip(NamedTextColor.darkAqua),
              _buildColorChip(NamedTextColor.darkBlue),
              _buildColorChip(NamedTextColor.darkGreen),
              _buildColorChip(NamedTextColor.darkPurple),
              _buildColorChip(NamedTextColor.darkRed),
              _buildColorChip(NamedTextColor.darkGray),
            ],
          ),
          verticalSpacing10,
          Text(
            context.l10n.lore_preview_title,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: decoration,
            child: Text(
              previewText,
              style: TextStyle(
                color: flutterColor,
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoneChip() {
    final isSelected = _selectedColor == null;
    return Tooltip(
      message: context.l10n.lore_color_default,
      child: InkWell(
        onTap: () => setState(() => _selectedColor = null),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade400,
              width: isSelected ? 2.5 : 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: isSelected
              ? const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.black,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildColorChip(NamedTextColor color) {
    final flutterColor = _toFlutterColor(color);
    final isSelected = _selectedColor == color;
    final isLight =
        ThemeData.estimateBrightnessForColor(flutterColor) == Brightness.light;

    return Tooltip(
      message: color.displayName,
      child: InkWell(
        onTap: () => setState(() => _selectedColor = color),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: flutterColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : (isLight ? Colors.grey.shade400 : Colors.grey.shade600),
              width: isSelected ? 2.5 : 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: flutterColor.withValues(alpha: 0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: isSelected
              ? Icon(
                  Icons.check,
                  size: 16,
                  color: isLight ? Colors.black : Colors.white,
                )
              : null,
        ),
      ),
    );
  }

  void _insertMiniMessageTag(String openTag, String closeTag) {
    final text = _miniMessageController.text;
    final selection = _miniMessageController.selection;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;

    final hasSelection = start != end;
    final selectedText = text.substring(start, end);
    final replacement = '$openTag$selectedText$closeTag';
    final newText = text.replaceRange(start, end, replacement);

    final cursorOffset = hasSelection
        ? start + replacement.length
        : start + openTag.length;

    _miniMessageController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }

  Widget _buildTagChip(
    String label, {
    required String openTag,
    required String closeTag,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => _insertMiniMessageTag(openTag, closeTag),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniMessageTab() {
    final previewText = _miniMessageController.text.isEmpty
        ? 'Lore Preview'
        : _miniMessageController.text;

    final parsedSpan = MiniMessageParser.parse(previewText);

    final decoration = _getPreviewDecoration(
      context: context,
      span: parsedSpan,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 10, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: _miniMessageFormKey,
            child: TextFormField(
              controller: _miniMessageController,
              maxLines: 2,
              validator: (value) =>
                  checkIfEmptyAndReturnErrorString(value ?? '', context),
              decoration: InputDecoration(
                labelText: context.l10n.lore_tab_minimessage,
                hintText:
                    '<yellow>Text</yellow> or <gradient:red:blue>Text</gradient>',
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tags',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.grey.shade400,
                    ),
              ),
              InkWell(
                onTap: () => _showSyntaxGuide(context),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.l10n.lore_syntax_guide_title,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildTagChip('<b>',
                  openTag: '<b>', closeTag: '</b>', tooltip: '<b>Bold</b>'),
              _buildTagChip('<i>',
                  openTag: '<i>', closeTag: '</i>', tooltip: '<i>Italic</i>'),
              _buildTagChip('<u>',
                  openTag: '<u>',
                  closeTag: '</u>',
                  tooltip: '<u>Underline</u>'),
              _buildTagChip('<st>',
                  openTag: '<st>',
                  closeTag: '</st>',
                  tooltip: '<st>Strikethrough</st>'),
              _buildTagChip('<gradient>',
                  openTag: '<gradient:red:blue>',
                  closeTag: '</gradient>',
                  tooltip: '<gradient:red:blue>Gradient</gradient>'),
              _buildTagChip('<rainbow>',
                  openTag: '<rainbow>',
                  closeTag: '</rainbow>',
                  tooltip: '<rainbow>Rainbow</rainbow>'),
              _buildTagChip('<reset>',
                  openTag: '<reset>',
                  closeTag: '',
                  tooltip: '<reset>Clear formatting'),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            context.l10n.lore_preview_title,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: decoration,
            child: Text.rich(
              parsedSpan,
            ),
          ),
        ],
      ),
    );
  }

  void _showSyntaxGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.lore_syntax_guide_title),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGuideItem(
                  tag: '<color> / <#hex>',
                  desc:
                      'Named colors (<red>, <yellow>, ...) or 3/6-digit hex (<#ff00aa>)',
                  example: '<gold>Epic <#00ff00>Sword',
                ),
                const Divider(),
                _buildGuideItem(
                  tag: '<b>, <i>, <u>, <st>',
                  desc:
                      'Styles: Bold, Italic, Underline, Strikethrough (close with </b> or <!b>)',
                  example: '<b>Bold</b> and <i>Italic</i>',
                ),
                const Divider(),
                _buildGuideItem(
                  tag: '<gradient:c1:c2:...>',
                  desc: 'Linear gradient between two or more colors',
                  example: '<gradient:red:blue>Gradient Text</gradient>',
                ),
                const Divider(),
                _buildGuideItem(
                  tag: '<rainbow>',
                  desc: 'Smooth rainbow spectrum over text',
                  example: '<rainbow>Rainbow Lore</rainbow>',
                ),
                const Divider(),
                _buildGuideItem(
                  tag: '<reset> or <r>',
                  desc: 'Clears all active colors and formatting',
                  example: '<red>Red <reset>Default',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.button_ok),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem({
    required String tag,
    required String desc,
    required String example,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tag,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF100010),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF28007F)),
            ),
            child: Text.rich(
              MiniMessageParser.parse(example),
            ),
          ),
        ],
      ),
    );
  }
}
