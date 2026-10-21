import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:tray_manager/tray_manager.dart';

import '../../core/desktop_capabilities.dart';
import '../../core/platform.dart';
import '../../features/player/player_controller.dart';

/// 托盘命令 — 与 EchoMusic `TrayCommand` 对齐。
enum TrayCommand {
  showWindow,
  togglePlayback,
  previous,
  next,
  setMode,
  volumeUp,
  volumeDown,
  toggleDesktopLyric,
  quit,
}

/// 播放态快照，驱动托盘菜单文案 / 勾选 / enabled。
class TrayPlaybackSnapshot {
  const TrayPlaybackSnapshot({
    this.isPlaying = false,
    this.mode = PlayerLoopMode.listLoop,
    this.volume = 1.0,
    this.hasTrack = false,
    this.canStepBack = false,
    this.title = '',
    this.artist = '',
  });

  final bool isPlaying;
  final PlayerLoopMode mode;
  final double volume;
  final bool hasTrack;
  final bool canStepBack;
  final String title;
  final String artist;

  /// 托盘菜单/提示里的当前曲目文案；空串 = 无曲目。
  String get trackLabel {
    final name = title.trim();
    if (name.isEmpty) return '';
    final performer = artist.trim();
    return performer.isEmpty ? name : '$name - $performer';
  }

  TrayPlaybackSnapshot copyWith({
    bool? isPlaying,
    PlayerLoopMode? mode,
    double? volume,
    bool? hasTrack,
    bool? canStepBack,
    String? title,
    String? artist,
  }) {
    return TrayPlaybackSnapshot(
      isPlaying: isPlaying ?? this.isPlaying,
      mode: mode ?? this.mode,
      volume: volume ?? this.volume,
      hasTrack: hasTrack ?? this.hasTrack,
      canStepBack: canStepBack ?? this.canStepBack,
      title: title ?? this.title,
      artist: artist ?? this.artist,
    );
  }
}

/// 托盘端口。非桌面 / 测试用 [NoopTray]。
abstract class TrayPort {
  Future<void> init();
  Future<void> syncPlayback(TrayPlaybackSnapshot snapshot);
  Future<void> destroy();
}

class NoopTray implements TrayPort {
  @override
  Future<void> init() async {}

  @override
  Future<void> syncPlayback(TrayPlaybackSnapshot snapshot) async {}

  @override
  Future<void> destroy() async {}
}

/// Windows / 桌面托盘。左键恢复主窗，右键弹出菜单（对齐 EchoMusic）。
class DesktopTray with TrayListener implements TrayPort {
  DesktopTray({
    required this.onShowWindow,
    required this.onTogglePlayback,
    required this.onPrevious,
    required this.onNext,
    required this.onSetMode,
    required this.onVolumeDelta,
    required this.onToggleDesktopLyric,
    required this.onQuit,
  });

  final FutureOr<void> Function() onShowWindow;
  final FutureOr<void> Function() onTogglePlayback;
  final FutureOr<void> Function() onPrevious;
  final FutureOr<void> Function() onNext;
  final FutureOr<void> Function(PlayerLoopMode mode) onSetMode;

  /// [delta] 为音量增量（0–1 量纲，如 ±0.05）。
  final FutureOr<void> Function(double delta) onVolumeDelta;
  final FutureOr<void> Function() onToggleDesktopLyric;
  final FutureOr<void> Function() onQuit;

  TrayPlaybackSnapshot _snapshot = const TrayPlaybackSnapshot();
  String? _lastTooltip;
  bool _desktopLyricOn = false;
  bool _ready = false;
  bool _iconCreated = false;
  bool get isReady => _ready;

  @override
  Future<void> init() async {
    if (_ready) return;
    await trayManager.setIcon(resolveTrayIconPath());
    _iconCreated = true;
    await _updateTooltip();
    trayManager.addListener(this);
    await _rebuildMenu();
    _ready = true;
  }

  @override
  Future<void> syncPlayback(TrayPlaybackSnapshot snapshot) async {
    _snapshot = snapshot;
    if (!_ready) return;
    await _rebuildMenu();
    await _updateTooltip();
  }

  Future<void> _updateTooltip() async {
    if (!DesktopCapabilities.current.trayTooltip) return;
    final label = _snapshot.trackLabel;
    final tooltip = label.isEmpty ? '泛音' : '泛音 · $label';
    if (tooltip == _lastTooltip) return;
    _lastTooltip = tooltip;
    await trayManager.setToolTip(tooltip);
  }

