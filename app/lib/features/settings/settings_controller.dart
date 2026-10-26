import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/cache/cover_cache.dart';
import '../../core/models/audio_quality.dart';
import '../../core/models/barrage.dart';
import '../../core/source/features.dart';
import '../../core/source/music_platform.dart';
import '../../core/theme/overtone_tokens.dart';
import '../../data/storage/queue_store.dart';
import '../search/search_history_controller.dart';
import '../desktop_lyric/desktop_lyric_style.dart';

export '../../core/models/audio_quality.dart' show AppQuality, AppQualityX;

enum SleepTimerMode { off, m15, m30, m60, custom }

enum AppThemeMode { dark, light, system }

/// 歌词字号倍率可调范围（1.0 = 默认字号）。
///
/// 应用内歌词、桌面歌词窗、安卓悬浮窗共用这一个值。范围取统一前两套
/// （应用内 0.8–1.6、桌面歌词样式 0.6–2.0）的并集，避免升级后有人
/// 可用档位变少。
const double kLyricFontScaleMin = 0.6;
const double kLyricFontScaleMax = 2.0;

/// 歌词行间距倍率可调范围。
///
/// 语义：**行盒高度 = 本曲文字实际高度 × 该倍率**（见
/// `lyrics_view._minExtent`）。所以 1.0 = 行盒贴住文字，再低只会裁字。
const double kLyricSpacingScaleMin = 1.0;

/// 上限 3.0：单行 18px 歌词（含 1.35 行高）约 24.3，×3 ≈ 73；桌面端 22px
/// 约 89。再往上就一屏只剩三四行。
const double kLyricSpacingScaleMax = 3.0;

/// 默认行间距：单行行盒约为文字的 1.5 倍（移动端 24.3 → 36.5）。
const double kLyricSpacingScaleDefault = 1.5;

/// Desktop: what the window close button does.
///
/// `ask` is the "don't remember" state — the close prompt shows every time,
/// unless the user ticks「记住我的选择」there (which persists `tray` / `quit`).
enum CloseBehavior { ask, tray, quit }

extension CloseBehaviorX on CloseBehavior {
  String get label => switch (this) {
    CloseBehavior.ask => '每次询问',
    CloseBehavior.tray => '最小化到托盘',
    CloseBehavior.quit => '退出应用',
  };

  /// Settings-row subtitle / close-prompt hint.
  String get closeHint => switch (this) {
    CloseBehavior.ask => '关闭时弹出提示，可勾选「记住我的选择」',
    CloseBehavior.tray => '关闭时最小化到系统托盘，不退出应用',
    CloseBehavior.quit => '关闭时直接退出应用',
  };
}

class AppSettings {
  const AppSettings({
    this.quality = AppQuality.hq,
    this.sleepMode = SleepTimerMode.off,
    this.sleepCustomMinutes = 45,
    this.wifiCoverOnly = false,
    this.lyricTranslation = true,
    this.lyricRomanization = false,
    this.lyricFontScale = 1,
    this.lyricSpacingScale = kLyricSpacingScaleDefault,
    this.mediaLyricSubtitle = false,
    this.mvBarrageEnabled = false,
    this.mvAudioFallbackEnabled = false,
    this.mvBarrageConfig = BarrageConfig.defaults,
    this.themeMode = AppThemeMode.light,
    this.accent = OvertoneAccent.teal,
    this.archiveSkin = false,
    this.closeBehavior = CloseBehavior.ask,
    this.taskbarProgress = true,
    this.taskbarCoverPreview = false,
    this.taskbarMediaBar = false,
    this.volume = 1.0,
    this.speed = 1.0,
    this.desktopLyricEnabled = false,
    this.desktopLyricLocked = false,
    this.lyricOffsetMs = 0,
    this.lyricOffsetOverrides = const {},
    this.desktopLyricStyle = const DesktopLyricStyle(),
    this.defaultSource = MusicPlatform.kugou,
    // 新装只开酷狗：网易云由登录态并入（[SettingsController.setNeteaseAccess]），
    // B 站要在设置里手动开。存量用户不迁移——enabledSources 是持久化配置，
    // 默认集改动只影响全新安装。
    this.enabledSources = const {MusicPlatform.kugou},
    this.disabledFeatures = const {},
  });

  final AppQuality quality;
  final SleepTimerMode sleepMode;
  final int sleepCustomMinutes;
  final bool wifiCoverOnly;

  /// 歌词副行：译文（KRC `[language:]` type=1）。
  final bool lyricTranslation;

  /// 歌词副行：音译/罗马音（type=0）。默认关，中文歌收益低。
  final bool lyricRomanization;

  /// 歌词字号倍率（[kLyricFontScaleMin]–[kLyricFontScaleMax]，1.0 = 默认）。
  /// 主行/副行字号与行盒同步缩放；桌面歌词窗、安卓悬浮窗也按它渲染
  /// （[DesktopLyricStyle] 里不再有独立字号，全局只有这一个字号）。
  final double lyricFontScale;

  /// 歌词行间距倍率（[kLyricSpacingScaleMin]–[kLyricSpacingScaleMax]）。
  /// 行盒高度 = 本曲文字实际高度 × 该倍率，与字号独立。
  final double lyricSpacingScale;

