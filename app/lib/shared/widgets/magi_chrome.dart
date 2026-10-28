import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/playback_source.dart';
import '../../core/models/track.dart';
import '../../core/theme/magi_skin.dart';
import '../../core/theme/overtone_theme.dart';
import '../../features/fm/fm_controller.dart';
import '../../features/likes/likes_controller.dart';
import '../../features/player/player_controller.dart';

/// EVA / MAGI 战术终端背景：细微的朱红点阵、十字准星与左右边缘刻度标尺（.eva-edge）。
class MagiGridPainter extends CustomPainter {
  const MagiGridPainter({required this.theme});

  final OvertoneTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    // 0. 战术纯黑碳素底色（确保在任何宿主亮/暗模式下背景都为深色）
    final bgPaint = Paint()..color = MagiSkin.bgBase;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // 1. 点阵背景
    final dotPaint = Paint()
      ..color = const Color(0x14FF354D)
      ..style = PaintingStyle.fill;

    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 0.8, dotPaint);
      }
    }

    // 2. 屏幕中央十字瞄准标线
    final linePaint = Paint()
      ..color = const Color(0x10FF354D)
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(0, size.height * 0.45),
      Offset(size.width, size.height * 0.45),
      linePaint,
    );

    // 3. 左右两侧刻度标尺（仿 .eva-edge：每 8px 短刻度，每 40px 长刻度）
    final shortTickPaint = Paint()
      ..color = MagiSkin.redBorderLight
      ..strokeWidth = 1.0;
    final longTickPaint = Paint()
      ..color = MagiSkin.redPrimary.withValues(alpha: 0.6)
      ..strokeWidth = 1.2;

    const topOffset = 60.0;
    final bottomOffset = size.height - 60.0;

    for (double y = topOffset; y <= bottomOffset; y += 8.0) {
      final isLong = ((y - topOffset) % 40.0).abs() < 1.0;
      final tickLen = isLong ? 8.0 : 3.0;
      final paint = isLong ? longTickPaint : shortTickPaint;

      // 左侧刻度
      canvas.drawLine(Offset(6, y), Offset(6 + tickLen, y), paint);
      // 右侧刻度
      canvas.drawLine(
        Offset(size.width - 6, y),
        Offset(size.width - 6 - tickLen, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant MagiGridPainter oldDelegate) => false;
}

/// 战术终端四角定位标尺与左上/右下状态块（参照 .eva-frame 与 .eva-corner）。
class MagiFrameCorners extends StatelessWidget {
  const MagiFrameCorners({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MagiFramePainter(),
      size: Size.infinite,
    );
  }
}

class _MagiFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cornerPaint = Paint()
      ..color = MagiSkin.redPrimary.withValues(alpha: 0.75)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const inset = 6.0;
    const len = 18.0;

    // 四角 L 型准星
    // 左上
    canvas.drawLine(const Offset(inset, inset), const Offset(inset + len, inset), cornerPaint);
    canvas.drawLine(const Offset(inset, inset), const Offset(inset, inset + len), cornerPaint);
    // 右上
    canvas.drawLine(Offset(size.width - inset, inset), Offset(size.width - inset - len, inset), cornerPaint);
    canvas.drawLine(Offset(size.width - inset, inset), Offset(size.width - inset, inset + len), cornerPaint);
    // 左下
    canvas.drawLine(Offset(inset, size.height - inset), Offset(inset + len, size.height - inset), cornerPaint);
    canvas.drawLine(Offset(inset, size.height - inset), Offset(inset, size.height - inset - len), cornerPaint);
    // 右下
    canvas.drawLine(Offset(size.width - inset, size.height - inset), Offset(size.width - inset - len, size.height - inset), cornerPaint);
    canvas.drawLine(Offset(size.width - inset, size.height - inset), Offset(size.width - inset, size.height - inset - len), cornerPaint);

    // 左上角 4px 战术朱红指示条（参照 .eva-clockpanel::before）
    final accentBlockPaint = Paint()
      ..color = MagiSkin.redPrimary
      ..style = PaintingStyle.fill;
    canvas.drawRect(const Rect.fromLTWH(inset - 1, inset - 1, 4, 32), accentBlockPaint);

    // 右下角 10px 边框标尺（参照 .eva-clockpanel::after）
    final brPaint = Paint()
      ..color = MagiSkin.redPrimary
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(size.width - inset - 10, size.height - inset), Offset(size.width - inset, size.height - inset), brPaint);
    canvas.drawLine(Offset(size.width - inset, size.height - inset - 10), Offset(size.width - inset, size.height - inset), brPaint);
  }

  @override
  bool shouldRepaint(covariant _MagiFramePainter oldDelegate) => false;
}

