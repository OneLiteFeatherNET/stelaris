import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/sound/playback/pick_by_weight.dart';
import 'package:stelaris/feature/sound/playback/play_button_content.dart';
import 'package:stelaris/feature/sound/playback/sound_playback_controller.dart';
import 'package:stelaris/feature/sound/playback/sound_waveform.dart';
import 'package:stelaris/feature/sound/playback/sound_waveform_painter.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Plays [from] on, the way the page reports what goes wrong.
typedef PlaySoundFile = Future<void> Function(
  SoundFileSource source, {
  Duration from,
});

/// The bar below the sound files that plays the [SoundPlaybackController]'s
/// current file: back, play or pause, next, its name, the waveform to jump
/// in, its time, a file picked by weight like in the game, and closing.
/// Below that, volume and pitch to try out, and to apply to the file.
///
/// While [shortcutsEnabled], the space bar plays or pauses and the arrow
/// keys step through the files, unless a dialog is open or a text field or
/// slider has the keyboard. Before any file was played, they start the
/// first one.
///
/// Times are shown as they play in the game, like in the cards.
class SoundPlayerBar extends StatefulWidget {
  const SoundPlayerBar({
    required this.controller,
    required this.projectId,
    required this.sources,
    required this.titleOf,
    required this.onPlay,
    required this.onApply,
    this.random,
    this.shortcutsEnabled = true,
    super.key,
  });

  final SoundPlaybackController controller;
  final String projectId;

  /// The files that can be played, in the order of the page.
  final List<SoundFileSource> sources;

  /// The name the page shows for a file.
  final String Function(SoundFileSource source) titleOf;

  final PlaySoundFile onPlay;

  /// Saves the file with the tried-out volume and pitch.
  final Future<void> Function(SoundFileSource updated) onApply;

  /// Picks the file played like in the game; a new one when null.
  final Random? random;

  /// Whether the keys play, e.g. only while the tab of the files shows.
  final bool shortcutsEnabled;

  @override
  State<SoundPlayerBar> createState() => _SoundPlayerBarState();
}

