import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/archive_skin.dart';
import '../../core/theme/cover_palette.dart';
import '../../core/theme/glass_tokens.dart';
import '../../core/theme/hero_tags.dart';
import '../../core/theme/overtone_theme.dart';
import '../../core/theme/overtone_tokens.dart';
import '../../features/player/player_controller.dart';
import 'common.dart';
import 'cover_box.dart';
import 'liquid_glass.dart';
import 'player_icon_buttons.dart';
import 'package:overtone/l10n/l10n.dart';

class MiniPlayerBar extends ConsumerWidget {
  const MiniPlayerBar({super.key, this.glassGlide = false});

  /// 滚动中（由 [RootShell] 的 `_glassGliding` 注入）：模糊降到
  /// [OvertoneTheme.glassThinSigmaScrolling]，滚停 300ms 后恢复。
  final bool glassGlide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = OvertoneTheme.of(context);
    // 细粒度订阅：播放栏只在「曲目 / 时长 / 加载态 / 播放态」变化时重建，
    // 不再被音量、循环模式、队列增删等离散变更连带重建。
    final track = ref.watch(playerControllerProvider.select((s) => s.current));
    if (track == null) return const SizedBox.shrink();
    final durationMs = ref.watch(
      playerControllerProvider.select((s) => s.durationMs),
    );
    final isLoading = ref.watch(
      playerControllerProvider.select((s) => s.isLoading),
    );
    final isPlaying = ref.watch(
      playerControllerProvider.select((s) => s.isPlaying),
    );

    // 实验皮肤：硬边、去浮层阴影，进度条改单色（封面渐变色属于标准皮肤语汇）。
    final skinned = ArchiveSkinActive.of(context);
    final skeuo = ArchiveSkinActive.skinOf(context).isSkeuo;
    final isLight = theme.palette.isLight;

    // 进度条独立成节点：拟物浮光（胶囊）贴上沿，其余皮肤保持底部细线。
    final progressLine = SizedBox(
      height: 2,
      child: PlayerPositionBuilder(
        builder: (context, positionMs) {
          final progress = durationMs == 0
              ? 0.0
              : (positionMs / durationMs).clamp(0.0, 1.0);
          return Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: skinned ? theme.primary : null,
                  gradient: skinned
                      ? null
                      : LinearGradient(
                          colors: [
                            CoverPalette.accentFromSeed(
                              track.coverUrl,
                              theme.palette,
                            ),
                            CoverPalette.accentFromSeed(
                              track.coverUrl,
                              theme.palette,
                            ).withValues(alpha: 0.4),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (skeuo) progressLine,
        Container(
          decoration: skinned || !skeuo
              ? BoxDecoration(
                  border: Border(
                    top: BorderSide(color: theme.divider),
                    bottom: BorderSide(color: theme.divider),
                  ),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
            child: Row(
              children: [
                CoverHero(
                  tag: OvertoneHeroTags.playerCover(track.id),
                  seed: track.coverUrl,
                  size: 44,
                  radius: skinned ? 0 : 10,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0, 0.25),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: Column(
                      key: ValueKey(track.id),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: skinned
                              ? theme.body.copyWith(fontWeight: FontWeight.w700)
                              : theme.body,
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                track.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.caption,
                              ),
                            ),
                            const SizedBox(width: 6),
                            // 混排队列下这首歌来自哪个源（紧凑只读小字）。
                            SourceLabel(
                              platform: track.platform,
                              compact: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.shangYiShou,
                  onPressed: isLoading
                      ? null
                      : () => ref
                            .read(playerControllerProvider.notifier)
                            .previous(),
                  icon: Icon(
                    Icons.skip_previous_rounded,
                    color: theme.textSecondary,
                  ),
                ),
                IconButton(
                  tooltip: isPlaying
                      ? context.l10n.zanTing
                      : context.l10n.boFang,
                  onPressed: isLoading
                      ? null
                      : () => ref
                            .read(playerControllerProvider.notifier)
                            .togglePlay(),
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: isLoading
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.primary,
                            ),
                          )
                        : PlayPauseIcon(
                            playing: isPlaying,
                            size: 32,
                            color: theme.primary,
                            spring: skeuo,
                          ),
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.xiaYiShou,
                  onPressed: isLoading
                      ? null
                      : () =>
                            ref.read(playerControllerProvider.notifier).next(),
                  icon: Icon(
                    Icons.skip_next_rounded,
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Progress alone listens to the live cursor — no TweenAnimationBuilder
        // (it used to restart a 200ms animation on every tick and never settle).
        if (!skeuo) progressLine,
      ],
    );

    // 实验皮肤：原样平铺（硬边、无阴影、底部细进度线）。
    if (skinned) {
      return Material(
        color: theme.surface,
        elevation: 0,
        child: InkWell(onTap: () => context.push('/player'), child: body),
      );
    }

    // 默认皮肤：改版前的原生 Material 条（elevation 投影 + 上下发丝线），
    // 不带浮起胶囊、玻璃与额外外边距。
    if (!skeuo) {
      return Material(
        color: theme.surface,
        elevation: isLight ? 1.5 : 8,
        shadowColor: isLight
            ? Colors.black.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.45),
        child: InkWell(onTap: () => context.push('/player'), child: body),
      );
    }

    // 拟物浮光：浮起胶囊——regular 玻璃（σ 16 / 78~88% 实底，保证 44dp
    // 封面旁的小字不糊）、圆角走 token、raised 阴影、进度线贴胶囊上沿；
    // 外边距与 Dock 同值，两条左右对齐。玻璃层 padding 归零，条的内部
    // 留白仍由 body 自己控制。
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        OvertoneSpacing.floatingInset,
        0,
        OvertoneSpacing.floatingInset,
        OvertoneSpacing.sm,
      ),
      child: LiquidGlass(
        key: const ValueKey('mini-bar-glass'),
        tier: GlassTier.regular,
        radius: OvertoneRadius.bar,
        shadow: theme.shadowRaised,
        scrim: theme.miniBarScrim,
        padding: EdgeInsets.zero,
        // 滚动时自动降一档模糊（regular：3.5 → 2.2），不用手写 σ 覆盖。
        scrolling: glassGlide,
        pressable: true,
        child: Material(
          // 圆角已由 [LiquidGlass] 的 ClipRRect 裁掉，这里不再叠第二层裁剪。
          color: Colors.transparent,
          child: InkWell(onTap: () => context.push('/player'), child: body),
        ),
      ),
    );
  }
}