/// 黑金相间的 130° 战术警戒斜纹条（EVA / NERV 标志性危险警示带，参照 .eva-hazard 与 .eva-mp-hazard）。
class MagiHazardBar extends StatelessWidget {
  const MagiHazardBar({super.key, this.height = 4.0, this.width});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: CustomPaint(
        painter: _HazardPainter(),
      ),
    );
  }
}

class _HazardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = MagiSkin.bgLayer1;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final stripePaint = Paint()
      ..color = MagiSkin.hazardGold
      ..style = PaintingStyle.fill;

    const stripeWidth = 5.0;
    const gap = 5.0;
    const total = stripeWidth + gap;

    final path = Path();
    for (double x = -size.height; x < size.width + size.height; x += total) {
      path.moveTo(x, size.height);
      path.lineTo(x + stripeWidth, size.height);
      path.lineTo(x + stripeWidth + size.height * 0.8, 0);
      path.lineTo(x + size.height * 0.8, 0);
      path.close();
    }
    canvas.drawPath(path, stripePaint);
  }

  @override
  bool shouldRepaint(covariant _HazardPainter oldDelegate) => false;
}

/// 目标锁定四角瞄准框（包裹封面大图，参照 .eva-mp-deck 与 .eva-mp-rings）。
///
/// 状态标签叠在封面角上，不再占用封面外的纵向空间，把面积还给封面。
class MagiTargetFrame extends StatelessWidget {
  const MagiTargetFrame({
    super.key,
    required this.child,
    required this.sourceCode,
  });

  final Widget child;
  final String sourceCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MagiSkin.bgLayer1,
        border: Border.all(color: MagiSkin.redHairline, width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 窄封面（手机小屏）上角标会盖住画面，直接省略。
          final showTags = constraints.maxWidth >= 180;
          return Stack(
            children: [
              child,
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _TargetCornerPainter(color: MagiSkin.redPrimary),
                  ),
                ),
              ),
              if (showTags)
                const Positioned(
                  left: 0,
                  top: 0,
                  child: _TargetTag(label: 'TARGET // AUDIO', accent: true),
                ),
              if (showTags)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: _TargetTag(label: 'CODE // $sourceCode'),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// 叠在封面上的小角标：半透明碳黑底保证任何封面都读得清。
class _TargetTag extends StatelessWidget {
  const _TargetTag({required this.label, this.accent = false});

  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MagiSkin.bgBase.withValues(alpha: 0.78),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: accent ? MagiSkin.redPrimary : MagiSkin.textTertiary,
          fontFamilyFallback: const ['Consolas', 'Courier New', 'monospace'],
        ),
      ),
    );
  }
}

class _TargetCornerPainter extends CustomPainter {
  const _TargetCornerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cornerPaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const len = 16.0;

    // 左上 ⌜
    canvas.drawLine(const Offset(0, 0), const Offset(len, 0), cornerPaint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, len), cornerPaint);

    // 右上 ⌝
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - len, 0), cornerPaint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), cornerPaint);

    // 左下 ⌞
    canvas.drawLine(Offset(0, size.height), Offset(len, size.height), cornerPaint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - len), cornerPaint);

    // 右下 ⌟
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - len, size.height), cornerPaint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - len), cornerPaint);

    // 中央微弱雷达同心圆与十字准星
    final center = Offset(size.width / 2, size.height / 2);
    final radarPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final maxR = math.min(size.width, size.height) * 0.38;
    canvas.drawCircle(center, maxR, radarPaint);
    canvas.drawCircle(center, maxR * 0.6, radarPaint);

    // 十字刻度标线
    canvas.drawLine(Offset(center.dx - maxR - 6, center.dy), Offset(center.dx + maxR + 6, center.dy), radarPaint);
    canvas.drawLine(Offset(center.dx, center.dy - maxR - 6), Offset(center.dx, center.dy + maxR + 6), radarPaint);
  }

  @override
  bool shouldRepaint(covariant _TargetCornerPainter oldDelegate) => false;
}

