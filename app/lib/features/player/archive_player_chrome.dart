import 'dart:math' as math;

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

/// 纸白发丝网格 + 边缘刻度尺。作为播放页背后的整屏图层绘制
/// （档案皮肤下 Scaffold 背景设为透明，才能透出来）。
class ArchiveGridPainter extends CustomPainter {
  ArchiveGridPainter({required this.theme});

  final OvertoneTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.bg);
    final hair = Paint()
      ..color = ArchiveChrome.gridLine(theme)
      ..strokeWidth = 1;
    final ruler = Paint()
      ..color = ArchiveChrome.rule(theme)
      ..strokeWidth = 1;

    const step = 56.0;
    for (double x = step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), hair);
    }
    for (double y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), hair);
    }
    for (double x = 0; x < size.width; x += 14) {
      final tall = (x / 14).round() % 5 == 0;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, tall ? 11 : 5),
        tall ? ruler : hair,
      );
    }
    for (double y = 0; y < size.height; y += 14) {
      final tall = (y / 14).round() % 5 == 0;
      canvas.drawLine(
        Offset(0, y),
        Offset(tall ? 11 : 5, y),
        tall ? ruler : hair,
      );
    }
  }

  @override
  bool shouldRepaint(ArchiveGridPainter old) => old.theme != theme;
}

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

/// 发丝进度线：已播段实线、未播段淡线、每 10% 一道刻度，游标是一根竖线。
///
/// 不用 Slider —— Slider 的 track 有最小高度与触摸垫，画不出 1px 的发丝感。
/// 拖动语义与 Slider 一致：按下/拖动只更新预览，松手才 seek。
class ArchiveProgressRule extends StatelessWidget {
  const ArchiveProgressRule({
    super.key,
    required this.value,
    required this.onDrag,
    required this.onEnd,
  });

  final double value;
  final void Function(double ratio) onDrag;
  final void Function(double ratio) onEnd;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    return LayoutBuilder(
      builder: (context, box) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        // 点哪跳哪：down 先给一次预览，up 才真正 seek。
        onTapDown: (d) =>
            onDrag((d.localPosition.dx / box.maxWidth).clamp(0.0, 1.0)),
        onTapUp: (d) =>
            onEnd((d.localPosition.dx / box.maxWidth).clamp(0.0, 1.0)),
        onHorizontalDragStart: (d) =>
            onDrag((d.localPosition.dx / box.maxWidth).clamp(0.0, 1.0)),
        onHorizontalDragUpdate: (d) =>
            onDrag((d.localPosition.dx / box.maxWidth).clamp(0.0, 1.0)),
        onHorizontalDragEnd: (d) => onEnd(
          (d.localPosition.dx / math.max(1.0, box.maxWidth)).clamp(0.0, 1.0),
        ),
        child: SizedBox(
          height: 22,
          child: CustomPaint(
            painter: _ProgressRulePainter(
              theme: theme,
              value: value.clamp(0.0, 1.0),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressRulePainter extends CustomPainter {
  _ProgressRulePainter({required this.theme, required this.value});

  final OvertoneTheme theme;
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.height / 2;
    final played = size.width * value;
    final rest = Paint()
      ..color = ArchiveChrome.gridLine(theme)
      ..strokeWidth = 1;
    final done = Paint()
      ..color = theme.textPrimary
      ..strokeWidth = 2;
    final tick = Paint()
      ..color = ArchiveChrome.rule(theme)
      ..strokeWidth = 1;
    final cursor = Paint()
      ..color = theme.primary
      ..strokeWidth = 2;

    canvas.drawLine(Offset(0, mid), Offset(size.width, mid), rest);
    if (played > 0) {
      canvas.drawLine(Offset(0, mid), Offset(played, mid), done);
    }
    for (var i = 0; i <= 10; i++) {
      final x = size.width * i / 10;
      canvas.drawLine(Offset(x, mid - 5), Offset(x, mid + 5), tick);
    }
    canvas.drawLine(Offset(played, mid - 9), Offset(played, mid + 9), cursor);
  }

  @override
  bool shouldRepaint(_ProgressRulePainter old) =>
      old.value != value || old.theme != theme;
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
