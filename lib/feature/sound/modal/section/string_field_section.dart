import 'package:flutter/material.dart';
import 'package:stelaris/feature/sound/modal/section/base_section.dart';

class StringInputSection extends StatefulWidget {
  const StringInputSection({super.key});

  @override
  State<StringInputSection> createState() => _StringInputSectionState();
}

class _StringInputSectionState extends State<StringInputSection> {
  late final TextEditingController _controller;
  final _borderRadius = BorderRadius.circular(8);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final outlineBorder = OutlineInputBorder(
      borderRadius: _borderRadius,
      borderSide: BorderSide(
        color: colorScheme.outline,
      ),
    );
    return BaseSection(
      title: 'Name',
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Enter your sound name',
          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          border: outlineBorder,
          suffixIcon: const Tooltip(
            message: 'test',
            child: Icon(Icons.info_outline),
          ),
          enabledBorder: outlineBorder,
          focusedBorder: OutlineInputBorder(
            borderRadius: _borderRadius,
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: _borderRadius,
            borderSide: BorderSide(color: colorScheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: _borderRadius,
            borderSide: BorderSide(color: colorScheme.error, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
      ),
    );
  }
}