/// 音频频谱/阶梯跳跃条（参照 .eva-mp-eq：带有 3px 阶梯式发光色块）。
class MagiEqualizerBar extends StatelessWidget {
  const MagiEqualizerBar({super.key, required this.isPlaying});

  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: MagiSkin.bgLayer2,
        border: Border.all(color: MagiSkin.redBorderLight),
      ),
      child: Row(
        children: [
          const Text(
            'SPECTRUM',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: MagiSkin.redPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isPlaying ? 'PLAY' : 'HOLD',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isPlaying ? MagiSkin.pilotGreen : MagiSkin.redPrimary,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 72,
            height: 14,
            child: CustomPaint(
              painter: _EqualizerPainter(isPlaying: isPlaying),
            ),
          ),
        ],
      ),
    );
  }
}

class _EqualizerPainter extends CustomPainter {
  const _EqualizerPainter({required this.isPlaying});

  final bool isPlaying;

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 10;
    const barWidth = 4.5;
    const gap = 2.5;

    final activePaint = Paint()..color = MagiSkin.redPrimary;
    final goldPaint = Paint()..color = MagiSkin.hazardGold;
    final dimPaint = Paint()..color = MagiSkin.bgLayer3;

    // 预设阶梯跳跃高度模式
    final heights = isPlaying
        ? const [0.8, 0.4, 0.9, 0.6, 1.0, 0.5, 0.7, 0.3, 0.85, 0.45, 0.75, 0.6]
        : const [0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2];

    for (int i = 0; i < barCount; i++) {
      final x = i * (barWidth + gap);
      final hFactor = heights[i % heights.length];
      final activeHeight = size.height * hFactor;

      // 底槽
      canvas.drawRect(Rect.fromLTWH(x, 0, barWidth, size.height), dimPaint);

      // 阶梯色块：每 3px 一格，间隔 1px
      double y = size.height - 2;
      while (y > size.height - activeHeight) {
        final blockPaint = (y < size.height * 0.35) ? goldPaint : activePaint;
        canvas.drawRect(Rect.fromLTWH(x, y - 2, barWidth, 2), blockPaint);
        y -= 3.5;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _EqualizerPainter oldDelegate) =>
      oldDelegate.isPlaying != isPlaying;
}

/// MAGI 三贤者战术判定共识条：MELCHIOR-1 / BALTHASAR-2 / CASPAR-3。
///
/// 单行状态带，不再为每台单元加卡框。
class MagiConsensusBar extends StatelessWidget {
  const MagiConsensusBar({super.key});

  static const _units = ['MELCHIOR-1', 'BALTHASAR-2', 'CASPAR-3'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _units.length; i++)
          Expanded(
            child: Row(
              children: [
                Container(width: 5, height: 5, color: MagiSkin.pilotGreen),
                const SizedBox(width: 6),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _units[i],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: MagiSkin.textTertiary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(width: 8),
        const Text(
          'AGREE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: MagiSkin.pilotGreen,
          ),
        ),
      ],
    );
  }
}

/// 战术硬核边框按钮（收起、详情、队列等，纯硬边 0 圆角）。
class MagiTagButton extends StatelessWidget {
  const MagiTagButton({
    super.key,
    this.label,
    this.icon,
    required this.onPressed,
    this.tooltip,
    this.emphasized = false,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 4,
    ),
  });

  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool emphasized;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final fg = emphasized
        ? MagiSkin.textOnAccent
        : (enabled ? MagiSkin.redPrimary : MagiSkin.redPrimary.withValues(alpha: 0.35));
    final bg = emphasized ? MagiSkin.redPrimary : Colors.transparent;

    Widget child = Material(
      color: bg,
      shape: Border.fromBorderSide(
        BorderSide(
          color: enabled ? MagiSkin.redHairline : MagiSkin.redBorderLight,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        hoverColor: emphasized ? MagiSkin.redHover : const Color(0x22FF354D),
        child: Padding(
          padding: contentPadding,
          child: icon != null
              ? Icon(icon, size: 16, color: fg)
              : Text(
                  '[ ${label ?? ''} ]',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: fg,
                    fontFamilyFallback: const ['Consolas', 'Courier New', 'monospace'],
                  ),
                ),
        ),
      ),
    );

    if (tooltip != null) {
      child = Tooltip(message: tooltip!, child: child);
    }
    return child;
  }
}

/// 分段式战术刻度能量/播放进度条（类似 EVA 内部电源倒计时与 .eva-mp-bar）。
///
/// 只保留一个大号倒计时读数：T- 剩余时间 + TOTAL 总长，其余信息交给刻度槽。
class MagiProgressGauge extends StatelessWidget {
  const MagiProgressGauge({
    super.key,
    required this.positionMs,
    required this.durationMs,
    required this.onSeek,
  });