  /// System media (lock screen / Bluetooth) subtitle shows `artist · lyric`.
  final bool mediaLyricSubtitle;

  /// MV 弹幕总开关（对齐 EchoMusic `mvBarrageEnabled`）。默认关。
  final bool mvBarrageEnabled;

  /// 播放失败时借用关联曲库 MV 的音轨兜底（对齐 EchoMusic MV 音频兜底）。默认关。
  ///
  /// 兜底拿到的是 MV 的音轨，可能是现场版/剪辑版，歌词时间轴与时长都可能
  /// 与歌曲对不上，因此默认关闭、由用户显式开启。
  final bool mvAudioFallbackEnabled;

  /// MV 弹幕显示配置（透明度 / 字号 / 速度 / 区域 / 密度）。
  final BarrageConfig mvBarrageConfig;

  final AppThemeMode themeMode;

  /// 主题强调色（默认青绿，取自应用图标）。
  final OvertoneAccent accent;

  /// 实验性「极简风格 UI」皮肤（全站，白底墨色）。
  ///
  /// 只在浅色 + 桌面双栏形态下生效，见 `ArchiveSkin.resolve`；深色与移动端一律
  /// 沿用标准皮肤，避免半迁移的观感。
  final bool archiveSkin;

  /// Desktop only: what the window close button does (ask / tray / quit).
  final CloseBehavior closeBehavior;

  /// Windows only: taskbar button progress bar (Echo「任务栏播放进度条」).
  final bool taskbarProgress;
  final bool taskbarCoverPreview;
  final bool taskbarMediaBar;

  /// 播放音量（0.0–1.0）。落盘记忆，重启不回 100%。
  final double volume;

  /// 播放倍速（1.0 = 正常）。运行时态在 `PlayerState.speed`，这里只做落盘；
  /// clamp 边界见 `kPlaySpeedMin` / `kPlaySpeedMax`（不 import 播放层，
  /// 避免 settings ← player 的循环依赖，边界值以注释同步维护）。
  final double speed;

  /// 桌面歌词窗口是否打开（启动恢复 + 托盘/设置同步）。
  final bool desktopLyricEnabled;

  /// 桌面歌词锁定（点击穿透）。
  final bool desktopLyricLocked;

  /// 歌词时间偏移（ms），正 = 歌词提前。
  ///
  /// 全局默认值：应用内歌词视图与桌面歌词窗都用它，再叠加该曲的逐曲微调
  /// （[lyricOffsetOverrides]）。
  final int lyricOffsetMs;

  /// 逐曲时间微调：`Track.identityKey` → ms（叠加在 [lyricOffsetMs] 上）。
  ///
  /// 只存「被用户调过的曲目」，缺省即 0；对齐 EchoMusic `timeOffsetMap`
  /// + `globalTimeOffsetMs` 的叠加口径。
  final Map<String, int> lyricOffsetOverrides;

  /// 当前曲生效的歌词偏移：全局默认 + 该曲微调。
  int lyricOffsetFor(String? trackKey) {
    if (trackKey == null) return lyricOffsetMs;
    return lyricOffsetMs + (lyricOffsetOverrides[trackKey] ?? 0);
  }

  /// 该曲是否被逐曲微调过（UI 据此显示「已微调 / 重置」）。
  bool hasLyricOffsetOverride(String? trackKey) =>
      trackKey != null && lyricOffsetOverrides.containsKey(trackKey);

  /// 桌面歌词 / 悬浮窗外观：颜色 / 描边 / 背景深度 / 字重。
  /// 字号不在这里——全局统一用 [lyricFontScale]。
  final DesktopLyricStyle desktopLyricStyle;

  /// 默认音源：搜索页音源筛选与「我喜欢」页源筛选的初始值（用户当次仍可切换）。
  final MusicPlatform defaultSource;

  /// 启用的音源（整源开关）。默认只含酷狗；空集合非法，setter 会拒绝。
  ///
  /// 只影响「新内容的入口」：搜索混排、源筛选条、默认源选择器与
  /// 单源功能页（FM/榜单/日推/发现）的空态。已在播放队列中的曲目
  /// 不受影响（播放器按曲目平台取源，不经此开关）。
  ///
  /// **网易云需登录才生效**：未登录时它不在此集合里（[SettingsController.setNeteaseAccess]），
  /// 避免「没登录却在各页出网易云」。B 站新装默认关闭，由用户在设置里开启，
  /// 开启后不再依赖登录态。
  final Set<MusicPlatform> enabledSources;

  /// 被**关闭**的「源 × 功能」子开关（[SourceFeature.tokenFor] 的集合）。
  ///
  /// 存「关闭项」而不是「启用项」：缺省（老数据 / 以后新增的功能）= 全开，
  /// 既不需要迁移，也不会让新加的功能一上线就是关的。允许全关——父开关
  /// 关闭时子项只是置灰、取值保留，重新启用父开关即恢复。
  final Set<String> disabledFeatures;

  /// 子开关**自身**的取值（不含父开关），供设置页显示。
  bool isFeatureOn(MusicPlatform p, SourceFeature f) =>
      !disabledFeatures.contains(f.tokenFor(p));

