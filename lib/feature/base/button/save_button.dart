import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/util/constants.dart';

/// The class represents the save button widget which is used to save the changes.
/// It is only used in such structures which require a save button.
class SaveButton extends StatefulWidget {
  const SaveButton({
    required this.callback,
    this.text = emptyString,
    this.successMessage,
    this.heroTag = 'save_button',
    super.key,
  });

  /// The callback to invoke when pressed. Can be asynchronous ([Future]).
  final FutureOr<void> Function()? callback;

  /// Optional text label for extended FAB.
  final String text;

  /// Optional message to display via an info [SnackBar] upon successful completion.
  final String? successMessage;

  /// Optional heroTag for the FAB.
  final Object heroTag;

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  bool _isLoading = false;

  Future<void> _handlePressed() async {
    if (_isLoading || widget.callback == null) return;

    final callback = widget.callback!;
    final dynamic result = callback();

    if (result is Future) {
      setState(() => _isLoading = true);
      try {
        await result;
        if (mounted && widget.successMessage != null) {
          context.showSuccessSnackBar(widget.successMessage!);
        }
      } catch (error) {
        if (mounted) {
          context.showErrorSnackBar(error);
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      if (widget.successMessage != null) {
        context.showSuccessSnackBar(widget.successMessage!);
      }
    }
  }

  Widget _buildIcon(Color progressColor) {
    if (_isLoading) {
      return SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: progressColor,
        ),
      );
    }
    return saveIcon;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foregroundColor = theme.colorScheme.onPrimary;

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 25, right: 10),
        child: widget.text == emptyString
            ? FloatingActionButton(
                heroTag: widget.heroTag,
                onPressed: _isLoading ? null : _handlePressed,
                child: _buildIcon(foregroundColor),
              )
            : FloatingActionButton.extended(
                heroTag: widget.heroTag,
                onPressed: _isLoading ? null : _handlePressed,
                label: Text(widget.text),
                icon: _buildIcon(foregroundColor),
              ),
      ),
    );
  }
}
