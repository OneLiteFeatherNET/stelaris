import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The dot after a detail page's title while the page holds unsaved edits.
///
/// It pops in with a single pulse when edits appear and fades out once
/// they are saved or discarded. A page opened with unsaved edits shows it
/// at once, and with animations disabled it simply appears and disappears.
class UnsavedIndicator extends StatefulWidget {
  const UnsavedIndicator({required this.visible, super.key});

  final bool visible;

  @override
  State<UnsavedIndicator> createState() => _UnsavedIndicatorState();
}

class _UnsavedIndicatorState extends State<UnsavedIndicator>
    with TickerProviderStateMixin {
  static const double _size = 8;

  late final AnimationController _appear = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
    reverseDuration: const Duration(milliseconds: 150),
    value: widget.visible ? 1 : 0,
  )..addStatusListener(_rebuild);

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..addStatusListener(_rebuild);

  late final Animation<double> _dotScale = CurvedAnimation(
    parent: _appear,
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeIn,
  );

  late final Animation<double> _pulseScale = Tween<double>(
    begin: 1,
    end: 2.5,
  ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeOut));

  late final Animation<double> _pulseOpacity = Tween<double>(
    begin: 0.5,
    end: 0,
  ).animate(_pulse);

  /// The dot leaves the tree once faded out, and the pulse once it ran.
  void _rebuild(AnimationStatus status) => setState(() {});

  @override
  void didUpdateWidget(UnsavedIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible == oldWidget.visible) return;

    if (MediaQuery.disableAnimationsOf(context)) {
      _appear.value = widget.visible ? 1 : 0;
    } else if (widget.visible) {
      _appear.forward();
      _pulse.forward(from: 0);
    } else {
      _appear.reverse();
    }
  }

  @override
  void dispose() {
    _appear.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Widget _dot(Color color, {Key? key}) => Container(
    key: key,
    width: _size,
    height: _size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  @override
  Widget build(BuildContext context) {
    if (_appear.isDismissed) return const SizedBox.shrink();
    final color = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 8),
      child: Tooltip(
        message: context.l10n.unsaved_indicator_tooltip,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (_pulse.isAnimating)
              FadeTransition(
                opacity: _pulseOpacity,
                child: ScaleTransition(
                  scale: _pulseScale,
                  child: _dot(color, key: const Key('unsaved_indicator_pulse')),
                ),
              ),
            FadeTransition(
              opacity: _appear,
              child: ScaleTransition(
                scale: _dotScale,
                child: _dot(
                  color,
                  key: const Key('page_header_unsaved_indicator'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
