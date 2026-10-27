import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart' show PointerEnterEvent, PointerExitEvent;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/track.dart';
import '../../core/theme/archive_skin.dart';
import '../../core/theme/magi_skin.dart';
import '../../shared/widgets/magi_chrome.dart';

import '../../core/theme/cover_palette.dart';
import '../../core/theme/hero_tags.dart';
import '../../core/theme/overtone_tokens.dart';
import '../../features/likes/likes_controller.dart';
import '../../features/player/player_controller.dart';
import '../../features/settings/settings_controller.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/player_icon_buttons.dart';
import '../../shared/widgets/cover_box.dart';
import '../../shared/widgets/cover_viewer.dart';
import '../../shared/widgets/lyrics_view.dart';
import '../../shared/widgets/archive_chrome.dart';
import '../../shared/widgets/archive_controls.dart';
import '../../shared/navigation/pop_or_explore.dart';
import '../../core/models/playback_source.dart';
import '../../core/source/music_platform.dart';
import '../fm/fm_controller.dart';
import '../mv/mv_entry.dart';
import '../profile/source_account.dart' show loginRouteFor;
import 'fm_controls.dart';
import 'archive_player_chrome.dart';
import '../../shared/widgets/lyric_display_sheet.dart';
import '../../shared/widgets/quality_sheet.dart';
import '../../shared/widgets/queue_sheet.dart';
import '../../shared/widgets/speed_sheet.dart';
import '../../core/theme/overtone_theme.dart';
import '../../core/theme/responsive.dart';

class FullPlayerPage extends ConsumerStatefulWidget {
  const FullPlayerPage({super.key});

  static String format(int ms) {
    final safe = ms < 0 ? 0 : ms;
    final d = Duration(milliseconds: safe);
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  ConsumerState<FullPlayerPage> createState() => _FullPlayerPageState();
}

class _FullPlayerPageState extends ConsumerState<FullPlayerPage> {
  /// 拖拽中的进度（0–1）；null = 未拖拽。
  ///
  /// 按下即 seek 会让一次误触直接跳歌，所以拖动期间只更新本地预览值，
  /// 松手（onChangeEnd）才真正 seek。
  double? _dragProgress;

  void _openLyrics(BuildContext context) => context.push('/player/lyrics');

  void _beginDrag(double value) => setState(() => _dragProgress = value);

