import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/fm_mode.dart';
import '../../core/models/playback_source.dart';
import '../../core/models/track.dart';
import '../../core/theme/cover_palette.dart';
import '../../core/theme/hero_tags.dart';
import '../../core/theme/archive_skin.dart';
import '../../core/theme/magi_skin.dart';
import '../../core/theme/overtone_theme.dart';
import '../../shared/widgets/archive_chrome.dart';
import '../../shared/widgets/magi_chrome.dart';
import '../../core/theme/overtone_tokens.dart';
import '../../core/theme/responsive.dart';
import '../fm/fm_controller.dart';
import '../fm/fm_radio_card.dart';
import '../player/player_controller.dart';
import '../../shared/widgets/archive_skin_scope.dart';

/// 发现页搜索框正下方的快捷入口：私人 FM 舞台（与 /fm 同构）+ 为你推荐入口卡。
///
/// 舞台直接复用 [FmStage] / [FmRadioCard] / [FmVinylCarousel]（桌面 272 / 手机 180），
/// 与独立私人 FM 页同一套「卡 + 黑胶一行」视觉；起播/切模式仍就地完成，不跳全屏播放页。
///
/// 独立成文件是为了可测试：[ExplorePage] 的 initState 会发起真实网络请求
/// （dio 的超时 Timer 在 FakeAsync 测试里永远挂起），入口本身无网络副作用，
/// 单独 pump 即可覆盖布局与导航。
class QuickEntries extends ConsumerStatefulWidget {
  const QuickEntries({super.key});

  @override
  ConsumerState<QuickEntries> createState() => _QuickEntriesState();
}

