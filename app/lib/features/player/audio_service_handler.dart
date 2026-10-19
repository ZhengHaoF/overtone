import 'package:audio_service/audio_service.dart';

import '../../core/models/track.dart';
import 'player_controller.dart';

/// System media notification / lock screen / Bluetooth (AVRCP) handler.
///
/// How the pieces map onto a car head unit:
/// * total duration  -> [MediaItem.duration] (media metadata)
/// * elapsed / bar   -> [PlaybackState.updatePosition] (MediaSession snapshot)
///
/// The platform does **not** extrapolate that position for us, and Android's
/// AVRCP target permanently stops sending `EVENT_PLAYBACK_POS_CHANGED` once two
/// consecutive reads return the same value. [PlayerController] therefore pushes
/// a fresh, monotonically increasing position on a steady tick.
///
/// Seek-related [systemActions] must also be declared or many head units never
/// show / refresh the position bar even when duration is present.
class OvertoneAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler
    implements OvertoneMediaBridge {
  OvertoneAudioHandler(this._controller);

  /// Enables notification/lock-screen seek bar and MediaSession ACTION_SEEK_TO
  /// (required by audio_service; not auto-enabled on Android).
  ///
  /// Also keep the raw transport actions here: a head unit that has dropped its
  /// transport slot (the carousel bug below) falls back to the session action
  /// list to build *any* UI at all, so this must never be empty.
  static const _systemActions = {
    MediaAction.seek,
    MediaAction.seekForward,
    MediaAction.seekBackward,
    MediaAction.play,
    MediaAction.pause,
    MediaAction.playPause,
    MediaAction.skipToNext,
    MediaAction.skipToPrevious,
    MediaAction.stop,
  };

  /// Fixed capacity of the notification / AVRCP action carousel.
  ///
  /// audio_service supports at most 3 action slots and all head units index the
  /// carousel positionally, so the layout must never change shape at runtime.
  /// Emitting a different number of controls on every play/pause used to
  /// desynchronise the car's cached list — after which the head unit no longer
  /// matched `Play`/`Pause` to an index, and media commands (and with them the
  /// position notifications the progress bar needs) stopped arriving.
  static const _compactIndices = [0, 1, 2];

  final PlayerController _controller;

  /// Last buffered position reported by the engine. Some head units (and the
  /// Android notification progress bar) read this as a secondary bar.
  Duration _bufferedPosition = Duration.zero;

  @override
  Future<void> play() async {
    final snapshot = _controller.snapshot;
    // 取流/切歌期间 `isPlaying` 为 false 但播放意图仍在。此时放行会让
    // togglePlay() 命中「isLoading && _wantPlaying」分支，把播放意图清掉，
    // 下一首随后以 play:false 灌入引擎并 pause —— 蓝牙/车机看到会话中途
    // paused 后回送 play，踩的正是这条。
    if (!snapshot.isPlaying && !_controller.wantsPlaying) {
      _controller.togglePlay();
    }
  }

  @override
  Future<void> pause() async {
    final snapshot = _controller.snapshot;
    // 与 play() 同口径：加载窗口里的 pause 也要能停（意图为播放才算「在播」）。
    if (snapshot.isPlaying || _controller.wantsPlaying) {
      _controller.togglePlay();
    }
  }

  @override
  Future<void> skipToNext() => _controller.next();

  @override
  Future<void> skipToPrevious() => _controller.previous();

  /// 车机 / 蓝牙的「随机」按钮。
  ///
  /// 随机模式在播放器侧是「队列重排」（见 `shuffle_order.dart`），但对系统
  /// 会话来说就是一个 shuffle 开关：打开 → 切入随机，关闭 → 切回顺序播放。
  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    switch (shuffleMode) {
      case AudioServiceShuffleMode.all:
        _controller.setMode(PlayerLoopMode.shuffle);
      case AudioServiceShuffleMode.none:
        // 关掉随机 = 回到顺序播放（不落在列表循环上）。只在确实是随机时
        // 才动模式，否则会把单曲循环/顺序播放顶掉。
        if (_controller.snapshot.mode == PlayerLoopMode.shuffle) {
          _controller.setMode(PlayerLoopMode.order);
        }
      case AudioServiceShuffleMode.group:
        // 无分组概念：按「整队随机」处理，别把车机按钮按成没反应。
        _controller.setMode(PlayerLoopMode.shuffle);
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    final current = _controller.snapshot.mode;
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        _controller.setMode(PlayerLoopMode.order);
      case AudioServiceRepeatMode.one:
        _controller.setMode(PlayerLoopMode.single);
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
        // 随机是对「整队」的修饰，重复整队时不该把它关掉。
        if (current != PlayerLoopMode.shuffle) {
          _controller.setMode(PlayerLoopMode.listLoop);
        }
    }
  }

  @override
  Future<void> seek(Duration position) {
    _controller.seekTo(position.inMilliseconds);
    return Future.value();
  }

  @override
  Future<void> stop() async {
    // Full teardown: pause the engine *and* drop back to idle. Merely pausing
    // would leave audio running behind a stopped session.
    await _controller.stopPlayback();
    _broadcast(
      playing: false,
      processing: AudioProcessingState.idle,
      position: Duration.zero,
    );
  }

  @override
  Future<void> onTaskRemoved() async {
    // The OS is tearing the app down; release audio rather than leaving a
    // foreground playback service that no UI can control any more.
    await _controller.stopPlayback();
  }

  /// Notification swiped away.
  ///
  /// Must NOT delegate to [stop]: `BaseAudioHandler.stop()` moves the session to
  /// idle, and audio_service then sends `stopService`, whose native side calls
  /// `deactivateMediaSession()` *and* `stopSelf()` — tearing the service down for
  /// good. The framework reuses the same service (and the same
  /// `OvertoneAudioHandler`) for the next `play()`, so a swipe would leave every
  /// later session dead: no notification, no AVRCP, no progress bar. Just pause
  /// and drop the notification instead.
  @override
  Future<void> onNotificationDeleted() async {
    await _controller.stopPlayback();
    _broadcast(
      playing: false,
      processing: AudioProcessingState.idle,
      position: Duration.zero,
    );
  }

  @override
  void sync({
    required bool playing,
    required AudioProcessingState processing,
    required Duration position,
    Duration bufferedPosition = Duration.zero,
    Track? track,
    String? subtitle,
  }) {
    _bufferedPosition = bufferedPosition;
    if (track != null) {
      mediaItem.add(_mediaItemFor(track, subtitle));
    }
    final wasPlaying = playbackState.value.playing;
    _broadcast(playing: playing, processing: processing, position: position);
    if (wasPlaying != playing) _reannounceCarousel();
  }

  @override
  void updatePosition(Duration position, {Duration? bufferedPosition}) {
    if (bufferedPosition != null) _bufferedPosition = bufferedPosition;
    final prev = playbackState.value;
    _broadcast(
      playing: prev.playing,
      processing: prev.processingState,
      position: position,
    );
  }

  @override
  void syncQueue(List<Track> tracks, int currentIndex) {
    queue.add([for (final track in tracks) _mediaItemFor(track, null)]);
  }

  @override
  void updateMediaSubtitle(String subtitle) {
    final track = _controller.snapshot.current;
    if (track == null) return;
    mediaItem.add(_mediaItemFor(track, subtitle));
  }

  MediaItem _mediaItemFor(Track track, String? subtitle) {
    final secondary =
        (subtitle == null || subtitle.isEmpty) ? track.artist : subtitle;
    return MediaItem(
      id: track.identityKey,
      title: track.name,
      artist: secondary,
      displaySubtitle: secondary,
      album: track.album,
      duration: Duration(milliseconds: track.durationMs),
      artUri: Uri.tryParse(track.coverUrl),
    );
  }

  void _broadcast({
    required bool playing,
    required AudioProcessingState processing,
    required Duration position,
  }) {
    final ready = processing == AudioProcessingState.ready;
    final mode = _controller.snapshot.mode;
    // Guard against a zero/overshoot buffered value: a position outside
    // (0, duration) makes the MediaSession seek bar unsupported on some
    // Android builds, which cancels the progress line entirely.
    final duration = mediaItem.value?.duration;
    var buffered = _bufferedPosition;
    if (buffered <= Duration.zero) {
      buffered = Duration.zero;
    } else if (duration != null && duration > Duration.zero) {
      buffered = buffered > duration ? duration : buffered;
    }
    playbackState.add(
      PlaybackState(
        controls: _controls(playing: playing),
        systemActions: _systemActions,
        androidCompactActionIndices: _compactIndices,
        processingState: processing,
        playing: playing,
        updatePosition: position,
        bufferedPosition: buffered,
        // MediaSession / AVRCP project progress as
        // position + speed * (now - updateTime). Keep speed non-zero only
        // while actually playing so a paused track does not creep forward.
        speed: (playing && ready) ? 1.0 : 0.0,
        queueIndex: _controller.snapshot.queue.isEmpty
            ? null
            : _controller.snapshot.currentIndex,
        // 不报这两个字段，车机/Android Auto 的随机与循环按钮就不回显，
        // 按下去也拿不到反馈（MPRIS 那边读的是 snapshot，默认不受影响）。
        shuffleMode: _shuffleModeOf(mode),
        repeatMode: _repeatModeOf(mode),
      ),
    );
  }

  AudioServiceShuffleMode _shuffleModeOf(PlayerLoopMode mode) =>
      mode == PlayerLoopMode.shuffle
      ? AudioServiceShuffleMode.all
      : AudioServiceShuffleMode.none;

  AudioServiceRepeatMode _repeatModeOf(PlayerLoopMode mode) => switch (mode) {
    PlayerLoopMode.single => AudioServiceRepeatMode.one,
    // 顺序播放播到底就停，列表循环/随机都绕回队列头。
    PlayerLoopMode.order => AudioServiceRepeatMode.none,
    PlayerLoopMode.listLoop || PlayerLoopMode.shuffle =>
      AudioServiceRepeatMode.all,
  };

  /// Fixed-shape carousel, always three slots.
  ///
  /// Slot 1 swaps between pause and play so the action *count* never changes;
  /// audio_service itself only requires the declared action support to match
  /// the icon it renders (see `AudioService.java`, which asserts exactly that).
  /// A varying length is what desynchronises a head unit's cached action list.
  List<MediaControl> _controls({required bool playing}) => [
        MediaControl.skipToPrevious,
        playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
      ];

  /// Total number of carousel slots, as the AVRCP target computes it.
  int get _actionCount => _compactIndices.length.clamp(0, 3);

  /// Re-announce the AVRCP key event behind [slot].
  ///
  /// Android's AVRCP target only notifies a head unit once per *slot*, and the
  /// action id sitting behind that slot can change without any new event. A car
  /// that has cached "slot 1 = play" therefore keeps rendering a play triangle
  /// after we flip to pause — and, worse, keeps sending the matching command.
  /// Pushing a state that differs in [PlaybackState.androidCompactActionIndices]
  /// makes the plugin rebuild the notification action list
  /// (`setState()` compares `compactActionIndices` and `controls`), so the
  /// framework re-derives `getActions()` and the head unit re-reads it.
  ///
  /// [PlaybackState] exposes no field for the derived action mask and
  /// `BasicPlaybackState` does not exist in audio_service 0.18.x, so the
  /// supported-set trick is not available here. Layout and transport-support
  /// changes are driven by `controls` / `systemActions` in [_broadcast], which
  /// is the only thing the plugin actually reads.
  ///
  /// NB: `androidCompactActionIndices` entries are **indices into [controls]**,
  /// not AVRCP keycodes. The plugin passes them straight to
  /// `Notification.MediaStyle.setShowActionsInCompactView()`, which indexes the
  /// action list, so anything outside `[0, controls.length)` is out of range.
  /// An earlier revision pushed the AVRCP keycodes here
  /// (SKIP_TO_PREVIOUS=11, PAUSE=5, PLAY=1, NEXT=9 — see
  /// `PlaybackStateCompat.toKeyCode()`), i.e. it asked the framework to render
  /// action #11 of a 3-action notification.
  void _reannounceCarousel() {
    final prev = playbackState.value;
    final count = _actionCount;
    if (count == 0) return;
    for (var slot = 0; slot < count; slot++) {
      // Collapse to a single slot so the list really differs from what the
      // plugin last saw, then restore the full carousel afterwards.
      playbackState.add(
        prev.copyWith(androidCompactActionIndices: [slot]),
      );
    }
    playbackState.add(prev.copyWith(androidCompactActionIndices: _compactIndices));
  }
}