  void _endDrag(double value, int durationMs) {
    ref
        .read(playerControllerProvider.notifier)
        .seekTo((value * durationMs).round());
    setState(() => _dragProgress = null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final player = ref.watch(playerControllerProvider);
    final controller = ref.read(playerControllerProvider.notifier);
    final track = player.current;
    if (track == null) {
      return Scaffold(
        backgroundColor: theme.bg,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => popOrExplore(context),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '暂无播放内容\n去搜索或歌单里点一首歌',
                    textAlign: TextAlign.center,
                    style: theme.caption,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    // 冷启动恢复 / 未起播时也可能停在本页：歌词与播放解耦，打开即 ensure。
    // build 期间不允许改 provider（会抛 Tried to modify a provider while the
    // widget tree was building），所以推迟到当前同步构建结束之后。
    unawaited(
      Future<void>.microtask(
        () => controller.ensureLyricsForCurrent(retryIfEmpty: true),
      ),
    );

    final duration = player.durationMs == 0 ? 1 : player.durationMs;
    final isDesktop = isDesktopView(context);

    if (isDesktop) {
      final activeSkin = ArchiveSkinActive.skinOf(context);
      final isSwiss = activeSkin == ExperimentalUiSkin.swiss;
      final isMagi = activeSkin == ExperimentalUiSkin.magi;
      final isExperimental = isSwiss || isMagi;
      final archive = isSwiss; // 保持向后兼容

      // 档案/战术皮肤整列左对齐，标准皮肤保持居中。
      final metaAlign = isExperimental ? TextAlign.start : TextAlign.center;
      final page = Scaffold(
        // 实验皮肤下 Scaffold 保持透明，让背后的网格透出来。
        backgroundColor: isExperimental ? Colors.transparent : theme.bg,
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOut,
          decoration: isExperimental
              ? null
              : BoxDecoration(
                  gradient: CoverPalette.playerBackground(
                    track.coverUrl,
                    theme.palette,
                  ),
                ),
          child: SafeArea(
            child: Row(
              children: [
                // ---------------- 左栏：封面、歌曲信息、进度与播放控制 ----------------
                SizedBox(
                  width: 448,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 16,
                    ),
                    child: LayoutBuilder(
                      builder: (context, colConstraints) {
                        final magiCoverSize = (colConstraints.maxHeight - 450).clamp(200.0, 280.0);
                        return Column(
                          crossAxisAlignment: isExperimental
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.center,
                          children: [
                            // 顶部导航：收起、标题、详情、队列
                            if (isMagi)
                              Row(
                                children: [
                                  MagiTagButton(
                                    tooltip: '收起播放页',
                                    label: 'ESC',
                                    onPressed: () => popOrExplore(context),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: MagiSkin.pilotGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Expanded(
                                    child: Text(
                                      'MAGI SYSTEM // 01',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.0,
                                        color: MagiSkin.redPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  MvEntryButton(track: track, size: 20),
                                  MagiTagButton(
                                    tooltip: '歌曲详情',
                                    label: 'SPEC',
                                    onPressed: () =>
                                        _openSongDetail(context, track),
                                  ),
                                  const SizedBox(width: 6),
                                  MagiTagButton(
                                    tooltip: '播放队列',
                                    label: 'QUEUE',
                                    onPressed: () => showQueueSheet(context, ref),
                                  ),
                                ],
                              )
                        else if (isSwiss)
                          Row(
                            children: [
                              ArchiveTagButton(
                                tooltip: '收起播放页',
                                label: 'ESC',
                                onPressed: () => popOrExplore(context),
                              ),
                              const SizedBox(width: 8),
                              const ArchiveSectionLabel('NOW PLAYING'),
                              const Spacer(),
                              MvEntryButton(track: track, size: 20),
                              ArchiveTagButton(
                                tooltip: '歌曲详情',
                                label: 'SPEC',
                                onPressed: () =>
                                    _openSongDetail(context, track),
                              ),
                              const SizedBox(width: 8),
                              ArchiveTagButton(
                                tooltip: '播放队列',
                                label: 'QUEUE',
                                onPressed: () => showQueueSheet(context, ref),
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => popOrExplore(context),
                                tooltip: '收起播放页',
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('正在播放', style: theme.section),
                              const Spacer(),
                              // 播放 MV（这首歌有 MV 时露出）
                              MvEntryButton(track: track, size: 20),
                              IconButton(
                                onPressed: () =>
                                    _openSongDetail(context, track),
                                tooltip: '歌曲详情',
                                icon: const Icon(
                                  Icons.info_outline_rounded,
                                  size: 20,
                                ),
                              ),
                              IconButton(
                                onPressed: () => showQueueSheet(context, ref),
                                tooltip: '播放队列',
                                icon: const Icon(
                                  Icons.queue_music_rounded,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),

                        if (!isMagi) const Spacer(),
                        if (isMagi) const SizedBox(height: 12),

                        // 大封面（Hero 落地点：从桌面底栏封面飞入）
                        if (isMagi)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: magiCoverSize,
                              child: MagiTargetFrame(
                                sourceCode: track.platform.label.toUpperCase(),
                                clearance: track.isVip ? 'VIP-01' : 'PUBLIC',
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: _PlayerCoverWithZoom(
                                    tag: OvertoneHeroTags.playerCover(track.id),
                                    seed: track.coverUrl,
                                    size: 0,
                                    radius: 0,
                                  ),
                                ),
                              ),
                            ),
                          )
                        else if (isSwiss)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ArchiveCardFrame(
                              org: track.platform.label,
                              clearance: track.isVip ? 'VIP' : '公开',
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: _PlayerCoverWithZoom(
                                  tag: OvertoneHeroTags.playerCover(track.id),
                                  seed: track.coverUrl,
                                  size: 0,
                                  radius: 0,
                                ),
                              ),
                            ),
                          )
                        else
                          _PlayerCoverWithZoom(
                            tag: OvertoneHeroTags.playerCover(track.id),
                            seed: track.coverUrl,
                            size: 260,
                            radius: OvertoneRadius.card,
                          ),

                        SizedBox(height: isMagi ? 10 : 20),

                        // 歌曲名与歌手
                        if (isMagi) ...[
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  '/// PRIORITY: LEVEL-AAA // SYNC: 100% ///',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.1,
                                    color: MagiSkin.redPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'CODE: ${track.platform.label.toUpperCase()}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: MagiSkin.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            track.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: metaAlign,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                              height: 1.15,
                              color: MagiSkin.textPrimary,
                              fontFamilyFallback: [
                                'Songti SC',
                                'SimSun',
                                'STSong',
                                'Noto Serif SC',
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                'ARTIST: [ ${track.artist.isEmpty ? "UNKNOWN" : track.artist} ]',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: MagiSkin.hazardGold,
                                ),
                              ),
                              if (track.album.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '// ALBUM: [ ${track.album} ]',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: MagiSkin.textTertiary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          MagiEqualizerBar(isPlaying: player.isPlaying),
                          const SizedBox(height: 8),
                          const MagiConsensusBar(),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'DECODER: NERV-DSP // 24bit HI-RES',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: MagiSkin.textTertiary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _PlayerQualityChip(track: track),
                            ],
                          ),
                        ] else if (isSwiss) ...[
                          // Kicker 序号与平台
                          Row(
                            children: [
                              Text(
                                '01 / NOW PLAYING',
                                style: theme.caption.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: theme.primary,
                                ),
                              ),
                              const Spacer(),
                              if (track.platform.label.isNotEmpty)
                                Text(
                                  track.platform.label.toUpperCase(),
                                  style: theme.caption.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.8,
                                    color: theme.textTertiary,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // 巨幅标题：冷峻粗体、紧实字距，形成大字阶张力
                          Text(
                            track.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: metaAlign,
                            style: theme.greeting.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // 艺术家与专辑：强对比度排版
                          Row(
                            children: [
                              Text(
                                track.artist.isEmpty ? '未知歌手' : track.artist,
                                style: theme.body.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.textPrimary,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              if (track.album.isNotEmpty) ...[
                                Text(
                                  '  /  ',
                                  style: theme.caption.copyWith(
                                    color: theme.textTertiary,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    track.album,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.caption.copyWith(
                                      color: theme.textSecondary,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 1,
                            color: theme.divider,
                          ),
                          const SizedBox(height: 10),
                          // 技术规格行：参数标题 + 格式 Chip
                          Row(
                            children: [
                              Text(
                                'SPECIFICATIONS',
                                style: theme.caption.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                  color: theme.textTertiary,
                                ),
                              ),
                              const Spacer(),
                              _PlayerQualityChip(track: track),
                            ],
                          ),
                        ] else ...[
                          Text(
                            track.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: metaAlign,
                            style: theme.title.copyWith(height: 1.2),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${track.artist} · ${track.album}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: metaAlign,
                            style: theme.caption,
                          ),
                          const SizedBox(height: 10),
                          _PlayerQualityChip(track: track),
                        ],
                        if (player.display == PlayerDisplayState.error) ...[
                          const SizedBox(height: 10),
                          _PlayerErrorNotice(
                            message: player.errorCode,
                            loginPlatform:
                                player.errorKind ==
                                    PlayerErrorKind.loginRequired
                                ? track.platform
                                : null,
                          ),
                        ],

                        const Spacer(),

                        // 进度滑块 — only this block tracks the live cursor.
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: PlayerPositionBuilder(
                            builder: (context, positionMs) {
                              final progress = (positionMs / duration).clamp(
                                0.0,
                                1.0,
                              );
                              final shownMs = _dragProgress == null
                                  ? positionMs
                                  : (_dragProgress! * duration).round();
                              if (isMagi) {
                                return MagiProgressGauge(
                                  positionMs: shownMs,
                                  durationMs: duration,
                                  onSeek: (ms) => _endDrag(ms / duration, duration),
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (isSwiss)
                                    ArchiveProgressRule(
                                      value: progress,
                                      onDrag: _beginDrag,
                                      onEnd: (v) => _endDrag(v, duration),
                                    )
                                  else
                                    SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 3,
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 5,
                                        ),
                                        overlayShape:
                                            const RoundSliderOverlayShape(
                                              overlayRadius: 10,
                                            ),
                                      ),
                                      child: Slider(
                                        value: _dragProgress ?? progress,
                                        onChangeStart: _beginDrag,
                                        onChanged: _beginDrag,
                                        onChangeEnd: (v) =>
                                            _endDrag(v, duration),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: archive
                                          ? MainAxisAlignment.start
                                          : MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          FullPlayerPage.format(shownMs),
                                          style: theme.caption.copyWith(
                                            fontSize: 12,
                                            fontWeight: archive
                                                ? FontWeight.w600
                                                : null,
                                            letterSpacing: archive ? 0.5 : null,
                                            fontFeatures: archive
                                                ? const [
                                                    FontFeature.tabularFigures(),
                                                  ]
                                                : null,
                                            color: archive
                                                ? theme.textPrimary
                                                : null,
                                          ),
                                        ),
                                        if (archive) const Spacer(),
                                        Text(
                                          '-${FullPlayerPage.format(duration - shownMs)}',
                                          style: theme.caption.copyWith(
                                            fontSize: 12,
                                            fontWeight: archive
                                                ? FontWeight.w600
                                                : null,
                                            letterSpacing: archive ? 0.5 : null,
                                            fontFeatures: archive
                                                ? const [
                                                    FontFeature.tabularFigures(),
                                                  ]
                                                : null,
                                            color: archive
                                                ? theme.textTertiary
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 12),

                        // 控制按钮栏
                        if (isMagi)
                          MagiControlBar(
                            player: player,
                            controller: controller,
                            track: track,
                          )
                        else if (isSwiss)
                          ArchiveControlBar(
                            player: player,
                            controller: controller,
                            track: track,
                          )
                        else
                          _ControlBar(
                            player: player,
                            controller: controller,
                            track: track,
                            compact: false,
                            height: 64,
                          ),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                ),
              ),
            ),

                // 分割线
                VerticalDivider(
                  width: 1,
                  color: isExperimental
                      ? theme.divider
                      : theme.divider.withValues(alpha: 0.5),
                ),

                // ---------------- 右栏：完整平滑滚动歌词 ----------------
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (isMagi) ...[
                              Container(
                                width: 3,
                                height: 14,
                                color: MagiSkin.redPrimary,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'MAGI // TRANSCRIPT LOG',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: MagiSkin.redPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '实时通信日志',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: MagiSkin.textPrimary,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: MagiSkin.pilotGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'SYNC: 100%',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: MagiSkin.pilotGreen,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ] else if (isSwiss) ...[
                              Container(
                                width: 3,
                                height: 14,
                                color: theme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '02 / LYRICS',
                                style: theme.caption.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: theme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '歌词',
                                style: theme.body.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.textPrimary,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ]
                            else
                              Text(
                                '歌词',
                                style: theme.section.copyWith(
                                  color: theme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            const Spacer(),
                            if (ref.watch(fmControllerProvider).active)
                              const FmEntryPill(),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: LyricPositionBuilder(
                            builder: (context, positionMs) => LyricsView(
                              lines: player.lyrics,
                              positionMs: positionMs,
                              isPlaying: player.isPlaying,
                              status: player.lyricsStatus,
                              onTapLine: (ms) => controller.seekTo(ms),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return _SkinPlayerBackdrop(skin: activeSkin, child: page);
    }

    final skin = ArchiveSkinActive.skinOf(context);
    final hasSkin = skin != ExperimentalUiSkin.off;

    final page = Scaffold(
      // Solid page bg avoids Material/Zoom settle flash-through.
      backgroundColor: hasSkin ? Colors.transparent : theme.bg,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOut,
        decoration: hasSkin
            ? null
            : BoxDecoration(
                gradient: CoverPalette.playerBackground(
                  track.coverUrl,
                  theme.palette,
                ),
              ),
        child: SafeArea(
          child: Column(
            children: [
              if (hasSkin)
                _SkinPlayerTopBar(
                  skin: skin,
                  track: track,
                  onCollapse: () => popOrExplore(context),
                  onSongDetail: () => _openSongDetail(context, track),
                  onQueue: () => showQueueSheet(context, ref),
                )
              else
                _TopBar(
                  expanded: false,
                  track: track,
                  onCollapsePage: () => popOrExplore(context),
                  onCollapseLyrics: () => context.pop(),
                  onSongDetail: () => _openSongDetail(context, track),
                  onQueue: () => showQueueSheet(context, ref),
                ),
              // FM 会话进行中：紧凑入口（原「私人 FM」页撤掉后的唯一常驻痕迹）。
              if (ref.watch(fmControllerProvider).active) const FmEntryPill(),
              Expanded(
                child: _CollapsedPlayerBody(
                  key: const ValueKey('player-collapsed'),
                  // Route Hero: large cover ↔ lyrics header / mini player.
                  useHero: true,
                  track: track,
                  player: player,
                  controller: controller,
                  duration: duration,
                  onExpandLyrics: () => _openLyrics(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return _SkinPlayerBackdrop(skin: skin, child: page);
  }

  void _openSongDetail(BuildContext context, Track track) {
    final q = <String, String>{
      'id': track.id,
      'platform': track.platform.wireName,
      'name': track.name,
      'artist': track.artist,
      // 带全 id 与 hash：详情页的「歌手」按钮靠 artistId（缺了就禁用），
      // 评论取数靠 hash / mixSongId（缺了要多跑一次搜歌解析）。
      'artistId': track.artistId,
      'hash': track.hash,
      'mixSongId': track.mixSongId,
      'album': track.album,
      'cover': track.coverUrl,
      'duration': '${track.durationMs}',
    };
    final qs = q.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    context.push('/song?$qs');
  }
}

/// Full lyrics as its own route: Hero flies cover large → header, and the
/// page uses center scale + fade (see `/player/lyrics` in app.dart).
class PlayerLyricsPage extends ConsumerStatefulWidget {
  const PlayerLyricsPage({super.key});

  @override
  ConsumerState<PlayerLyricsPage> createState() => _PlayerLyricsPageState();
}

class _PlayerLyricsPageState extends ConsumerState<PlayerLyricsPage> {
  /// 同播放页：拖动只更新预览值，松手才 seek。
  double? _dragProgress;

  void _beginDrag(double value) => setState(() => _dragProgress = value);

  void _endDrag(double value, int durationMs) {
    ref
        .read(playerControllerProvider.notifier)
        .seekTo((value * durationMs).round());
    setState(() => _dragProgress = null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final player = ref.watch(playerControllerProvider);
    final controller = ref.read(playerControllerProvider.notifier);
    final track = player.current;

    if (track == null) {
      return Scaffold(
        backgroundColor: theme.bg,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
                ),
              ),
              Expanded(
                child: Center(child: Text('暂无播放内容', style: theme.caption)),
              ),
            ],
          ),
        ),
      );
    }
    // 同上：build 期间改 provider 会抛异常，推迟到构建结束之后。
    unawaited(
      Future<void>.microtask(
        () => controller.ensureLyricsForCurrent(retryIfEmpty: true),
      ),
    );

    final duration = player.durationMs == 0 ? 1 : player.durationMs;
    final skin = ArchiveSkinActive.skinOf(context);
    final hasSkin = skin != ExperimentalUiSkin.off;
    final isSwiss = skin == ExperimentalUiSkin.swiss;

    final page = Scaffold(
      backgroundColor: hasSkin ? Colors.transparent : theme.bg,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOut,
        decoration: hasSkin
            ? null
            : BoxDecoration(
                gradient: CoverPalette.playerBackground(
                  track.coverUrl,
                  theme.palette,
                ),
              ),
        child: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.deferToChild,
            onVerticalDragEnd: (d) {
              final v = d.primaryVelocity ?? 0;
              if (v > 240 && context.canPop()) context.pop();
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    OvertoneSpacing.sm,
                    OvertoneSpacing.sm,
                    OvertoneSpacing.xl,
                    4,
                  ),
                  child: SizedBox(
                    height: 48,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          tooltip: '收起歌词',
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 32,
                          ),
                        ),
                        // Hero destination: mini cover in lyrics header.
                        CoverHero(
                          tag: OvertoneHeroTags.playerCover(track.id),
                          seed: track.coverUrl,
                          size: 44,
                          radius: hasSkin ? 0 : OvertoneRadius.tag,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                track.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                              Text(
                                '${track.artist} · ${track.album}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.caption.copyWith(height: 1.2),
                              ),
                            ],
                          ),
                        ),
                        _PlayerQualityChip(
                          track: track,
                          // 窄屏顶栏先让位给曲名，只留 VIP/音质徽标。
                          compact: MediaQuery.sizeOf(context).width < 480,
                        ),
                      ],
                    ),
                  ),
                ),
                if (hasSkin)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      OvertoneSpacing.lg,
                      2,
                      OvertoneSpacing.lg,
                      8,
                    ),
                    child: Row(
                      children: [
                        if (isSwiss)
                          const ArchiveSectionLabel('02 / LYRICS')
                        else ...[
                          Container(
                            width: 3,
                            height: 14,
                            color: MagiSkin.redPrimary,
                          ),
                          const SizedBox(width: 8),
                          const Flexible(
                            child: Text(
                              'MAGI // TRANSCRIPT LOG',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: MagiSkin.redPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Flexible(
                            child: Text(
                              '实时通信日志',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: MagiSkin.textPrimary,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                      ],
                    ),
                  ),
                if (player.display == PlayerDisplayState.error)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      OvertoneSpacing.xl,
                      4,
                      OvertoneSpacing.xl,
                      0,
                    ),
                    child: Text(
                      player.errorCode.isEmpty
                          ? '播放失败，可点下一首重试'
                          : player.errorCode,
                      textAlign: TextAlign.center,
                      style: theme.caption.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                Expanded(
                  child: LyricPositionBuilder(
                    builder: (context, positionMs) => LyricsView(
                      lines: player.lyrics,
                      positionMs: positionMs,
                      isPlaying: player.isPlaying,
                      status: player.lyricsStatus,
                      onTapLine: (ms) => controller.seekTo(ms),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    OvertoneSpacing.lg,
                    4,
                    OvertoneSpacing.lg,
                    20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PlayerPositionBuilder(
                        builder: (context, positionMs) {
                          final progress = (positionMs / duration).clamp(
                            0.0,
                            1.0,
                          );
                          final shownMs = _dragProgress == null
                              ? positionMs
                              : (_dragProgress! * duration).round();
                          if (hasSkin && !isSwiss) {
                            return MagiProgressGauge(
                              positionMs: shownMs,
                              durationMs: duration,
                              onSeek: (ms) => controller.seekTo(ms.round()),
                            );
                          }
                          if (hasSkin) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ArchiveProgressRule(
                                  value: progress,
                                  onDrag: _beginDrag,
                                  onEnd: (v) => _endDrag(v, duration),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      FullPlayerPage.format(shownMs),
                                      style: theme.caption.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                        color: theme.textPrimary,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '-${FullPlayerPage.format((duration - shownMs).clamp(0, duration).toInt())}',
                                      style: theme.caption.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                        color: theme.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 48,
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 3,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 5,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 10,
                                    ),
                                  ),
                                  child: Slider(
                                    value: _dragProgress ?? progress,
                                    onChangeStart: _beginDrag,
                                    onChanged: _beginDrag,
                                    onChangeEnd: (v) => _endDrag(v, duration),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 22,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        FullPlayerPage.format(shownMs),
                                        style: theme.caption.copyWith(
                                          height: 1.2,
                                        ),
                                      ),
                                      Text(
                                        '-${FullPlayerPage.format((duration - shownMs).clamp(0, duration).toInt())}',
                                        style: theme.caption.copyWith(
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      if (hasSkin)
                        isSwiss
                            ? ArchiveControlBar(
                                player: player,
                                controller: controller,
                                track: track,
                              )
                            : MagiControlBar(
                                player: player,
                                controller: controller,
                                track: track,
                              )
                      else
                        _ControlBar(
                          player: player,
                          controller: controller,
                          track: track,
                          compact: true,
                          height: 60,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return _SkinPlayerBackdrop(skin: skin, child: page);
  }
}

/// 实验皮肤的整页底板：swiss 铺发丝网格；magi 碳素底 + 战术网格 + 上下警示条
/// + 四角准星。桌面与移动端共用同一套底板。
class _SkinPlayerBackdrop extends StatelessWidget {
  const _SkinPlayerBackdrop({required this.skin, required this.child});

  final ExperimentalUiSkin skin;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    if (skin == ExperimentalUiSkin.swiss) {
      return Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: CustomPaint(painter: ArchiveGridPainter(theme: theme)),
          ),
          child,
        ],
      );
    }
    if (skin == ExperimentalUiSkin.magi) {
      return ColoredBox(
        color: MagiSkin.bgBase,
        child: Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              child: CustomPaint(painter: MagiGridPainter(theme: theme)),
            ),
            Column(
              children: [
                const MagiHazardBar(height: 4),
                Expanded(child: child),
                const MagiHazardBar(height: 4),
              ],
            ),
            const IgnorePointer(child: MagiFrameCorners()),
          ],
        ),
      );
    }
    return child;
  }
}

/// 手机播放页的实验皮肤顶栏：与桌面同一套标签按钮，压缩到一行。
class _SkinPlayerTopBar extends StatelessWidget {
  const _SkinPlayerTopBar({
    required this.skin,
    required this.track,
    required this.onCollapse,
    required this.onSongDetail,
    required this.onQueue,
  });

  final ExperimentalUiSkin skin;
  final Track track;
  final VoidCallback onCollapse;
  final VoidCallback onSongDetail;
  final VoidCallback onQueue;

  @override
  Widget build(BuildContext context) {
    final isMagi = skin == ExperimentalUiSkin.magi;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      child: SizedBox(
        height: 44,
        child: isMagi
            ? Row(
                children: [
                  MagiTagButton(
                    tooltip: '收起播放页',
                    label: 'ESC',
                    onPressed: onCollapse,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: MagiSkin.pilotGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'MAGI SYSTEM // 01',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: MagiSkin.redPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  MvEntryButton(track: track, size: 20),
                  MagiTagButton(
                    tooltip: '歌曲详情',
                    label: 'SPEC',
                    onPressed: onSongDetail,
                  ),
                  const SizedBox(width: 6),
                  MagiTagButton(
                    tooltip: '播放队列',
                    label: 'QUEUE',
                    onPressed: onQueue,
                  ),
                ],
              )
            : Row(
                children: [
                  ArchiveTagButton(
                    tooltip: '收起播放页',
                    label: 'ESC',
                    onPressed: onCollapse,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 12,
                          color: OvertoneTheme.of(context).primary,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'NOW PLAYING',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: OvertoneTheme.of(context).caption.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: OvertoneTheme.of(context).textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  MvEntryButton(track: track, size: 20),
                  ArchiveTagButton(
                    tooltip: '歌曲详情',
                    label: 'SPEC',
                    onPressed: onSongDetail,
                  ),
                  const SizedBox(width: 8),
                  ArchiveTagButton(
                    tooltip: '播放队列',
                    label: 'QUEUE',
                    onPressed: onQueue,
                  ),
                ],
              ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.expanded,
    required this.track,
    required this.onCollapsePage,
    required this.onCollapseLyrics,
    required this.onSongDetail,
    required this.onQueue,
  });

  final bool expanded;
  final Track track;
  final VoidCallback onCollapsePage;
  final VoidCallback onCollapseLyrics;
  final VoidCallback onSongDetail;
  final VoidCallback onQueue;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final title = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: expanded
          ? Column(
              key: const ValueKey('expanded-title'),
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  track.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.section,
                ),
                Text(
                  track.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.caption,
                ),
              ],
            )
          : Text(
              key: const ValueKey('playing-title'),
              '正在播放',
              textAlign: TextAlign.center,
              style: theme.section,
            ),
    );

    // Stack keeps the title on the true screen center: left has 1 action,
    // right has 2 — an Expanded between unequal side widths would shift left.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: SizedBox(
        height: 56,
        child: Stack(
          children: [
            Center(child: title),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: expanded ? onCollapseLyrics : onCollapsePage,
                tooltip: expanded ? '收起歌词' : '返回',
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onSongDetail,
                    tooltip: '歌曲详情',
                    icon: const Icon(Icons.info_outline_rounded),
                  ),
                  IconButton(
                    onPressed: onQueue,
                    icon: const Icon(Icons.queue_music_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 播放页大封面：点击查看大图。
///
/// 桌面端 hover 浮现「查看大图」提示（与底栏展开图标同一套 140ms 淡入语言，
/// 静息时封面全彩）；移动端没有 hover，直接点。Hero 飞行由内部
/// [_PlayerCoverSlot] 负责，本组件只在外层包手势与提示层。
class _PlayerCoverWithZoom extends StatefulWidget {
  const _PlayerCoverWithZoom({
    required this.tag,
    required this.seed,
    required this.size,
    required this.radius,
    this.useHero = true,
  });

  final String tag;
  final String seed;

  /// 边长；`0` = 填充父容器（移动端布局）。
  final double size;
  final double radius;
  final bool useHero;

  @override
  State<_PlayerCoverWithZoom> createState() => _PlayerCoverWithZoomState();
}

class _PlayerCoverWithZoomState extends State<_PlayerCoverWithZoom> {
  bool _hovered = false;

  // Stable tear-offs so MouseRegion doesn't see new closures every rebuild.
  void _handleEnter(PointerEnterEvent _) {
    if (_hovered) return;
    setState(() => _hovered = true);
  }

  void _handleExit(PointerExitEvent _) {
    if (!_hovered || !mounted) return;
    setState(() => _hovered = false);
  }

  @override
  Widget build(BuildContext context) {
    final hint = AnimatedOpacity(
      opacity: _hovered ? 1 : 0,
      duration: const Duration(milliseconds: 140),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          color: Colors.black.withValues(alpha: 0.25),
        ),
        child: const Center(
          child: Icon(Icons.zoom_in_rounded, size: 32, color: Colors.white70),
        ),
      ),
    );
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: _handleEnter,
      onExit: _handleExit,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () =>
            showCoverViewer(context, seed: widget.seed, tag: widget.tag),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _PlayerCoverSlot(
              tag: widget.tag,
              seed: widget.seed,
              size: widget.size,
              radius: widget.radius,
              useHero: widget.useHero,
            ),
            // 提示层铺满封面； opacity 0 时不影响点击（父级 GestureDetector
            // 照常收到事件），与底栏展开图标同一处理。
            if (widget.size > 0)
              SizedBox(width: widget.size, height: widget.size, child: hint)
            else
              Positioned.fill(child: hint),
          ],
        ),
      ),
    );
  }
}

class _PlayerCoverSlot extends StatelessWidget {
  const _PlayerCoverSlot({
    required this.tag,
    required this.seed,
    required this.size,
    required this.radius,
    required this.useHero,
  });

  final String tag;
  final String seed;
  final double size;
  final double radius;

  /// Route Hero only on settled frames — avoids duplicate tags mid-FX.
  final bool useHero;

  @override
  Widget build(BuildContext context) {
    if (!useHero) {
      return CoverBox(seed: seed, size: size, radius: radius);
    }
    return CoverHero(tag: tag, seed: seed, size: size, radius: radius);
  }
}

class _CollapsedPlayerBody extends StatefulWidget {
  const _CollapsedPlayerBody({
    super.key,
    required this.track,
    required this.player,
    required this.controller,
    required this.duration,
    required this.onExpandLyrics,
    this.useHero = true,
  });

  final Track track;
  final PlayerState player;
  final PlayerController controller;
  final int duration;
  final VoidCallback onExpandLyrics;
  final bool useHero;

  static String format(int ms) {
    final safe = ms < 0 ? 0 : ms;
    final d = Duration(milliseconds: safe);
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  State<_CollapsedPlayerBody> createState() => _CollapsedPlayerBodyState();
}

class _CollapsedPlayerBodyState extends State<_CollapsedPlayerBody> {
  /// 同播放页：拖动只更新预览值，松手才 seek。
  double? _dragProgress;

  void _beginDrag(double value) => setState(() => _dragProgress = value);

  void _endDrag(double value) {
    widget.controller.seekTo((value * widget.duration).round());
    setState(() => _dragProgress = null);
  }

  int get duration => widget.duration;

  String format(int ms) => _CollapsedPlayerBody.format(ms);

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final skin = ArchiveSkinActive.skinOf(context);
    if (skin != ExperimentalUiSkin.off) {
      return _SkinCollapsedPlayerBody(
        skin: skin,
        track: widget.track,
        player: widget.player,
        controller: widget.controller,
        duration: widget.duration,
        onExpandLyrics: widget.onExpandLyrics,
        useHero: widget.useHero,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final bodyH = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height;
        final showError = widget.player.display == PlayerDisplayState.error;
        // Bottom chrome (meta / progress / controls) stays pinned.
        const metaH = 56.0;
        const sliderH = 48.0;
        const timeH = 22.0;
        const controlsH = 64.0;
        const padTop = OvertoneSpacing.sm;
        const padBottom = 20.0;
        final bottomH =
            padTop +
            metaH +
            (showError ? 56 : 0) +
            sliderH +
            timeH +
            controlsH +
            padBottom;
        final upperH = (bodyH - bottomH).clamp(120.0, bodyH);
        // Lyrics sit directly under the cover; split remaining upper space.
        final coverH = (upperH * 0.62).clamp(72.0, upperH - 48);
        final lyricsH = upperH - coverH;

        Widget lyrics() {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onExpandLyrics,
            onVerticalDragEnd: (d) {
              final v = d.primaryVelocity ?? 0;
              if (v < -200) widget.onExpandLyrics();
            },
            child: ClipRect(
              child: LyricPositionBuilder(
                builder: (context, positionMs) => LyricsView(
                  compact: true,
                  lines: widget.player.lyrics,
                  positionMs: positionMs,
                  isPlaying: widget.player.isPlaying,
                  status: widget.player.lyricsStatus,
                ),
              ),
            ),
          );
        }

        return Column(
          children: [
            // 1) Album cover
            SizedBox(
              height: coverH,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          OvertoneRadius.card + 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 28,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: _PlayerCoverWithZoom(
                        tag: OvertoneHeroTags.playerCover(widget.track.id),
                        seed: widget.track.coverUrl,
                        size: 0,
                        radius: OvertoneRadius.card + 4,
                        useHero: widget.useHero,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 2) Lyrics — right under the cover
            SizedBox(
              height: lyricsH,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: OvertoneSpacing.lg,
                ),
                child: lyrics(),
              ),
            ),
            // 3) Track meta + progress + controls
            SizedBox(
              height: bottomH,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  OvertoneSpacing.lg,
                  padTop,
                  OvertoneSpacing.lg,
                  padBottom,
                ),
                child: Column(
                  children: [
                    _TrackMetaRow(track: widget.track, height: metaH),
                    if (showError)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: SizedBox(
                          height: 48,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.error.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(
                                OvertoneRadius.tag,
                              ),
                            ),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.player.errorCode.isEmpty
                                  ? '播放失败，可点下一首重试'
                                  : widget.player.errorCode,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.caption.copyWith(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ),
                      ),
                    SizedBox(
                      height: sliderH + timeH,
                      child: PlayerPositionBuilder(
                        builder: (context, positionMs) {
                          final progress = (positionMs / duration).clamp(
                            0.0,
                            1.0,
                          );
                          final shownMs = _dragProgress == null
                              ? positionMs
                              : (_dragProgress! * duration).round();
                          return Column(
                            children: [
                              SizedBox(
                                height: sliderH,
                                child: Center(
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 3,
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 6,
                                      ),
                                      overlayShape:
                                          const RoundSliderOverlayShape(
                                            overlayRadius: 10,
                                          ),
                                      trackShape:
                                          const RoundedRectSliderTrackShape(),
                                    ),
                                    child: Slider(
                                      value: _dragProgress ?? progress,
                                      onChangeStart: _beginDrag,
                                      onChanged: _beginDrag,
                                      onChangeEnd: (v) => _endDrag(v),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: timeH,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        format(shownMs),
                                        style: theme.caption.copyWith(
                                          height: 1.2,
                                        ),
                                      ),
                                      Text(
                                        '-${format(duration - shownMs)}',
                                        style: theme.caption.copyWith(
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    _ControlBar(
                      player: widget.player,
                      controller: widget.controller,
                      track: widget.track,
                      compact: false,
                      height: controlsH,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 手机播放页的实验皮肤版式。
///
/// 与标准布局的分工：封面套档案/战术卡框，底部换成皮肤进度与控制栏。底部
/// chrome 用自然高度，封面与歌词按剩余空间弹性分配，窄屏与长屏都不溢出。
class _SkinCollapsedPlayerBody extends StatefulWidget {
  const _SkinCollapsedPlayerBody({
    required this.skin,
    required this.track,
    required this.player,
    required this.controller,
    required this.duration,
    required this.onExpandLyrics,
    this.useHero = true,
  });

  final ExperimentalUiSkin skin;
  final Track track;
  final PlayerState player;
  final PlayerController controller;
  final int duration;
  final VoidCallback onExpandLyrics;
  final bool useHero;

  @override
  State<_SkinCollapsedPlayerBody> createState() =>
      _SkinCollapsedPlayerBodyState();
}

class _SkinCollapsedPlayerBodyState extends State<_SkinCollapsedPlayerBody> {
  double? _dragProgress;

  void _beginDrag(double value) => setState(() => _dragProgress = value);

  void _endDrag(double value) {
    widget.controller.seekTo((value * widget.duration).round());
    setState(() => _dragProgress = null);
  }

  String format(int ms) => _CollapsedPlayerBody.format(ms);

  Widget _coverPanel() {
    final isSwiss = widget.skin == ExperimentalUiSkin.swiss;
    final cover = _PlayerCoverWithZoom(
      tag: OvertoneHeroTags.playerCover(widget.track.id),
      seed: widget.track.coverUrl,
      size: 0,
      radius: 0,
      useHero: widget.useHero,
    );
    return LayoutBuilder(
      builder: (context, box) {
        // 卡框除封面外的固定高度/宽度：顶部标题行、刻度尺、底部信息行与内边距。
        final chromeH = isSwiss ? 84.0 : 72.0;
        final chromeW = isSwiss ? 26.0 : 18.0;
        if (box.maxHeight < chromeH + 96 || box.maxWidth < chromeW + 96) {
          // 空间不足以放下卡框：只保留方角封面，绝不溢出。
          final side = math.min(box.maxHeight, box.maxWidth - 32);
          return Center(
            child: SizedBox.square(
              dimension: side.clamp(0.0, double.infinity),
              child: cover,
            ),
          );
        }
        final side = math.min(
          box.maxHeight - chromeH,
          box.maxWidth - chromeW - 32,
        );
        return Center(
          child: SizedBox(
            width: side + chromeW,
            child: isSwiss
                ? ArchiveCardFrame(
                    org: widget.track.platform.label,
                    clearance: widget.track.isVip ? 'VIP' : '公开',
                    child: SizedBox.square(dimension: side, child: cover),
                  )
                : MagiTargetFrame(
                    sourceCode: widget.track.platform.label.toUpperCase(),
                    clearance: widget.track.isVip ? 'VIP-01' : 'PUBLIC',
                    child: SizedBox.square(dimension: side, child: cover),
                  ),
          ),
        );
      },
    );
  }

  Widget _lyrics() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onExpandLyrics,
      onVerticalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v < -200) widget.onExpandLyrics();
      },
      child: ClipRect(
        child: LyricPositionBuilder(
          builder: (context, positionMs) => LyricsView(
            compact: true,
            lines: widget.player.lyrics,
            positionMs: positionMs,
            isPlaying: widget.player.isPlaying,
            status: widget.player.lyricsStatus,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final isSwiss = widget.skin == ExperimentalUiSkin.swiss;
    final showError = widget.player.display == PlayerDisplayState.error;
    return Column(
      children: [
        Expanded(
          child: Column(
            children: [
              Expanded(flex: 62, child: _coverPanel()),
              Expanded(
                flex: 38,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: OvertoneSpacing.lg,
                  ),
                  child: _lyrics(),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            OvertoneSpacing.lg,
            8,
            OvertoneSpacing.lg,
            20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SkinTrackMeta(
                skin: widget.skin,
                track: widget.track,
                player: widget.player,
              ),
              if (showError) ...[
                const SizedBox(height: 8),
                _PlayerErrorNotice(
                  message: widget.player.errorCode,
                  loginPlatform:
                      widget.player.errorKind == PlayerErrorKind.loginRequired
                      ? widget.track.platform
                      : null,
                ),
              ],
              const SizedBox(height: 8),
              PlayerPositionBuilder(
                builder: (context, positionMs) {
                  final progress = (positionMs / widget.duration).clamp(
                    0.0,
                    1.0,
                  );
                  final shownMs = _dragProgress == null
                      ? positionMs
                      : (_dragProgress! * widget.duration).round();
                  if (!isSwiss) {
                    return MagiProgressGauge(
                      positionMs: shownMs,
                      durationMs: widget.duration,
                      onSeek: (ms) => widget.controller.seekTo(ms.round()),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ArchiveProgressRule(
                        value: progress,
                        onDrag: _beginDrag,
                        onEnd: _endDrag,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            format(shownMs),
                            style: theme.caption.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                              color: theme.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '-${format(widget.duration - shownMs)}',
                            style: theme.caption.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                              color: theme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),
              if (isSwiss)
                ArchiveControlBar(
                  player: widget.player,
                  controller: widget.controller,
                  track: widget.track,
                )
              else
                MagiControlBar(
                  player: widget.player,
                  controller: widget.controller,
                  track: widget.track,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 手机播放页的曲目元信息：swiss 的编号/规格排版，或 MAGI 的战术参数块。
class _SkinTrackMeta extends StatelessWidget {
  const _SkinTrackMeta({
    required this.skin,
    required this.track,
    required this.player,
  });

  final ExperimentalUiSkin skin;
  final Track track;
  final PlayerState player;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    if (skin == ExperimentalUiSkin.magi) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '/// PRIORITY: LEVEL-AAA // SYNC: 100% ///',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: MagiSkin.redPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'CODE: ${track.platform.label.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: MagiSkin.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            track.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
              height: 1.15,
              color: MagiSkin.textPrimary,
              fontFamilyFallback: ['Songti SC', 'SimSun', 'STSong', 'Noto Serif SC'],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Flexible(
                child: Text(
                  'ARTIST: [ ${track.artist.isEmpty ? "UNKNOWN" : track.artist} ]',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: MagiSkin.hazardGold,
                  ),
                ),
              ),
              if (track.album.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '// ALBUM: [ ${track.album} ]',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: MagiSkin.textTertiary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          MagiEqualizerBar(isPlaying: player.isPlaying),
          const SizedBox(height: 6),
          const MagiConsensusBar(),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              '01 / NOW PLAYING',
              style: theme.caption.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: theme.primary,
              ),
            ),
            const Spacer(),
            if (track.platform.label.isNotEmpty)
              Text(
                track.platform.label.toUpperCase(),
                style: theme.caption.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: theme.textTertiary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          track.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.greeting.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Flexible(
              child: Text(
                track.artist.isEmpty ? '未知歌手' : track.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.body.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (track.album.isNotEmpty) ...[
              Text(
                '  /  ',
                style: theme.caption.copyWith(
                  fontWeight: FontWeight.w300,
                  color: theme.textTertiary,
                ),
              ),
              Expanded(
                child: Text(
                  track.album,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.caption.copyWith(
                    color: theme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(height: 1, color: theme.divider),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              'SPECIFICATIONS',
              style: theme.caption.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: theme.textTertiary,
              ),
            ),
            const Spacer(),
            _PlayerQualityChip(track: track),
          ],
        ),
      ],
    );
  }
}

class _TrackMetaRow extends StatelessWidget {
  const _TrackMetaRow({required this.track, required this.height});

  final Track track;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    return SizedBox(
      height: height,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: SizedBox(
          key: ValueKey(track.id),
          height: height,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.title.copyWith(height: 1.2),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${track.artist} · ${track.album}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.caption.copyWith(height: 1.2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // 当前曲目来自哪个音源（混排队列里尤其需要）。
                        SourceBadge(platform: track.platform),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _PlayerQualityChip(track: track),
            ],
          ),
        ),
      ),
    );
  }
}

/// 桌面播放页的持久错误位。移动端紧凑布局与歌词页已有错误文案，
/// 桌面左栏此前完全没有，登录失败看起来就是「点了没反应」。
class _PlayerErrorNotice extends StatelessWidget {
  const _PlayerErrorNotice({required this.message, this.loginPlatform});

  final String message;
  final MusicPlatform? loginPlatform;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final color = Theme.of(context).colorScheme.error;
    // 皮肤里没有色块位置：danger 靠左侧 3px 色条 + 文字色表达，
    // 跟 ArchiveSectionLabel 同一个语汇，出错时仍然跳得出来。
    final skinned = ArchiveSkinActive.skinOf(context) != ExperimentalUiSkin.off;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(skinned ? 8 : 10, 6, 4, 6),
      decoration: skinned
          ? BoxDecoration(
              border: Border(left: BorderSide(color: color, width: 3)),
            )
          : BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(OvertoneRadius.tag),
            ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message.trim().isEmpty ? '播放失败，可点下一首重试' : message.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.caption.copyWith(
                color: color,
                fontSize: 12,
                height: 1.25,
              ),
            ),
          ),
          if (loginPlatform != null)
            TextButton(
              onPressed: () => context.push(loginRouteFor(loginPlatform!)),
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('去登录'),
            ),
        ],
      ),
    );
  }
}

/// 播放页音质区域：VIP 与实际音质并排展示；音质 chip 可点切换。
class _PlayerQualityChip extends ConsumerWidget {
  const _PlayerQualityChip({required this.track, this.compact = false});

  final Track track;

  /// 窄屏顶栏只保留 VIP / 音质徽标，隐藏倍速、桌面歌词等次级入口。
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = OvertoneTheme.of(context);
    final player = ref.watch(playerControllerProvider);
    final preferred = ref.watch(settingsControllerProvider).quality;
    final resolved = player.resolvedQuality;
    final quality = resolved ?? preferred;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (track.isVip) ...[
          const QualityBadge(label: 'VIP', solid: true),
          const SizedBox(width: 4),
        ],
        InkWell(
          borderRadius: BorderRadius.circular(OvertoneRadius.small),
          onTap: () => showQualitySheet(context, ref),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                QualityBadge(
                  label: quality.badge,
                  solid:
                      quality == AppQuality.sq || quality == AppQuality.hiRes,
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.unfold_more_rounded,
                  size: 14,
                  color: theme.textSecondary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
        if (!compact) ...[
          const SpeedChip(),
          const SizedBox(width: 4),
          const LyricDisplayButton(),
          const SizedBox(width: 2),
          // 逐曲时间微调：全局偏移在设置页，这里只调当前这首。
          LyricOffsetButton(trackKey: track.identityKey),
        ],
      ],
    );
  }
}

class _ControlBar extends ConsumerWidget {
  const _ControlBar({
    required this.player,
    required this.controller,
    required this.track,
    required this.compact,
    this.height,
  });

  final PlayerState player;
  final PlayerController controller;
  final Track track;
  final bool compact;
  final double? height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = OvertoneTheme.of(context);
    // Always bind the live player state so the play/pause icon cannot go stale.
    final live = ref.watch(playerControllerProvider);
    final liked = ref.watch(likesProvider).any((t) => t.id == track.id);
    final barH = height ?? (compact ? 56.0 : 64.0);
    final playSize = compact ? 50.0 : 56.0;
    final isPlaying = live.isPlaying;
    final isLoading = live.isLoading;

    return SizedBox(
      height: barH,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // FM 会话：循环/随机对"流"没有意义，这个位置换成 FM 原生的「不喜欢」。
            if (live.queueSource == PlaybackQueueSource.fm)
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: () =>
                    ref.read(fmControllerProvider.notifier).dislike(),
                tooltip: '不喜欢，换下一首',
                icon: Icon(
                  Icons.thumb_down_alt_rounded,
                  color: theme.favorite,
                  size: 24,
                ),
              )
            else
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: controller.cycleMode,
                tooltip: _modeLabel(live.mode),
                icon: Icon(
                  switch (live.mode) {
                    PlayerLoopMode.order => Icons.trending_flat_rounded,
                    PlayerLoopMode.listLoop => Icons.repeat_rounded,
                    PlayerLoopMode.shuffle => Icons.shuffle_rounded,
                    PlayerLoopMode.single => Icons.repeat_one_rounded,
                  },
                  color: theme.textSecondary,
                  size: 24,
                ),
              ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              // FM 只能池内回退：退到会话第一首就禁用，绝不环绕到队列尾部。
              onPressed: live.canStepBack ? controller.previous : null,
              tooltip: live.canStepBack ? '上一首' : '已经是私人 FM 的第一首',
              icon: Icon(
                Icons.skip_previous_rounded,
                size: 32,
                color: live.canStepBack
                    ? theme.textPrimary
                    : theme.textTertiary,
              ),
            ),
            Container(
              width: playSize,
              height: playSize,
              decoration: BoxDecoration(
                color: theme.primary,
                shape: BoxShape.circle,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: isLoading
                    ? Padding(
                        key: const ValueKey('play-loading'),
                        padding: EdgeInsets.all(playSize * 0.28),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : IconButton(
                        key: const ValueKey('play-toggle'),
                        padding: EdgeInsets.zero,
                        onPressed: controller.togglePlay,
                        icon: PlayPauseIcon(
                          playing: isPlaying,
                          size: compact ? 28 : 32,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              onPressed: controller.next,
              icon: Icon(
                Icons.skip_next_rounded,
                size: 32,
                color: theme.textPrimary,
              ),
            ),
            LikeButton(
              liked: liked,
              onToggle: () => ref.read(likesProvider.notifier).toggle(track),
              size: 22,
              activeColor: theme.favorite,
              inactiveColor: theme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  static String _modeLabel(PlayerLoopMode mode) => playbackModeLabel(mode);
}