  final int positionMs;
  final int durationMs;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    final clamped = positionMs.clamp(0, durationMs);
    final remainingMs = math.max(0, durationMs - clamped);
    final progress = durationMs > 0 ? clamped / durationMs : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: Text(
                'T-',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: MagiSkin.textTertiary,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _formatMs(remainingMs),
              style: const TextStyle(
                fontSize: MagiSkin.readoutSize,
                fontWeight: FontWeight.w900,
                fontFeatures: [FontFeature.tabularFigures()],
                letterSpacing: 0.6,
                height: 1.0,
                color: MagiSkin.redPrimary,
              ),
            ),
            const Spacer(),
            Text(
              'TOTAL ${_formatMs(durationMs)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFeatures: [FontFeature.tabularFigures()],
                letterSpacing: 0.5,
                color: MagiSkin.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 分段式进度刻度槽；细白游标提示这里可以拖动。
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (details) {
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;
              final dx = details.localPosition.dx.clamp(0.0, box.size.width);
              onSeek((dx / box.size.width) * durationMs);
            },
            onTapDown: (details) {
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;
              final dx = details.localPosition.dx.clamp(0.0, box.size.width);
              onSeek((dx / box.size.width) * durationMs);
            },
            child: SizedBox(
              height: 20,
              child: CustomPaint(
                painter: _MagiGaugePainter(progress: progress),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _formatMs(int ms) {
    if (ms <= 0) return '00:00';
    final s = ms ~/ 1000;
    final m = s ~/ 60;
    final r = s % 60;
    return '${m.toString().padLeft(2, '0')}:${r.toString().padLeft(2, '0')}';
  }
}

class _MagiGaugePainter extends CustomPainter {
  const _MagiGaugePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const totalSegments = 32;
    const gap = 2.0;
    const barTop = 5.0;
    final barHeight = math.max(0.0, size.height - 10);
    final segmentWidth = (size.width - (totalSegments - 1) * gap) / totalSegments;
    final activeSegments = (progress * totalSegments).round();

    final activePaint = Paint()..color = MagiSkin.redPrimary;
    final inactivePaint = Paint()..color = MagiSkin.bgLayer3;

    for (int i = 0; i < totalSegments; i++) {
      final x = i * (segmentWidth + gap);
      final rect = Rect.fromLTWH(x, barTop, segmentWidth, barHeight);
      canvas.drawRect(rect, i < activeSegments ? activePaint : inactivePaint);
    }

    final cursorX = (size.width * progress).clamp(0.5, size.width - 0.5);
    final cursorPaint = Paint()
      ..color = MagiSkin.textPrimary.withValues(alpha: 0.7)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(cursorX, 0),
      Offset(cursorX, size.height),
      cursorPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MagiGaugePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// MAGI 战术控制栏（包含播放/暂停、上一首、下一首、随机循环、红心同步）。
class MagiControlBar extends ConsumerWidget {
  const MagiControlBar({
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
      height: 46,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isFm)
            MagiTagButton(
              tooltip: '不喜欢，换下一首',
              label: 'DISLIKE',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              onPressed: () => ref.read(fmControllerProvider.notifier).dislike(),
            )
          else
            MagiTagButton(
              tooltip: playbackModeLabel(live.mode),
              icon: switch (live.mode) {
                PlayerLoopMode.order => Icons.trending_flat_rounded,
                PlayerLoopMode.listLoop => Icons.repeat_rounded,
                PlayerLoopMode.shuffle => Icons.shuffle_rounded,
                PlayerLoopMode.single => Icons.repeat_one_rounded,
              },
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              onPressed: controller.cycleMode,
            ),
          MagiTagButton(
            tooltip: live.canStepBack ? '上一首' : '第一首',
            icon: Icons.skip_previous_rounded,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            onPressed: live.canStepBack ? controller.previous : null,
          ),
          MagiTagButton(
            tooltip: live.isPlaying ? '暂停' : '播放',
            label: live.isLoading
                ? 'STANDBY'
                : (live.isPlaying ? 'HOLD' : 'EXEC'),
            emphasized: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 9,
            ),
            onPressed: controller.togglePlay,
          ),
          MagiTagButton(
            tooltip: '下一首',
            icon: Icons.skip_next_rounded,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            onPressed: controller.next,
          ),
          MagiTagButton(
            tooltip: liked ? '取消红心' : '我喜欢',
            icon: liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            onPressed: () => ref.read(likesProvider.notifier).toggle(track),
          ),
        ],
      ),
    );
  }
}