class _SoundPlayerBarState extends State<SoundPlayerBar>
    with SingleTickerProviderStateMixin {
  late final Random _random = widget.random ?? Random();
  late final Ticker _ticker = createTicker((_) => _syncPosition());
  final ValueNotifier<Duration> _position = ValueNotifier(Duration.zero);
  bool _applying = false;

  /// Where a drag along the waveform would let go; while set, only the
  /// waveform and the time follow it, the file seeks once at the end.
  double? _scrubbing;

  SoundPlaybackController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onPlayback);
    HardwareKeyboard.instance.addHandler(_onKey);
    _onPlayback();
  }

  @override
  void didUpdateWidget(SoundPlayerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onPlayback);
      widget.controller.addListener(_onPlayback);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onPlayback);
    HardwareKeyboard.instance.removeHandler(_onKey);
    _ticker.dispose();
    _position.dispose();
    super.dispose();
  }

  void _onPlayback() {
    final playing = _controller.status == SoundPlaybackStatus.playing;
    if (playing && !_ticker.isActive) _ticker.start();
    if (!playing && _ticker.isActive) _ticker.stop();
    _syncPosition();
    if (mounted) setState(() {});
  }

  void _syncPosition() {
    if (_scrubbing != null) return;
    final current = _controller.current;
    _position.value = current == null
        ? Duration.zero
        : _controller.positionOf(current);
  }

  int get _index {
    final current = _controller.current;
    if (current == null) return -1;
    return widget.sources.indexWhere((source) => _same(source, current));
  }

  static bool _same(SoundFileSource a, SoundFileSource b) =>
      a.id != null ? a.id == b.id : a.name == b.name;

  void _play(SoundFileSource source, {Duration from = Duration.zero}) =>
      widget.onPlay(source, from: from);

  void _playPause(SoundFileSource current) {
    switch (_controller.status) {
      case SoundPlaybackStatus.playing || SoundPlaybackStatus.paused:
        _controller.togglePause();
      case SoundPlaybackStatus.loading:
        _controller.stop();
      case SoundPlaybackStatus.idle:
        _play(current);
    }
  }

  /// Handles the space bar and the arrow keys, see [SoundPlayerBar].
  bool _onKey(KeyEvent event) {
    if (!widget.shortcutsEnabled || event is! KeyDownEvent) return false;
    if (widget.sources.isEmpty || !_hasKeyboard) return false;
    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isControlPressed ||
        keyboard.isMetaPressed ||
        keyboard.isAltPressed ||
        keyboard.isShiftPressed) {
      return false;
    }

    final current = _controller.current;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.space:
        current == null ? _play(widget.sources.first) : _playPause(current);
      case LogicalKeyboardKey.arrowLeft:
        current == null ? _play(widget.sources.first) : _step(-1);
      case LogicalKeyboardKey.arrowRight:
        current == null ? _play(widget.sources.first) : _step(1);
      default:
        return false;
    }
    return true;
  }

  /// Whether the keys are meant for the page: no dialog over it, and no text
  /// field or slider that takes them.
  bool get _hasKeyboard {
    if (!mounted || ModalRoute.of(context)?.isCurrent == false) return false;
    final focused = FocusManager.instance.primaryFocus?.context;
    if (focused == null) return true;
    return focused.widget is! EditableText &&
        focused.findAncestorWidgetOfExactType<EditableText>() == null &&
        focused.findAncestorWidgetOfExactType<Slider>() == null;
  }

  void _step(int by) {
    final next = _index + by;
    if (next < 0 || next >= widget.sources.length) return;
    _play(widget.sources[next]);
  }

  void _playRandom() {
    final picked = pickByWeight(widget.sources, _random);
    if (picked != null) _play(picked);
  }

  /// Jumps to [fraction] of [waveform]; a file that doesn't play starts
  /// there.
  void _seek(SoundFileSource current, SoundWaveform waveform, double fraction) {
    final position = waveform.duration * fraction.clamp(0.0, 1.0);
    switch (_controller.status) {
      case SoundPlaybackStatus.playing || SoundPlaybackStatus.paused:
        _controller.seek(position);
        _syncPosition();
      case SoundPlaybackStatus.idle:
        _play(current, from: position);
      case SoundPlaybackStatus.loading:
        break;
    }
  }

  /// Moves the shown position along a drag, without seeking yet.
  void _scrub(SoundWaveform waveform, double fraction) {
    final clamped = fraction.clamp(0.0, 1.0);
    _scrubbing = clamped;
    _position.value = waveform.duration * clamped;
  }

  /// Seeks where the drag let go, like a tap there.
  void _endScrub(SoundFileSource current, SoundWaveform waveform) {
    final fraction = _scrubbing;
    _scrubbing = null;
    if (fraction == null) return;
    _seek(current, waveform, fraction);
  }

  void _cancelScrub() {
    _scrubbing = null;
    _syncPosition();
  }

  Future<void> _apply(SoundFileSource current) async {
    setState(() => _applying = true);
    try {
      await widget.onApply(
        current.copyWith(
          volume: _controller.volumeOf(current),
          pitch: _controller.pitchOf(current),
        ),
      );
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _controller.current;
    if (current == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final index = _index;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Material(
        key: const Key('sound_player_bar'),
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppShapes.large),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            // The sides take as much room each, so the waveform stays in the
            // middle; what it leaves goes to both of its sides alike.
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    IconButton(
                      key: const Key('sound_player_previous'),
                      tooltip: l10n.sound_player_previous,
                      onPressed: index > 0 ? () => _step(-1) : null,
                      icon: const Icon(Icons.skip_previous),
                    ),
                    _PlayPauseButton(
                      status: _controller.status,
                      onPressed: () => _playPause(current),
                    ),
                    IconButton(
                      key: const Key('sound_player_next'),
                      tooltip: l10n.sound_player_next,
                      onPressed: index < widget.sources.length - 1
                          ? () => _step(1)
                          : null,
                      icon: const Icon(Icons.skip_next),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 260),
                        child: Text(
                          widget.titleOf(current),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
              Flexible(
                flex: 2,
                // Wider, the bars of the waveform would stand apart.
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: _SeekableWaveform(
                    future: _controller.waveformOf(widget.projectId, current),
                    initial: _controller.readWaveformOf(current),
                    position: _position,
                    pitch: _controller.pitchOf(current),
                    onSeek: (waveform, fraction) =>
                        _seek(current, waveform, fraction),
                    onScrub: _scrub,
                    onScrubEnd: (waveform) => _endScrub(current, waveform),
                    onScrubCancel: _cancelScrub,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(width: 16),
                    _TuneMenu(
                      controller: _controller,
                      current: current,
                      applying: _applying,
                      onApply: () => _apply(current),
                    ),
                    IconButton(
                      key: const Key('sound_player_random'),
                      tooltip: l10n.sound_player_random,
                      onPressed: widget.sources.isEmpty ? null : _playRandom,
                      icon: const Icon(Icons.casino_outlined),
                    ),
                    IconButton(
                      key: const Key('sound_player_close'),
                      tooltip: l10n.sound_player_close,
                      onPressed: _controller.close,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The button that opens volume and pitch to try out, with a dot while they
/// differ from the file's, and the menu of the sliders, apply and reset.
///
/// The menu opens above the bar with some room to it, its end lined up with
/// the end of the button, so it opens towards the page.
class _TuneMenu extends StatefulWidget {
  const _TuneMenu({
    required this.controller,
    required this.current,
    required this.applying,
    required this.onApply,
  });

  final SoundPlaybackController controller;
  final SoundFileSource current;
  final bool applying;
  final VoidCallback onApply;

  @override
  State<_TuneMenu> createState() => _TuneMenuState();
}

class _TuneMenuState extends State<_TuneMenu> {
  final MenuController _menu = MenuController();

  /// Slider values keep to two decimals, as typed into the file's dialog.
  static double _round(double value) => (value * 100).roundToDouble() / 100;

  static const EdgeInsets _padding = EdgeInsets.all(16);
  static const double _contentWidth = 320;

  /// The room between the top of the button and the menu: the padding of the
  /// bar above the button, and a gap above the bar.
  static const double _gap = 6 + 8;

  void _toggle() => _menu.isOpen ? _menu.close() : _menu.open();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    return RawMenuAnchor(
      controller: _menu,
      overlayBuilder: (context, info) => Positioned(
        right: info.overlaySize.width - info.anchorRect.right,
        bottom: info.overlaySize.height - info.anchorRect.top + _gap,
        child: TapRegion(
          // The button is in the group too, so its tap toggles instead.
          groupId: info.tapRegionGroupId,
          onTapOutside: (_) => _menu.close(),
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.escape): _menu.close,
            },
            child: FocusScope(
              autofocus: true,
              child: Material(
                color: colorScheme.surfaceContainer,
                elevation: 3,
                shape: AppShapes.rounded(AppShapes.extraSmall),
                clipBehavior: Clip.antiAlias,
                child: _content(context),
              ),
            ),
          ),
        ),
      ),
      builder: (context, menu, _) => IconButton(
        key: const Key('sound_player_tune'),
        tooltip: l10n.sound_player_tune,
        isSelected: menu.isOpen,
        onPressed: _toggle,
        icon: Badge(
          isLabelVisible: widget.controller.hasPreview,
          smallSize: 8,
          child: const Icon(Icons.tune),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final l10n = context.l10n;
    final current = widget.current;
    // A volume above 1 only widens the range in the game.
    final maxVolume = max<double>(1, current.volume);
    final labelStyle = Theme.of(context).textTheme.labelMedium;
    // Both sliders start where the longer label ends.
    final labelWidth = [l10n.sound_pitch, l10n.sound_volume]
        .map((label) => _textWidth(context, label, labelStyle))
        .reduce(max);
    return Padding(
      key: const Key('sound_player_tune_menu'),
      padding: _padding,
      child: SizedBox(
        width: _contentWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _ValueSlider(
              key: const Key('sound_player_pitch'),
              label: l10n.sound_pitch,
              labelWidth: labelWidth,
              value: widget.controller.pitchOf(current),
              min: 0.5,
              max: 2,
              divisions: 30,
              onChanged: (value) =>
                  widget.controller.preview(pitch: _round(value)),
            ),
            _ValueSlider(
              key: const Key('sound_player_volume'),
              label: l10n.sound_volume,
              labelWidth: labelWidth,
              value: widget.controller.volumeOf(current),
              min: 0,
              max: maxVolume,
              divisions: (maxVolume * 20).round(),
              onChanged: (value) =>
                  widget.controller.preview(volume: _round(value)),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: l10n.sound_player_reset_tooltip,
                  child: TextButton.icon(
                    key: const Key('sound_player_reset'),
                    onPressed: widget.controller.hasPreview
                        ? widget.controller.resetPreview
                        : null,
                    icon: const Icon(Icons.restart_alt),
                    label: Text(l10n.sound_player_reset),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: l10n.sound_player_apply_tooltip,
                  child: FilledButton.tonalIcon(
                    key: const Key('sound_player_apply'),
                    onPressed: widget.controller.hasPreview && !widget.applying
                        ? widget.onApply
                        : null,
                    icon: const Icon(Icons.check),
                    label: Text(l10n.sound_player_apply),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Play while idle or paused, pause while playing, stop while loading.
class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({required this.status, required this.onPressed});

  final SoundPlaybackStatus status;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final (tooltip, icon) = playButtonContent(status, context.l10n);
    return IconButton.filled(
      key: const Key('sound_player_play_pause'),
      tooltip: tooltip,
      onPressed: onPressed,
      icon: icon,
    );
  }
}

/// How wide [text] lays out in one line in [style].
double _textWidth(BuildContext context, String text, TextStyle? style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    maxLines: 1,
  )..layout();
  final width = painter.width;
  painter.dispose();
  return width.ceilToDouble();
}

/// [text] with every digit as a zero, to measure the room any value of its
/// length takes.
String _zeroed(String text) => text.replaceAll(RegExp('[0-9]'), '0');

typedef _OnSeek = void Function(SoundWaveform waveform, double fraction);

/// The waveform of the current file with its time; a tap jumps there, a drag
/// moves along and jumps where it lets go. A line follows the mouse to show
/// where.
class _SeekableWaveform extends StatefulWidget {
  const _SeekableWaveform({
    required this.future,
    required this.initial,
    required this.position,
    required this.pitch,
    required this.onSeek,
    required this.onScrub,
    required this.onScrubEnd,
    required this.onScrubCancel,
  });

  final Future<SoundWaveform> future;
  final SoundWaveform? initial;
  final ValueNotifier<Duration> position;

  /// The pitch it plays with, for the times as they play in the game.
  final double pitch;
  final _OnSeek onSeek;
  final _OnSeek onScrub;
  final void Function(SoundWaveform waveform) onScrubEnd;
  final VoidCallback onScrubCancel;

  @override
  State<_SeekableWaveform> createState() => _SeekableWaveformState();
}

class _SeekableWaveformState extends State<_SeekableWaveform> {
  /// Where the mouse is along the waveform, from 0 to 1; null outside.
  final ValueNotifier<double?> _hover = ValueNotifier(null);

  @override
  void dispose() {
    _hover.dispose();
    super.dispose();
  }

  String _time(Duration played, Duration total) =>
      '${formatPlayTime(playTimeAt(played, widget.pitch))} / '
      '${formatPlayTime(playTimeAt(total, widget.pitch))}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final timeStyle = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    final onSeek = widget.onSeek;
    final onScrub = widget.onScrub;
    final onScrubEnd = widget.onScrubEnd;
    final onScrubCancel = widget.onScrubCancel;
    final position = widget.position;
    return FutureBuilder<SoundWaveform>(
      future: widget.future,
      initialData: widget.initial,
      builder: (context, snapshot) {
        final waveform = snapshot.data;
        // As wide as the longest time of this file, so the waveform keeps
        // its width while the time runs.
        final timeWidth = _textWidth(
          context,
          waveform == null
              ? '0:00 / 0:00'
              : _zeroed(_time(waveform.duration, waveform.duration)),
          timeStyle,
        );
        return Row(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double fraction(Offset local) =>
                      local.dx / constraints.maxWidth;
                  return MouseRegion(
                    cursor: waveform == null
                        ? MouseCursor.defer
                        : SystemMouseCursors.click,
                    onHover: waveform == null
                        ? null
                        : (event) => _hover.value = fraction(
                            event.localPosition,
                          ).clamp(0.0, 1.0),
                    onExit: (_) => _hover.value = null,
                    child: GestureDetector(
                      key: const Key('sound_player_waveform'),
                      behavior: HitTestBehavior.opaque,
                      onTapDown: waveform == null
                          ? null
                          : (details) => onSeek(
                              waveform,
                              fraction(details.localPosition),
                            ),
                      onHorizontalDragStart: waveform == null
                          ? null
                          : (details) => onScrub(
                              waveform,
                              fraction(details.localPosition),
                            ),
                      onHorizontalDragUpdate: waveform == null
                          ? null
                          : (details) => onScrub(
                              waveform,
                              fraction(details.localPosition),
                            ),
                      onHorizontalDragEnd: waveform == null
                          ? null
                          : (_) => onScrubEnd(waveform),
                      onHorizontalDragCancel: waveform == null
                          ? null
                          : onScrubCancel,
                      child: _WaveformPaint(
                        peaks: waveform?.peaks ?? const [],
                        duration: waveform?.duration,
                        position: position,
                        hover: _hover,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: timeWidth,
              child: ValueListenableBuilder<Duration>(
                valueListenable: position,
                builder: (context, played, _) => Text(
                  waveform == null ? '–:––' : _time(played, waveform.duration),
                  key: const Key('sound_player_time'),
                  style: timeStyle,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The bars of a waveform that grow into new [peaks], e.g. once they are
/// read or another file plays, from what was shown before.
class _WaveformPaint extends StatefulWidget {
  const _WaveformPaint({
    required this.peaks,
    required this.duration,
    required this.position,
    required this.hover,
  });

  final List<double> peaks;
  final Duration? duration;
  final ValueListenable<Duration> position;
  final ValueListenable<double?> hover;

  @override
  State<_WaveformPaint> createState() => _WaveformPaintState();
}

class _WaveformPaintState extends State<_WaveformPaint>
    with SingleTickerProviderStateMixin {
  static const Duration _duration = Duration(milliseconds: 250);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
  );
  late final Animation<double> _transition = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  /// What the bars grow from: flat at first.
  List<double> _previous = const [];
  bool _grown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Not in initState, which can't read the media query yet.
    if (_grown) return;
    _grown = true;
    _grow();
  }

  @override
  void didUpdateWidget(_WaveformPaint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (listEquals(oldWidget.peaks, widget.peaks)) return;
    // From where the bars are now, also halfway through growing.
    _previous = lerpPeaks(_previous, oldWidget.peaks, _transition.value);
    _grow();
  }

  void _grow() {
    final animate = !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);
    if (!animate || widget.peaks.isEmpty && _previous.isEmpty) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return RepaintBoundary(
      child: CustomPaint(
        size: const Size.fromHeight(32),
        painter: SoundWaveformPainter(
          peaks: widget.peaks,
          previous: _previous,
          transition: _transition,
          duration: widget.duration,
          position: widget.position,
          hover: widget.hover,
          played: colorScheme.primary,
          unplayed: colorScheme.outlineVariant,
          marker: colorScheme.onSurface,
        ),
      ),
    );
  }
}

/// A labelled slider with its value.
class _ValueSlider extends StatelessWidget {
  const _ValueSlider({
    required this.label,
    required this.labelWidth,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    super.key,
  });

  final String label;

  /// The width of the longest label, so the sliders line up.
  final double labelWidth;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueStyle = theme.textTheme.bodySmall;
    // As wide as the largest value, so the slider keeps its length.
    final valueWidth = _textWidth(
      context,
      _zeroed(max.toStringAsFixed(2)),
      valueStyle,
    );
    return Row(
      children: [
        SizedBox(
          width: labelWidth,
          child: Text(label, style: theme.textTheme.labelMedium),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            label: value.toStringAsFixed(2),
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: valueWidth,
          child: Text(
            value.toStringAsFixed(2),
            style: valueStyle,
            textAlign: TextAlign.end,
            maxLines: 1,
            softWrap: false,
          ),
        ),
      ],
    );
  }
}
