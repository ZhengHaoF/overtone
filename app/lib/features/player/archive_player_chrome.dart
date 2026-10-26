import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/playback_source.dart';
import '../../core/models/track.dart';
import '../../core/theme/overtone_theme.dart';
import '../../features/likes/likes_controller.dart';
import '../../shared/widgets/archive_chrome.dart';
import '../fm/fm_controller.dart';
import 'player_controller.dart';

/// 「档案终端」皮肤的播放页专用组件。
///
/// 通用原语（TagButton / SectionLabel / Ruler / Ticks）已抽到
/// `shared/widgets/archive_chrome.dart`，内容页共用。
///
/// 只负责**外观**：交互一律由调用方把回调传进来，播放状态的读写仍然留在
/// full_player_page，避免同一份接线在两处各写一遍而漂移。
///
/// 颜色全部取自 [OvertoneTheme]，不写死 —— 皮肤换的正是这张调色板，将来出
/// 墨底版只需要再给一个 palette。

/// 档案卡外框：顶条（机构 / 权限）、刻度尺、内容、底条（强调块 + 刻度）。
///
/// 封面本体由 [child] 传入且**保持 Hero**，所以从底栏飞入的动画不受影响。
class ArchiveCardFrame extends StatelessWidget {
  const ArchiveCardFrame({
    super.key,
    required this.org,
    required this.clearance,
    required this.child,
  });

  final String org;
  final String clearance;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border.all(color: theme.textTertiary, width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(org, style: theme.caption.copyWith(letterSpacing: 1.2)),
              const Spacer(),
              Text(
                clearance,
                style: theme.caption.copyWith(letterSpacing: 1.2),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const ArchiveRuler(),
          const SizedBox(height: 10),
          child,
          const SizedBox(height: 10),
          Row(
            children: [
              Container(width: 26, height: 2, color: theme.primary),
              const SizedBox(width: 6),
              const ArchiveTicks(),
              const Spacer(),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 控制栏的档案版：五个槽位与标准皮肤一一对应，回调走同一个 controller。
class ArchiveControlBar extends ConsumerWidget {
  const ArchiveControlBar({
    super.key,
    required this.player,
    required this.controller,
    required this.track,
  });

  final PlayerState player;
  final PlayerController controller;
  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(playerControllerProvider);
    final liked = ref.watch(likesProvider).any((t) => t.id == track.id);
    final isFm = live.queueSource == PlaybackQueueSource.fm;

    return SizedBox(
      width: double.infinity,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isFm)
            ArchiveTagButton(
              tooltip: '不喜欢，换下一首',
              icon: Icons.thumb_down_alt_rounded,
              onPressed: () =>
                  ref.read(fmControllerProvider.notifier).dislike(),
            )
          else
            ArchiveTagButton(
              tooltip: playbackModeLabel(live.mode),
              icon: switch (live.mode) {
                PlayerLoopMode.order => Icons.trending_flat_rounded,
                PlayerLoopMode.listLoop => Icons.repeat_rounded,
                PlayerLoopMode.shuffle => Icons.shuffle_rounded,
                PlayerLoopMode.single => Icons.repeat_one_rounded,
              },
              onPressed: controller.cycleMode,
            ),
          ArchiveTagButton(
            tooltip: live.canStepBack ? '上一首' : '已经是私人 FM 的第一首',
            icon: Icons.skip_previous_rounded,
            onPressed: live.canStepBack ? controller.previous : null,
          ),
          ArchiveTagButton(
            tooltip: live.isPlaying ? '暂停' : '播放',
            label: live.isLoading
                ? 'LOADING'
                : (live.isPlaying ? 'PLAYING' : 'PAUSED'),
            emphasized: true,
            onPressed: controller.togglePlay,
          ),
          ArchiveTagButton(
            tooltip: '下一首',
            icon: Icons.skip_next_rounded,
            onPressed: controller.next,
          ),
          ArchiveTagButton(
            tooltip: liked ? '取消红心' : '我喜欢',
            icon: liked
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            onPressed: () => ref.read(likesProvider.notifier).toggle(track),
          ),
        ],
      ),
    );
  }
}