  /// 实际是否生效：父（整源）+ 子（功能）两级 AND。消费点一律用这个。
  bool isFeatureEnabled(MusicPlatform p, SourceFeature f) =>
      enabledSources.contains(p) && isFeatureOn(p, f);

  /// 空态归因用：有「启用中、但该功能被单独关掉」的源 → 返回该功能（页面
  /// 提示「这一项已关闭」）；一个都没有 → 返回 null（页面提示「音源已停用」，
  /// 因为此时锅在整源开关或该源压根没这个能力）。
  ///
  /// 不拿 [effectiveDefaultSource] 判断：它按定义必然落在启用集里，永远为真。
  SourceFeature? featureSwitchCause(SourceFeature f) =>
      enabledSources.any((p) => !isFeatureOn(p, f)) ? f : null;

  /// 默认源被停用后的回退值：按枚举序取第一个仍启用的源。
  MusicPlatform get effectiveDefaultSource =>
      enabledSources.contains(defaultSource)
      ? defaultSource
      : MusicPlatform.values.firstWhere(
          enabledSources.contains,
          orElse: () => MusicPlatform.kugou,
        );

  String get defaultSourceLabel => defaultSource.label;

  ThemeMode get materialThemeMode => switch (themeMode) {
    AppThemeMode.dark => ThemeMode.dark,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.system => ThemeMode.system,
  };

  String get themeModeLabel => switch (themeMode) {
    AppThemeMode.dark => '深色',
    AppThemeMode.light => '浅色',
    AppThemeMode.system => '跟随系统',
  };

  int get sleepMinutes => switch (sleepMode) {
    SleepTimerMode.off => 0,
    SleepTimerMode.m15 => 15,
    SleepTimerMode.m30 => 30,
    SleepTimerMode.m60 => 60,
    SleepTimerMode.custom => sleepCustomMinutes,
  };

  String get qualityLabel => quality.label;

  /// 概念版 `/v5/url` 的 quality 参数（song_url.js：quality || 128）。
  String get qualityParam => quality.param;

  AppSettings copyWith({
    AppQuality? quality,
    SleepTimerMode? sleepMode,
    int? sleepCustomMinutes,
    bool? wifiCoverOnly,
    bool? lyricTranslation,
    bool? lyricRomanization,
    double? lyricFontScale,
    double? lyricSpacingScale,
    bool? mediaLyricSubtitle,
    bool? mvBarrageEnabled,
    bool? mvAudioFallbackEnabled,
    BarrageConfig? mvBarrageConfig,
    AppThemeMode? themeMode,
    OvertoneAccent? accent,
    bool? archiveSkin,
    CloseBehavior? closeBehavior,
    bool? taskbarProgress,
    bool? taskbarCoverPreview,
    bool? taskbarMediaBar,
    double? volume,
    double? speed,
    bool? desktopLyricEnabled,
    bool? desktopLyricLocked,
    int? lyricOffsetMs,
    Map<String, int>? lyricOffsetOverrides,
    DesktopLyricStyle? desktopLyricStyle,
    MusicPlatform? defaultSource,
    Set<MusicPlatform>? enabledSources,
    Set<String>? disabledFeatures,
  }) {
    return AppSettings(
      quality: quality ?? this.quality,
      sleepMode: sleepMode ?? this.sleepMode,
      sleepCustomMinutes: sleepCustomMinutes ?? this.sleepCustomMinutes,
      wifiCoverOnly: wifiCoverOnly ?? this.wifiCoverOnly,
      lyricTranslation: lyricTranslation ?? this.lyricTranslation,
      lyricRomanization: lyricRomanization ?? this.lyricRomanization,
      lyricFontScale: lyricFontScale ?? this.lyricFontScale,
      lyricSpacingScale: lyricSpacingScale ?? this.lyricSpacingScale,
      mediaLyricSubtitle: mediaLyricSubtitle ?? this.mediaLyricSubtitle,
      mvBarrageEnabled: mvBarrageEnabled ?? this.mvBarrageEnabled,
      mvAudioFallbackEnabled:
          mvAudioFallbackEnabled ?? this.mvAudioFallbackEnabled,
      mvBarrageConfig: mvBarrageConfig ?? this.mvBarrageConfig,
      themeMode: themeMode ?? this.themeMode,
      accent: accent ?? this.accent,
      archiveSkin: archiveSkin ?? this.archiveSkin,
      closeBehavior: closeBehavior ?? this.closeBehavior,
      taskbarProgress: taskbarProgress ?? this.taskbarProgress,
      taskbarCoverPreview: taskbarCoverPreview ?? this.taskbarCoverPreview,
      taskbarMediaBar: taskbarMediaBar ?? this.taskbarMediaBar,
      volume: volume ?? this.volume,
      speed: speed ?? this.speed,
      desktopLyricEnabled: desktopLyricEnabled ?? this.desktopLyricEnabled,
      desktopLyricLocked: desktopLyricLocked ?? this.desktopLyricLocked,
      lyricOffsetMs: lyricOffsetMs ?? this.lyricOffsetMs,
      lyricOffsetOverrides: lyricOffsetOverrides ?? this.lyricOffsetOverrides,
      desktopLyricStyle: desktopLyricStyle ?? this.desktopLyricStyle,
      defaultSource: defaultSource ?? this.defaultSource,
      enabledSources: enabledSources ?? this.enabledSources,
      disabledFeatures: disabledFeatures ?? this.disabledFeatures,
    );
  }
}