class _QuickEntriesState extends ConsumerState<QuickEntries>
    with TickerProviderStateMixin {
  late final AnimationController _spin;
  late final AnimationController _bars;

  @override
  void initState() {
    super.initState();
    // 与 /fm 舞台一致的自旋 / 频谱时基；仅在播放时 repeat，空闲停表省电
    // 也让测试的 pumpAndSettle 能收敛。
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );
    _bars = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
  }

  @override
  void dispose() {
    _spin.dispose();
    _bars.dispose();
    super.dispose();
  }

  void _syncAnimations({required bool playing}) {
    if (playing) {
      if (!_spin.isAnimating) _spin.repeat();
      if (!_bars.isAnimating) _bars.repeat();
    } else {
      _spin.stop();
      _bars.stop();
    }
  }

  /// 与 /fm 一致：已激活则就地切换播放/暂停；有预览缓存则从缓存即时起播；
  /// 否则按 pending 开台重新拉取。
  Future<void> _startOrToggle() async {
    final player = ref.read(playerControllerProvider);
    final fm = ref.read(fmControllerProvider);
    final fmCtl = ref.read(fmControllerProvider.notifier);
    final playerCtl = ref.read(playerControllerProvider.notifier);
    final fmActive = fm.active || player.queueSource == PlaybackQueueSource.fm;
    if (fmActive && player.current != null) {
      playerCtl.togglePlay();
      return;
    }
    if (fm.previewTracks.isNotEmpty) {
      await fmCtl.playCachedPreview();
      return;
    }
    await fmCtl.start(mode: fm.pendingMode, pool: fm.pendingPool);
  }

  /// 模式切换（对齐 EchoMusic PersonalFm.vue 的 handleChangePersonalFmMode）：
  /// - FM 已激活 / 正在播放：立即以新模式重开会话；
  /// - 否则只改 pending，等起播时生效。
  void _handleModeChanged(FmMode newMode) {
    final fmState = ref.read(fmControllerProvider);
    if (fmState.loading) return;

    final player = ref.read(playerControllerProvider);
    final isFmActive = player.queueSource == PlaybackQueueSource.fm;

    if (isFmActive && newMode == fmState.mode) return;

    final fm = ref.read(fmControllerProvider.notifier);
    // 只有 FM 会话进行中才立即重开；播云盘/歌单时只改 pending 并刷新预览，
    // 否则一点档位就把当前队列冲掉并重新拉取。
    if (isFmActive) {
      unawaited(fm.start(mode: newMode, pool: fmState.pendingPool));
    } else {
      fm.setPendingMode(newMode);
      unawaited(fm.ensurePreview());
    }
  }

  void _like() {
    ref.read(fmControllerProvider.notifier).like();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已加入我喜欢'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final fm = ref.watch(fmControllerProvider);
    final player = ref.watch(playerControllerProvider);
    final playerCtl = ref.read(playerControllerProvider.notifier);
    final fmCtl = ref.read(fmControllerProvider.notifier);

    final desktop = isDesktopView(context);
    final fmActive = fm.active || player.queueSource == PlaybackQueueSource.fm;
    // 播放器队列只在 FM 会话中复用；未起播时盘阵用预览缓存（云盘/歌单照播不误），
    // 卡面文案保持空闲态，点播从缓存即时起。
    final fmCurrent = fmActive ? player.current : null;
    final List<Track> fmQueue = fmActive ? player.queue : fm.previewTracks;
    final fmIndex = fmActive ? player.currentIndex : 0;
    final previewCover = fm.previewTracks.isNotEmpty
        ? fm.previewTracks.first.coverUrl
        : 'fm';
    final showPlaying = player.isPlaying && fmActive;
    _syncAnimations(playing: showPlaying);
    final accent = CoverPalette.accentFromSeed(
      fmCurrent?.coverUrl ?? 'fm',
      theme.palette,
    );

    final radioCard = FmRadioCard(
      theme: theme,
      accent: accent,
      mode: fm.pendingMode,
      pool: fm.pendingPool,
      // 无档位轴的源（网易）隐藏模式胶囊，卡面改挂电台名。
      stationTitle: fmCtl.hasModeAxis ? null : '私人 FM',
      stationSubtitle: fmCtl.hasModeAxis
          ? null
          : '${fmCtl.displaySource?.label ?? ''}私人 FM',
      showModeAxis: fmCtl.hasModeAxis,
      onMode: _handleModeChanged,
      onPlay: _startOrToggle,
      onDislike: fmCtl.dislike,
      onLike: _like,
      isPlaying: showPlaying,
      bars: _bars,
      trackName: fmCurrent?.name ?? '',
      artist: fmCurrent?.artist ?? '',
      loading: fm.loading || fm.previewLoading,
      actionsEnabled: fmCurrent != null,
    );

    final carousel = FmVinylCarousel(
      theme: theme,
      accent: accent,
      spin: _spin,
      tracks: fmQueue,
      currentIndex: fmIndex,
      fallbackCoverUrl: fmActive ? (fmCurrent?.coverUrl ?? 'fm') : previewCover,
      playing: showPlaying,
      onPlayIndex: (index) {
        if (index < 0 || index >= fmQueue.length) return;
        if (fmActive && index == player.currentIndex) return;
        if (fmActive) {
          playerCtl.playAtIndex(index);
        } else {
          unawaited(
            ref
                .read(fmControllerProvider.notifier)
                .playCachedPreview(index: index),
          );
        }
      },
      onTapCurrent: _startOrToggle,
      discSize: FmStageMetrics.discSizeFor(desktop),
      sideGap: FmStageMetrics.sideGapFor(desktop),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FmStage(desktop: desktop, radioCard: radioCard, carousel: carousel),
        // 舞台阴影外溢略多，给下方入口留一点空气。
        const SizedBox(height: OvertoneSpacing.lg),
        // Android 无桌面侧栏：挂「为你推荐 + 探索」入口。窄屏纵向堆叠，
        // 半宽卡片里的副标题会把 68 高的卡挤爆。
        LayoutBuilder(
          builder: (context, constraints) {
            final sideBySide = constraints.maxWidth >= 520;
            final recommend = RecommendHubEntryCard(
              onTap: () => context.push('/recommend'),
            );
            final discovery = DiscoveryEntryCard(
              onTap: () => context.push('/discovery'),
            );
            if (!sideBySide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [recommend, const SizedBox(height: 12), discovery],
              );
            }
            return Row(
              children: [
                Expanded(child: recommend),
                const SizedBox(width: 12),
                Expanded(child: discovery),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// 发现页「探索」入口卡（对齐侧栏「探索」/ EchoMusic 探索发现）。
class DiscoveryEntryCard extends StatelessWidget {
  const DiscoveryEntryCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final archive = ArchiveSkinActive.of(context);
    final magi = ArchiveSkinActive.skinOf(context).isEva;
    final ev = context.eva;
    if (magi) {
      return _MagiEntryCard(
        key: const ValueKey('discovery_entry_card'),
        stamp: '探',
        stampInverted: true,
        title: '音律探索',
        subtitle: '歌单 · 榜单 · 新碟 · 歌手 // ARCHIVE',
        action: Icons.arrow_forward_rounded,
        onTap: onTap,
      );
    }
    return Material(
      key: const ValueKey('discovery_entry_card'),
      color: theme.surface,
      elevation: magi ? 6 : 0,
      shadowColor: ev.accent.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(archive ? 0 : OvertoneRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(archive ? 0 : OvertoneRadius.card),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              archive ? 0 : OvertoneRadius.card,
            ),
            border: Border.all(
              color: magi
                  ? ev.accentWash
                  : (archive
                        ? ArchiveChrome.lineStrong(theme)
                        : theme.divider),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    archive ? 0 : OvertoneRadius.tile,
                  ),
                  color: archive ? Colors.transparent : theme.primary,
                  border: archive
                      ? Border.all(color: ArchiveChrome.lineStrong(theme))
                      : null,
                ),
                child: Icon(
                  Icons.explore_rounded,
                  color: archive ? theme.primary : Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '探索',
                      style: theme.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        letterSpacing: archive ? 0.6 : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '歌单 · 榜单 · 新碟 · 歌手',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.caption.copyWith(
                        fontSize: 12,
                        letterSpacing: archive ? 0.4 : null,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    archive ? 0 : OvertoneRadius.tag,
                  ),
                  color: archive
                      ? Colors.transparent
                      : theme.textSecondary.withValues(alpha: 0.12),
                  border: archive
                      ? Border.all(color: ArchiveChrome.lineStrong(theme))
                      : null,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: theme.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 发现页「为你推荐」入口卡（EchoMusic Home feature-card 风格）。
///
/// 点击进入推荐聚合页 `/recommend`；每日推荐成为聚合页内子入口。
class RecommendHubEntryCard extends StatelessWidget {
  const RecommendHubEntryCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final archive = ArchiveSkinActive.of(context);
    final magi = ArchiveSkinActive.skinOf(context).isEva;
    final ev = context.eva;
    final dayStr = DateTime.now().day.toString();
    if (magi) {
      return _MagiEntryCard(
        key: const ValueKey('recommend_hub_entry_card'),
        stamp: dayStr,
        title: '为你推荐',
        subtitle: '每日 · 风格 · 歌单精选 // DAILY SYNC',
        action: Icons.auto_awesome_rounded,
        onTap: onTap,
      );
    }
    return Material(
      key: const ValueKey('recommend_hub_entry_card'),
      color: theme.surface,
      elevation: magi ? 6 : 0,
      shadowColor: ev.accent.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(archive ? 0 : OvertoneRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(archive ? 0 : OvertoneRadius.card),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              archive ? 0 : OvertoneRadius.card,
            ),
            border: Border.all(
              color: magi
                  ? ev.accentWash
                  : (archive
                        ? ArchiveChrome.lineStrong(theme)
                        : theme.divider),
            ),
          ),
          child: Row(
            children: [
              // EchoMusic: .feature-icon（大号日历数字）
              Hero(
                tag: OvertoneHeroTags.dailyRecommendBadge,
                flightShuttleBuilder:
                    OvertoneHeroTags.dailyRecommendBadgeFlightShuttle,
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        archive ? 0 : OvertoneRadius.tile,
                      ),
                      color: archive ? theme.textPrimary : theme.primary,
                      boxShadow: magi ? ev.glow : null,
                    ),
                    child: Center(
                      child: Text(
                        dayStr,
                        style: TextStyle(
                          color: archive ? theme.surface : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '为你推荐',
                      style: theme.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        letterSpacing: archive ? 0.6 : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '每日 · 风格 · 歌单精选',
                      style: theme.caption.copyWith(
                        fontSize: 12,
                        letterSpacing: archive ? 0.4 : null,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // EchoMusic: .feature-action 轻色块动作圆钮
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    archive ? 0 : OvertoneRadius.tag,
                  ),
                  color: archive
                      ? Colors.transparent
                      : theme.primary.withValues(alpha: 0.12),
                  border: archive
                      ? Border.all(color: ArchiveChrome.lineStrong(theme))
                      : null,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: theme.primary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// MAGI 首页入口卡：硬边白框 + 大号图章 + 反色说明条。
class _MagiEntryCard extends StatelessWidget {
  const _MagiEntryCard({
    super.key,
    required this.stamp,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.onTap,
    this.stampInverted = false,
  });

  final String stamp;
  final String title;
  final String subtitle;
  final IconData action;
  final VoidCallback onTap;
  final bool stampInverted;

  @override
  Widget build(BuildContext context) {
    final ev = context.eva;
    final stampColor = stampInverted
        ? ev.textPrimary
        : ev.accent;
    final stampTextColor = stampInverted
        ? ev.bgBase
        : ev.textPrimary;
    return Material(
      color: ev.bgBase,
      child: InkWell(
        onTap: onTap,
        hoverColor: ev.accent.withValues(alpha: 0.08),
        child: Container(
          height: 92,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: Border.all(color: ev.textPrimary, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: stampColor,
                  border: Border.all(color: ev.textPrimary, width: 2),
                ),
                child: Center(
                  child: MagiDisplayText(
                    stamp,
                    matisse: true,
                    compression: 0.92,
                    style: TextStyle(
                      fontSize: stamp.length > 1 ? 30 : 36,
                      fontWeight: FontWeight.w800,
                      height: 0.95,
                      color: stampTextColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: MagiDisplayText(
                        title,
                        compression: 0.86,
                        style: TextStyle(
                          fontSize: MagiSkin.entryTitleSize,
                          fontWeight: FontWeight.w900,
                          height: 0.95,
                          color: ev.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      color: ev.textPrimary,
                      child: Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: ev.bgBase,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  border: Border.all(color: ev.textPrimary, width: 2),
                ),
                child: Icon(action, size: 22, color: ev.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