  /// 同步「桌面歌词」勾选态（设置页 / 歌词窗关闭时都会走到这里）。
  Future<void> setDesktopLyricEnabled(bool enabled) async {
    if (_desktopLyricOn == enabled) return;
    _desktopLyricOn = enabled;
    if (!_ready) return;
    await _rebuildMenu();
  }

  @override
  Future<void> destroy() async {
    if (!_ready && !_iconCreated) return;
    _ready = false;
    _iconCreated = false;
    trayManager.removeListener(this);
    try {
      await trayManager.destroy();
    } catch (_) {}
  }

  @override
  void onTrayIconMouseDown() {
    unawaited(Future(() => onShowWindow()));
  }

  @override
  void onTrayIconRightMouseDown() {
    // AppIndicator displays its menu itself; this method has no Linux native
    // implementation in tray_manager 0.5.x.
    if (isLinuxPlatform) return;
    unawaited(trayManager.popUpContextMenu());
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    final key = menuItem.key;
    if (key == null) return;
    if (key.startsWith('mode_')) {
      final name = key.substring('mode_'.length);
      final mode = PlayerLoopMode.values
          .where((m) => m.name == name)
          .firstOrNull;
      if (mode != null) unawaited(Future(() => onSetMode(mode)));
      return;
    }
    switch (key) {
      case 'show_window':
        unawaited(Future(() => onShowWindow()));
      case 'toggle_playback':
        if (_snapshot.hasTrack) unawaited(Future(() => onTogglePlayback()));
      case 'previous':
        if (_snapshot.hasTrack && _snapshot.canStepBack) {
          unawaited(Future(() => onPrevious()));
        }
      case 'next':
        if (_snapshot.hasTrack) unawaited(Future(() => onNext()));
      case 'volume_up':
        unawaited(Future(() => onVolumeDelta(0.05)));
      case 'volume_down':
        unawaited(Future(() => onVolumeDelta(-0.05)));
      case 'desktop_lyric':
        unawaited(Future(() => onToggleDesktopLyric()));
      case 'quit':
        unawaited(Future(() => onQuit()));
    }
  }

  Future<void> _rebuildMenu() async {
    final s = _snapshot;
    final volumePct = (s.volume * 100).round().clamp(0, 100);
    await trayManager.setContextMenu(
      Menu(
        items: [
          if (s.trackLabel.isNotEmpty) ...[
            MenuItem(key: 'now_playing', label: s.trackLabel, disabled: true),
            MenuItem.separator(),
          ],
          MenuItem(key: 'show_window', label: '显示窗口'),
          MenuItem.separator(),
          MenuItem(
            key: 'toggle_playback',
            label: s.isPlaying ? '暂停' : '播放',
            disabled: !s.hasTrack,
          ),
          MenuItem(
            key: 'previous',
            label: '上一首',
            disabled: !s.hasTrack || !s.canStepBack,
          ),
          MenuItem(key: 'next', label: '下一首', disabled: !s.hasTrack),
          MenuItem(
            key: 'play_mode',
            label: '播放模式',
            disabled: !s.hasTrack,
            submenu: Menu(
              items: [
                for (final mode in PlayerLoopMode.values)
                  MenuItem(
                    key: 'mode_${mode.name}',
                    label: mode.label,
                    type: 'checkbox',
                    checked: s.mode == mode,
                  ),
              ],
            ),
          ),
          MenuItem.separator(),
          MenuItem(
            key: 'volume_label',
            label: '音量 $volumePct%',
            disabled: true,
          ),
          MenuItem(key: 'volume_up', label: '增大音量'),
          MenuItem(key: 'volume_down', label: '减小音量'),
          if (supportsDesktopLyrics) ...[
            MenuItem.separator(),
            MenuItem(
              key: 'desktop_lyric',
              label: '桌面歌词',
              type: 'checkbox',
              checked: _desktopLyricOn,
            ),
          ],
          MenuItem.separator(),
          MenuItem(key: 'quit', label: '退出'),
        ],
      ),
    );
  }
}

/// 运行时解析托盘图标文件路径（tray_manager 需要真实文件路径，不能走 asset 字节）。
String resolveTrayIconPath() {
  final filename = isWindowsPlatform ? 'tray_icon.ico' : 'tray_icon.png';
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    final fromExe = p.join(
      p.dirname(Platform.resolvedExecutable),
      'data',
      'flutter_assets',
      'assets',
      filename,
    );
    if (File(fromExe).existsSync()) return fromExe;
  }
  return p.join('assets', filename);
}