class SettingsController extends Notifier<AppSettings> {
  static const _kQuality = 'settings.quality';
  static const _kSleep = 'settings.sleep';
  static const _kSleepCustom = 'settings.sleepCustom';
  static const _kWifiCover = 'settings.wifiCover';
  static const _kLyricTr = 'settings.lyricTranslation';
  static const _kLyricRo = 'settings.lyricRomanization';
  static const _kLyricFontScale = 'settings.lyricFontScale';
  static const _kLyricSpacingScaleV2 = 'settings.lyricSpacingScaleV2';

  /// 旧语义（行盒 = 56 基准 × 倍率）的键，只读不写，用于一次性折算。
  static const _kLyricSpacingScaleLegacy = 'settings.lyricSpacingScale';
  static const _kMediaLyric = 'settings.mediaLyricSubtitle';
  static const _kMvBarrageEnabled = 'settings.mvBarrageEnabled';
  static const _kMvAudioFallbackEnabled = 'settings.mvAudioFallbackEnabled';
  static const _kMvBarrageConfig = 'settings.mvBarrageConfig';
  static const _kThemeMode = 'settings.themeMode';
  static const _kAccent = 'settings.accent';
  static const _kArchiveSkin = 'settings.archiveSkin';

  /// 旧键：皮肤只覆盖播放页时用的名字，读取时兼容，写入一律用新键。
  static const _kArchiveSkinLegacy = 'settings.playerSkinArchive';
  static const _kCloseBehavior = 'settings.closeBehavior';

  /// Legacy boolean key (`closeToTray`); read once for migration, then removed.
  static const _kCloseToTrayLegacy = 'settings.closeToTray';
  static const _kTaskbarProgress = 'settings.taskbarProgress';
  static const _kTaskbarCoverPreview = 'settings.taskbarCoverPreview';
  static const _kTaskbarMediaBar = 'settings.taskbarMediaBar';
  static const _kVolume = 'settings.volume';
  static const _kSpeed = 'settings.speed';
  static const _kDesktopLyricEnabled = 'settings.desktopLyricEnabled';
  static const _kDesktopLyricLocked = 'settings.desktopLyricLocked';

  /// 全局歌词偏移的落盘键。键名沿用桌面歌词时代的 `desktopLyricOffsetMs`：
  /// 改名会丢掉存量用户已存的偏移值，而这个偏移现在同时服务应用内歌词。
  static const _kLyricOffsetMs = 'settings.desktopLyricOffsetMs';
  static const _kLyricOffsetOverrides = 'settings.lyricOffsetOverrides';
  static const _kDesktopLyricStyle = 'settings.desktopLyricStyle';
  static const _kDefaultSource = 'settings.defaultSource';
  static const _kEnabledSources = 'settings.enabledSources';
  static const _kDisabledFeatures = 'settings.disabledFeatures';

  @override
  AppSettings build() {
    _restoreFuture = _restore();
    return const AppSettings();
  }

  Future<void>? _restoreFuture;

  /// Lets `main()` wait for persisted settings before the first frame, so the
  /// app never paints one theme and then flips to the saved one.
  Future<void> ensureRestored() async {
    await (_restoreFuture ??= _restore());
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final q = prefs.getString(_kQuality);
      final s = prefs.getString(_kSleep);
      final themeName = prefs.getString(_kThemeMode);
      final accentName = prefs.getString(_kAccent);
      // 统一字号迁移：用户没调过统一滑块、但旧版「桌面歌词样式」里存过
      // 独立字号时，把旧值接过来（见 [_readLegacyStyleFontScale]），
      // 否则升级后桌面歌词 / 悬浮窗的字号会被重置回 100%。
      final fontScale = prefs.getString(_kLyricFontScale) != null
          ? _readScale(
              prefs,
              _kLyricFontScale,
              kLyricFontScaleMin,
              kLyricFontScaleMax,
            )
          : (_readLegacyStyleFontScale(prefs) ?? 1);
      state = AppSettings(
        quality: AppQuality.values.firstWhere(
          (e) => e.name == q,
          orElse: () => AppQuality.hq,
        ),
        sleepMode: SleepTimerMode.values.firstWhere(
          (e) => e.name == s,
          orElse: () => SleepTimerMode.off,
        ),
        sleepCustomMinutes: prefs.getInt(_kSleepCustom) ?? 45,
        wifiCoverOnly: prefs.getBool(_kWifiCover) ?? false,
        lyricTranslation: prefs.getBool(_kLyricTr) ?? true,
        lyricRomanization: prefs.getBool(_kLyricRo) ?? false,
        lyricFontScale: fontScale,
        lyricSpacingScale: _readSpacingScale(prefs),
        mediaLyricSubtitle: prefs.getBool(_kMediaLyric) ?? false,
        mvBarrageEnabled: prefs.getBool(_kMvBarrageEnabled) ?? false,
        mvAudioFallbackEnabled:
            prefs.getBool(_kMvAudioFallbackEnabled) ?? false,
        mvBarrageConfig: BarrageConfig.decode(
          prefs.getString(_kMvBarrageConfig),
        ),
        accent: OvertoneAccent.values.firstWhere(
          (e) => e.name == accentName,
          orElse: () => OvertoneAccent.teal,
        ),
        archiveSkin:
            prefs.getBool(_kArchiveSkin) ??
            prefs.getBool(_kArchiveSkinLegacy) ??
            false,
        themeMode: AppThemeMode.values.firstWhere(
          (e) => e.name == themeName,
          orElse: () => AppThemeMode.light,
        ),
        closeBehavior: _readCloseBehavior(prefs),
        taskbarProgress: prefs.getBool(_kTaskbarProgress) ?? true,
        taskbarCoverPreview: prefs.getBool(_kTaskbarCoverPreview) ?? false,
        taskbarMediaBar: prefs.getBool(_kTaskbarMediaBar) ?? false,
        // 非 bool 值按字符串落盘（见 _save），脏数据回落 1.0。
        volume: (double.tryParse(prefs.getString(_kVolume) ?? '') ?? 1.0).clamp(
          0.0,
          1.0,
        ),
        // 倍速：同 volume 的字符串落盘口径；越界 / 脏数据回落 1.0。
        speed: (double.tryParse(prefs.getString(_kSpeed) ?? '') ?? 1.0).clamp(
          0.5,
          2.0,
        ),
        desktopLyricEnabled: prefs.getBool(_kDesktopLyricEnabled) ?? false,
        desktopLyricLocked: prefs.getBool(_kDesktopLyricLocked) ?? false,
        lyricOffsetMs: _readInt(prefs, _kLyricOffsetMs).clamp(-10000, 10000),
        lyricOffsetOverrides: _readLyricOffsetOverrides(prefs),
        desktopLyricStyle: _readDesktopLyricStyle(prefs),
        defaultSource: MusicPlatform.fromWire(
          prefs.getString(_kDefaultSource) ?? '',
        ),
        enabledSources: _readEnabledSources(prefs),
        disabledFeatures: _readDisabledFeatures(prefs),
      );
    } catch (_) {}
  }

  /// 读整数。兼容 [_save] 把非 bool 值统一按字符串写盘的旧数据
  ///（历史上 `settings.desktopLyricOffsetMs` 正是这样存进去的，直接
  /// `getInt` 读会永远拿到 null，偏移重启即归零）。
  int _readInt(SharedPreferences prefs, String key, {int fallback = 0}) {
    final raw = prefs.get(key);
    if (raw is int) return raw;
    return int.tryParse('$raw') ?? fallback;
  }

  /// 读取逐曲歌词偏移。存 JSON 对象字符串（对齐 mvBarrageConfig /
  /// desktopLyricStyle）；缺失 / 脏数据 / 非法条目逐项丢弃。
  Map<String, int> _readLyricOffsetOverrides(SharedPreferences prefs) {
    try {
      final raw = prefs.getString(_kLyricOffsetOverrides);
      if (raw == null || raw.isEmpty) return const {};
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const {};
      final out = <String, int>{};
      for (final entry in decoded.entries) {
        final key = entry.key;
        if (key is! String || key.isEmpty) continue;
        final value = entry.value;
        final ms = value is int ? value : int.tryParse('$value');
        if (ms == null) continue;
        out[key] = ms.clamp(-10000, 10000);
      }
      return out;
    } catch (_) {
      return const {};
    }
  }

  /// 读取桌面歌词外观。存的是 JSON 字符串（对齐 mvBarrageConfig 的做法）；
  /// 缺失 / 脏数据 / 越界字段都由 DesktopLyricStyle.fromWire 兜底回默认。
  DesktopLyricStyle _readDesktopLyricStyle(SharedPreferences prefs) {
    try {
      final raw = prefs.getString(_kDesktopLyricStyle);
      if (raw == null || raw.isEmpty) return const DesktopLyricStyle();
      final decoded = jsonDecode(raw);
      return DesktopLyricStyle.fromWire(decoded);
    } catch (_) {
      return const DesktopLyricStyle();
    }
  }

  /// 读旧版「桌面歌词样式」JSON 里的独立字号（已合并进
  /// [AppSettings.lyricFontScale]，新数据不再写该字段）。
  ///
  /// 只服务于一次性升级迁移：统一前用户在样式面板调的悬浮窗 / 歌词窗
  /// 字号，不能因为改了数据模型就丢失。
  double? _readLegacyStyleFontScale(SharedPreferences prefs) {
    try {
      final raw = prefs.getString(_kDesktopLyricStyle);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final v = (decoded['fontScale'] as num?)?.toDouble();
      if (v == null) return null;
      return v.clamp(kLyricFontScaleMin, kLyricFontScaleMax);
    } catch (_) {
      return null;
    }
  }

  /// 读取整源开关。缺失 / 空列表（非法态）/ 全部未知 → 默认集兜底。
  ///
  /// 不用 [MusicPlatform.fromWire]：它对未知值回退 kugou，会把脏数据
  /// 误读成「酷狗启用」，这里按 wireName 精确匹配后丢弃未知值。
  Set<MusicPlatform> _readEnabledSources(SharedPreferences prefs) {
    final raw = prefs.getStringList(_kEnabledSources);
    if (raw == null) return AppSettings().enabledSources;
    final parsed = MusicPlatform.values
        .where((p) => raw.contains(p.wireName))
        .toSet();
    return parsed.isEmpty ? AppSettings().enabledSources : parsed;
  }

  /// 读取「源 × 功能」子开关的**关闭**项。缺失（老数据）→ 空集 = 全开。
  ///
  /// 只认当前存在的 token：源或功能被移除后遗留的脏值会被丢弃，避免它
  /// 影响同名功能的判断。空列表是合法态（全部功能都关）。
  Set<String> _readDisabledFeatures(SharedPreferences prefs) {
    final raw = prefs.getStringList(_kDisabledFeatures);
    if (raw == null) return const {};
    final known = {
      for (final p in MusicPlatform.values)
        for (final f in SourceFeature.values) f.tokenFor(p),
    };
    return {
      for (final t in raw)
        if (known.contains(t)) t,
    };
  }

  /// 读取倍率。缺失 / 非数字 / 越界（旧版本或脏数据）→ 回落 [fallback]。
  double _readScale(
    SharedPreferences prefs,
    String key,
    double min,
    double max, {
    double fallback = 1,
  }) {
    final raw = double.tryParse(prefs.getString(key) ?? '');
    if (raw == null || raw < min || raw > max) return fallback;
    return raw;
  }

  /// 行间距读盘。
  ///
  /// 新键是「行盒 = 文字高度 × 倍率」；旧键是「行盒 = 56 基准 × 倍率」：
  /// - 旧默认值（没调过）→ 换成新默认，直接得到更紧的新观感；
  /// - 调过的值 → 按 [_kLegacySpacingRatio] 折算，观感不变。
  ///
  /// 旧键不删：用户一旦保存过新值就只读新键，旧键自然失效。
  double _readSpacingScale(SharedPreferences prefs) {
    final v2 = double.tryParse(prefs.getString(_kLyricSpacingScaleV2) ?? '');
    if (v2 != null) {
      return v2.clamp(kLyricSpacingScaleMin, kLyricSpacingScaleMax).toDouble();
    }
    final legacy = double.tryParse(
      prefs.getString(_kLyricSpacingScaleLegacy) ?? '',
    );
    if (legacy == null) return kLyricSpacingScaleDefault;
    if ((legacy - 1).abs() < 0.001) return kLyricSpacingScaleDefault;
    return (legacy * _kLegacySpacingRatio)
        .clamp(kLyricSpacingScaleMin, kLyricSpacingScaleMax)
        .toDouble();
  }

  /// 旧默认 56 基准 ÷ 单行文字高 24.3 ≈ 2.3。
  static const _kLegacySpacingRatio = 2.3;

  /// New key wins; otherwise migrate the old `closeToTray` boolean.
  /// Missing both → the new default「每次询问」.
  CloseBehavior _readCloseBehavior(SharedPreferences prefs) {
    final name = prefs.getString(_kCloseBehavior);
    if (name != null) {
      return CloseBehavior.values.firstWhere(
        (e) => e.name == name,
        orElse: () => CloseBehavior.ask,
      );
    }
    final legacy = prefs.getBool(_kCloseToTrayLegacy);
    if (legacy == null) return CloseBehavior.ask;
    return legacy ? CloseBehavior.tray : CloseBehavior.quit;
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _save(_kThemeMode, mode.name);
  }

  Future<void> setAccent(OvertoneAccent accent) async {
    if (state.accent == accent) return;
    state = state.copyWith(accent: accent);
    await _save(_kAccent, accent.name);
  }

  Future<void> setArchiveSkin(bool v) async {
    if (state.archiveSkin == v) return;
    state = state.copyWith(archiveSkin: v);
    await _save(_kArchiveSkin, v);
  }

  Future<void> setQuality(AppQuality v) async {
    state = state.copyWith(quality: v);
    await _save(_kQuality, v.name);
  }

  Future<void> setSleep(SleepTimerMode mode, {int? customMinutes}) async {
    state = state.copyWith(
      sleepMode: mode,
      sleepCustomMinutes: customMinutes ?? state.sleepCustomMinutes,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSleep, mode.name);
    if (customMinutes != null) {
      await prefs.setInt(_kSleepCustom, customMinutes);
    }
  }

  Future<void> setWifiCoverOnly(bool v) async {
    state = state.copyWith(wifiCoverOnly: v);
    await _save(_kWifiCover, v);
  }

  Future<void> setLyricTranslation(bool v) async {
    state = state.copyWith(lyricTranslation: v);
    await _save(_kLyricTr, v);
  }

  Future<void> setLyricRomanization(bool v) async {
    state = state.copyWith(lyricRomanization: v);
    await _save(_kLyricRo, v);
  }

  /// 歌词字号倍率。拖动过程中传 `persist: false` 只改内存态做即时预览，
  /// 松手（`onChangeEnd`）再落盘，避免一次拖动写几十次 SharedPreferences。
  ///
  /// 落盘与「值是否变化」解耦：松手时的值必然已经由预览写进内存态，
  /// 若在这里因相等而提前 return，就永远不会落盘。
  Future<void> setLyricFontScale(double v, {bool persist = true}) async {
    final next = _normalizeScale(v, kLyricFontScaleMin, kLyricFontScaleMax);
    if (next != state.lyricFontScale) {
      state = state.copyWith(lyricFontScale: next);
    }
    if (persist) await _save(_kLyricFontScale, next);
  }

  /// 歌词行间距倍率。`persist` 语义同 [setLyricFontScale]。
  Future<void> setLyricSpacingScale(double v, {bool persist = true}) async {
    final next = _normalizeScale(
      v,
      kLyricSpacingScaleMin,
      kLyricSpacingScaleMax,
    );
    if (next != state.lyricSpacingScale) {
      state = state.copyWith(lyricSpacingScale: next);
    }
    if (persist) await _save(_kLyricSpacingScaleV2, next);
  }

  /// 夹到合法区间并收敛到 0.01 精度（滑块取值连续，落盘前归一）。
  double _normalizeScale(double v, double min, double max) =>
      (v.clamp(min, max) * 100).roundToDouble() / 100;

  Future<void> setMediaLyricSubtitle(bool v) async {
    state = state.copyWith(mediaLyricSubtitle: v);
    await _save(_kMediaLyric, v);
  }

  Future<void> setMvBarrageEnabled(bool v) async {
    state = state.copyWith(mvBarrageEnabled: v);
    await _save(_kMvBarrageEnabled, v);
  }

  Future<void> setMvAudioFallbackEnabled(bool v) async {
    state = state.copyWith(mvAudioFallbackEnabled: v);
    await _save(_kMvAudioFallbackEnabled, v);
  }

  /// MV 弹幕配置。拖动滑块时传 `persist: false` 只改内存态做即时预览，
  /// 松手（`onChangeEnd`）再落盘 —— 语义同 [setLyricFontScale]。
  Future<void> setMvBarrageConfig(
    BarrageConfig v, {
    bool persist = true,
  }) async {
    final next = v.normalized();
    if (next.encode() != state.mvBarrageConfig.encode()) {
      state = state.copyWith(mvBarrageConfig: next);
    }
    if (persist) await _save(_kMvBarrageConfig, next.encode());
  }

  Future<void> setCloseBehavior(CloseBehavior v) async {
    state = state.copyWith(closeBehavior: v);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kCloseBehavior, v.name);
      // Migration done — drop the stale boolean so it can't shadow the new key.
      await prefs.remove(_kCloseToTrayLegacy);
    } catch (_) {}
  }

  Future<void> setTaskbarProgress(bool v) async {
    state = state.copyWith(taskbarProgress: v);
    await _save(_kTaskbarProgress, v);
  }

  Future<void> setTaskbarCoverPreview(bool v) async {
    state = state.copyWith(taskbarCoverPreview: v);
    await _save(_kTaskbarCoverPreview, v);
  }

  Future<void> setTaskbarMediaBar(bool v) async {
    state = state.copyWith(taskbarMediaBar: v);
    await _save(_kTaskbarMediaBar, v);
  }

  /// 播放音量。记忆落盘，重启后仍是上次的值。
  Future<void> setVolume(double v) async {
    final next = v.clamp(0.0, 1.0);
    if (state.volume == next) return;
    state = state.copyWith(volume: next);
    await _save(_kVolume, next);
  }

  /// 播放倍速。记忆落盘，重启后仍是上次的值。
  /// 由 `PlayerController.setSpeed` 调用（唯一写入口）；UI 不直接写。
  Future<void> setSpeed(double v) async {
    final next = v.clamp(0.5, 2.0);
    if (state.speed == next) return;
    state = state.copyWith(speed: next);
    await _save(_kSpeed, next);
  }

  /// 桌面歌词开关。真正的窗口开关由 [DesktopLyricBridge] 执行后再回写此值，
  /// 避免「设置先亮、窗口没开」的不一致。
  Future<void> setDesktopLyricEnabled(bool v) async {
    if (state.desktopLyricEnabled == v) return;
    state = state.copyWith(desktopLyricEnabled: v);
    await _save(_kDesktopLyricEnabled, v);
  }

  Future<void> setDesktopLyricLocked(bool v) async {
    if (state.desktopLyricLocked == v) return;
    state = state.copyWith(desktopLyricLocked: v);
    await _save(_kDesktopLyricLocked, v);
  }

  /// 全局歌词偏移（ms）。应用内歌词视图与桌面歌词窗共用的默认值。
  Future<void> setLyricOffsetMs(int v) async {
    final next = v.clamp(-10000, 10000);
    if (state.lyricOffsetMs == next) return;
    state = state.copyWith(lyricOffsetMs: next);
    await _save(_kLyricOffsetMs, next);
  }

  /// 逐曲歌词偏移微调（叠加在全局值之上）。
  ///
  /// [deltaMs]：相对当前微调值的增量（对齐 EchoMusic `adjustTimeOffset`）。
  /// [reset]：清除该曲微调（回到只吃全局值）。
  Future<void> adjustTrackLyricOffsetMs(
    String trackKey, {
    int deltaMs = 0,
    bool reset = false,
  }) async {
    if (trackKey.isEmpty) return;
    final next = Map<String, int>.from(state.lyricOffsetOverrides);
    final current = next[trackKey] ?? 0;
    if (reset) {
      if (next.remove(trackKey) == null) return;
    } else {
      final adjusted = (current + deltaMs).clamp(-10000, 10000);
      if (next[trackKey] == adjusted) return;
      next[trackKey] = adjusted;
    }
    state = state.copyWith(lyricOffsetOverrides: Map.unmodifiable(next));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLyricOffsetOverrides, jsonEncode(next));
    } catch (_) {}
  }

  /// 桌面歌词外观。拖动滑块时传 persist: false 只改内存态做即时预览，
  /// 松手（onChangeEnd）再落盘，对齐 [setLyricFontScale] 的做法。
  Future<void> setDesktopLyricStyle(
    DesktopLyricStyle v, {
    bool persist = true,
  }) async {
    if (state.desktopLyricStyle != v) {
      state = state.copyWith(desktopLyricStyle: v);
    }
    if (persist) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kDesktopLyricStyle, jsonEncode(v.toWire()));
      } catch (_) {}
    }
  }

  Future<void> setDefaultSource(MusicPlatform v) async {
    state = state.copyWith(defaultSource: v);
    await _save(_kDefaultSource, v.wireName);
  }

  /// 页面内「切音源」筛选条切换时调用：把**具体源**同步为全局默认源。
  ///
  /// 「全部」(`null`) 是混排视图、不代表任何一个源，**不写**——否则「全部」
  /// 会被曲解成「用默认源」。已等于当前默认源时也不需要落盘。
  ///
  /// 放在这里而不是 [SourceFilterBar] 内部：`shared/` 不反向依赖 `features/`，
  /// 由 9 处调用点的 `onSelect` 各自调用（口径见方案 §11 决策记录）。
  void syncDefaultSourceFromFilter(MusicPlatform? platform) {
    if (platform == null || platform == state.defaultSource) return;
    setDefaultSource(platform);
  }

  /// 整源开关。空集合直接拒绝（至少保留一个源，否则 App 没有可用音源）。
  ///
  /// 停用当前默认源时，默认源联动回退到第一个仍启用的源并落盘，
  /// 消费点（搜索页 / 我喜欢页初始筛选）无需各自处理该边界。
  Future<void> setEnabledSources(Set<MusicPlatform> v) async {
    if (v.isEmpty ||
        v.length == state.enabledSources.length &&
            v.containsAll(state.enabledSources)) {
      return;
    }
    var next = state.copyWith(enabledSources: v);
    if (!v.contains(next.defaultSource)) {
      next = next.copyWith(defaultSource: next.effectiveDefaultSource);
    }
    state = next;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_kEnabledSources, [
        for (final p in MusicPlatform.values)
          if (v.contains(p)) p.wireName,
      ]);
      // 默认源可能被联动修正，两个 key 要一起写。
      await prefs.setString(_kDefaultSource, state.defaultSource.wireName);
    } catch (_) {}
  }

  /// 网易云音源需登录才生效：把网易云按登录态并入（登录成功）/移出（退出登录）
  /// 启用集。移出后集空时回落酷狗（[setEnabledSources] 拒绝空集），停用默认源
  /// 时的回退也由它统一处理。
  ///
  /// **启动时只在 `logged == false` 方向调用**（见 `main.dart`）：已登录时不动
  /// 启用集，免得覆盖用户在登录态下对网易云的**手动停用**——只有「登录事件」
  /// （扫码确认）才会重新并入。状态本就一致时静默返回，不写盘。
  Future<void> setNeteaseAccess(bool logged) async {
    const netease = MusicPlatform.netease;
    final has = state.enabledSources.contains(netease);
    if (logged == has) return;
    final next = {...state.enabledSources};
    if (logged) {
      next.add(netease);
    } else {
      next.remove(netease);
      if (next.isEmpty) next.add(MusicPlatform.kugou);
    }
    await setEnabledSources(next);
  }

  /// 「源 × 功能」子开关。与整源开关不同，**允许全关**（父开关关闭时子项
  /// 只是置灰、取值保留，重新开启父开关即恢复），所以这里不拒绝空集合。
  Future<void> setFeatureEnabled(
    MusicPlatform platform,
    SourceFeature feature,
    bool v,
  ) async {
    final token = feature.tokenFor(platform);
    final next = {...state.disabledFeatures};
    if (v) {
      if (!next.remove(token)) return;
    } else {
      if (!next.add(token)) return;
    }
    state = state.copyWith(disabledFeatures: next);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_kDisabledFeatures, next.toList()..sort());
    } catch (_) {}
  }

  /// Clear cover disk/memory cache + play & search history. Returns a status label.
  Future<String> clearImageAndHistoryCache() async {
    await CoverCache.instance.clear();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    try {
      final store = await QueueStore.open();
      await store.clearAll();
    } catch (_) {}
    try {
      await ref.read(searchHistoryProvider.notifier).clear();
    } catch (_) {}
    return '已清理图片缓存、播放与搜索历史';
  }

  Future<void> _save(String key, Object value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value is bool) {
        await prefs.setBool(key, value);
      } else {
        await prefs.setString(key, '$value');
      }
    } catch (_) {}
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
