import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/playback_source.dart';
import '../../core/models/track.dart';
import '../../core/theme/magi_skin.dart';
import '../../core/theme/overtone_tokens.dart';
import '../../features/fm/fm_controller.dart';
import '../../features/likes/likes_controller.dart';
import '../../features/player/player_controller.dart';

/// MAGI 皮肤的氛围底板：深紫黑渐变 + 紫红双光晕 + 右上 NERV 标志与幽灵大字。
///
/// 只画氛围，不参与命中测试；内容直接叠在上层，滚动时水印保持静止。
class MagiBackdrop extends StatelessWidget {
  const MagiBackdrop({super.key, required this.child, this.emblem = true});

  final Widget child;
  final bool emblem;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 窄屏不放标志：96px 的水印会压到抬起的内容上。
        final showEmblem = emblem && constraints.maxWidth > 640;
        return Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: MagiSkin.bgBase),
            IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(painter: const _MagiAuraPainter()),
              ),
            ),
            if (showEmblem)
              const Positioned(
                top: 44,
                right: 48,
                width: 96,
                height: 96,
                child: _MagiEmblem(),
              ),
            child,
          ],
        );
      },
    );
  }
}

/// 右上角的 NERV 标志水印（品牌图，替代原先手绘的圆形印章）。
class _MagiEmblem extends StatelessWidget {
  const _MagiEmblem();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.65,
      child: Transform.rotate(
        angle: -0.16,
        child: Image.asset(
          'assets/magi_emblem.png',
          fit: BoxFit.contain,
          excludeFromSemantics: true,
        ),
      ),
    );
  }
}

class _MagiAuraPainter extends CustomPainter {
  const _MagiAuraPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. 深紫黑对角渐变
    canvas.drawRect(
      rect,
      Paint()..shader = MagiSkin.shellGradient.createShader(rect),
    );

    // 2. 左上紫晕 + 右下红晕
    _glow(
      canvas,
      rect,
      center: Offset(size.width * 0.16, -size.height * 0.08),
      radius: size.width * 0.8,
      color: const Color(0x336D28D9),
    );
    _glow(
      canvas,
      rect,
      center: Offset(size.width * 0.98, size.height * 1.04),
      radius: size.width * 0.62,
      color: const Color(0x38FF2743),
    );

    // 3. 两道斜向高光，像海报上的灯带
    _diagonalStreak(canvas, size, offsetY: size.height * 0.2, alpha: 0x0D);
    _diagonalStreak(canvas, size, offsetY: size.height * 0.62, alpha: 0x14);

    // 4. 巨号 NERV 幽灵字
    final ghost = _layout(
      'NERV',
      fontSize: size.width * 0.17,
      color: const Color(0x0AFF2743),
      weight: FontWeight.w900,
      letterSpacing: size.width * 0.004,
    );
    ghost.paint(
      canvas,
      Offset(size.width - ghost.width - 18, size.height * 0.03),
    );

    // 5. 顶部日文引句（参考图里那行很淡的台词）
    final quote = _layout(
      '神は天にいまし、すべて世は事もなし',
      fontSize: 12,
      color: const Color(0x14F6EEF9),
      weight: FontWeight.w500,
      letterSpacing: 6,
    );
    quote.paint(
      canvas,
      Offset((size.width - quote.width) / 2, size.height * 0.11),
    );

    // 6. 右下 ALERT 角标
    final alert = _layout(
      'ALERT! // CONDITION: RED',
      fontSize: 10,
      color: const Color(0x73FF2743),
      weight: FontWeight.w800,
      letterSpacing: 1.6,
      italic: true,
    );
    alert.paint(
      canvas,
      Offset(size.width - alert.width - 24, size.height - alert.height - 18),
    );

    // 7. 暗角
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          radius: 1.05,
          colors: [Color(0x00000000), Color(0x80000000)],
          stops: [0.5, 1.0],
        ).createShader(rect),
    );
  }

  void _glow(
    Canvas canvas,
    Rect rect, {
    required Offset center,
    required double radius,
    required Color color,
  }) {
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(
            (center.dx / rect.width) * 2 - 1,
            (center.dy / rect.height) * 2 - 1,
          ),
          radius: radius / rect.width,
          colors: [color, const Color(0x00000000)],
        ).createShader(rect),
    );
  }

  void _diagonalStreak(
    Canvas canvas,
    Size size, {
    required double offsetY,
    required int alpha,
  }) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0x00000000),
          Color.fromARGB(alpha, 255, 255, 255),
          const Color(0x00000000),
        ],
      ).createShader(Rect.fromLTWH(0, offsetY, size.width, 1.4));
    canvas.save();
    canvas.translate(size.width / 2, offsetY);
    canvas.rotate(-0.09);
    canvas.drawRect(
      Rect.fromLTWH(-size.width * 0.72, 0, size.width * 1.44, 1.4),
      paint,
    );
    canvas.restore();
  }

  TextPainter _layout(
    String text, {
    required double fontSize,
    required Color color,
    required FontWeight weight,
    required double letterSpacing,
    bool italic = false,
  }) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: weight,
          letterSpacing: letterSpacing,
          height: 1.1,
          color: color,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          fontFamilyFallback: const ['Consolas', 'Courier New', 'monospace'],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  @override
  bool shouldRepaint(covariant _MagiAuraPainter oldDelegate) => false;
}

/// 战术终端四角定位标尺与左上/右下状态块（参照 .eva-frame 与 .eva-corner）。
class MagiFrameCorners extends StatelessWidget {
  const MagiFrameCorners({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _MagiFramePainter(), size: Size.infinite);
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
    canvas.drawLine(
      const Offset(inset, inset),
      const Offset(inset + len, inset),
      cornerPaint,
    );
    canvas.drawLine(
      const Offset(inset, inset),
      const Offset(inset, inset + len),
      cornerPaint,
    );
    // 右上
    canvas.drawLine(
      Offset(size.width - inset, inset),
      Offset(size.width - inset - len, inset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - inset, inset),
      Offset(size.width - inset, inset + len),
      cornerPaint,
    );
    // 左下
    canvas.drawLine(
      Offset(inset, size.height - inset),
      Offset(inset + len, size.height - inset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(inset, size.height - inset),
      Offset(inset, size.height - inset - len),
      cornerPaint,
    );
    // 右下
    canvas.drawLine(
      Offset(size.width - inset, size.height - inset),
      Offset(size.width - inset - len, size.height - inset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - inset, size.height - inset),
      Offset(size.width - inset, size.height - inset - len),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MagiFramePainter oldDelegate) => false;
}

/// 霓虹红分隔带：海报里那种带辉光的细红线，替代旧的警戒斜纹。
class MagiHazardBar extends StatelessWidget {
  const MagiHazardBar({super.key, this.height = 4.0, this.width});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: CustomPaint(painter: _HazardPainter()),
    );
  }
}

class _HazardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Rect.fromLTWH(0, size.height / 2 - 0.7, size.width, 1.4);
    final shader = const LinearGradient(
      colors: [Color(0x00FF2743), Color(0x8CFF2743), Color(0x00FF2743)],
      stops: [0.0, 0.5, 1.0],
    ).createShader(line);

    // 先画一层模糊辉光，再压一条实线。
    canvas.drawRect(
      line.inflate(2),
      Paint()
        ..shader = shader
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawRect(line, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _HazardPainter oldDelegate) => false;
}

/// 目标锁定四角瞄准框（包裹封面大图，参照 .eva-mp-deck 与 .eva-mp-rings）。
class MagiTargetFrame extends StatelessWidget {
  const MagiTargetFrame({
    super.key,
    required this.child,
    required this.sourceCode,
    required this.clearance,
  });

  final Widget child;
  final String sourceCode;
  final String clearance;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: MagiSkin.violetGradient,
        borderRadius: BorderRadius.circular(OvertoneRadius.card),
        border: Border.all(color: MagiSkin.redBorderLight, width: 1),
        boxShadow: MagiSkin.glowRedSoft,
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 顶部战术状态标头
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: MagiSkin.redPrimary,
                  shape: BoxShape.circle,
                  boxShadow: MagiSkin.glowRed,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'TARGET: AUDIO // CODE: $sourceCode',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: MagiSkin.redPrimary,
                    fontFamilyFallback: [
                      'Consolas',
                      'Courier New',
                      'monospace',
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'LOCK',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: MagiSkin.violetLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 核心封面：霓虹描边 + 外发光
          Stack(
            children: [
              child,
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(OvertoneRadius.cover),
                      border: Border.all(
                        color: MagiSkin.redBorderStrong,
                        width: 1.2,
                      ),
                      boxShadow: MagiSkin.glowRed,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 底部坐标与密级
          Row(
            children: [
              Text(
                'AUTH: $clearance',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: MagiSkin.redPrimary,
                ),
              ),
              const Spacer(),
              const Flexible(
                child: Text(
                  '35.39°N / 139.44°E',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: MagiSkin.textTertiary,
                    fontFamilyFallback: [
                      'Consolas',
                      'Courier New',
                      'monospace',
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 音频频谱/阶梯跳跃条（参照 .eva-mp-eq：带有 3px 阶梯式发光色块）。
class MagiEqualizerBar extends StatelessWidget {
  const MagiEqualizerBar({super.key, required this.isPlaying});

  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: MagiSkin.violetGradient,
        borderRadius: BorderRadius.circular(OvertoneRadius.card),
        border: Border.all(color: MagiSkin.redBorderLight),
        boxShadow: MagiSkin.glowVioletSoft,
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
              color: isPlaying ? MagiSkin.violetLight : MagiSkin.redPrimary,
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
    final highPaint = Paint()..color = MagiSkin.violetLight;
    final dimPaint = Paint()
      ..color = MagiSkin.violetDeep.withValues(alpha: 0.6);

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

      // 阶梯色块：每 3px 一格，间隔 1px，上段转为霓虹紫
      double y = size.height - 2;
      while (y > size.height - activeHeight) {
        final blockPaint = (y < size.height * 0.35) ? highPaint : activePaint;
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
class MagiConsensusBar extends StatelessWidget {
  const MagiConsensusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _ConsensusUnit(unit: 'MELCHIOR-1', status: 'AGREE'),
        SizedBox(width: 4),
        _ConsensusUnit(unit: 'BALTHASAR-2', status: 'AGREE'),
        SizedBox(width: 4),
        _ConsensusUnit(unit: 'CASPAR-3', status: 'AGREE'),
      ],
    );
  }
}

class _ConsensusUnit extends StatelessWidget {
  const _ConsensusUnit({required this.unit, required this.status});

  final String unit;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(
          gradient: MagiSkin.violetGradient,
          borderRadius: BorderRadius.circular(OvertoneRadius.tag),
          border: Border.all(color: MagiSkin.redBorderLight, width: 1),
        ),
        child: Column(
          children: [
            Text(
              unit,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: MagiSkin.textTertiary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 1),
            Text(
              status,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: MagiSkin.violetLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 霓虹胶囊按钮（收起、详情、队列、播放控制）。
class MagiTagButton extends StatelessWidget {
  const MagiTagButton({
    super.key,
    this.label,
    this.icon,
    required this.onPressed,
    this.tooltip,
    this.emphasized = false,
  });

  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final fg = emphasized
        ? MagiSkin.textOnAccent
        : (enabled
              ? MagiSkin.redPrimary
              : MagiSkin.redPrimary.withValues(alpha: 0.35));

    Widget child = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(OvertoneRadius.chip),
        hoverColor: emphasized ? MagiSkin.redHover : const Color(0x22FF2743),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: icon != null
              ? Icon(icon, size: 16, color: fg)
              : Text(
                  '[ ${label ?? ''} ]',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: fg,
                    fontFamilyFallback: const [
                      'Consolas',
                      'Courier New',
                      'monospace',
                    ],
                  ),
                ),
        ),
      ),
    );

    child = Container(
      decoration: BoxDecoration(
        gradient: emphasized ? MagiSkin.redGradient : null,
        borderRadius: BorderRadius.circular(OvertoneRadius.chip),
        boxShadow: emphasized ? MagiSkin.glowRed : null,
      ),
      // 边框用前景绘制，避免 border 参与布局把手机窄屏挤溢出。
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(OvertoneRadius.chip),
        border: Border.all(
          color: enabled ? MagiSkin.redBorderStrong : MagiSkin.redBorderLight,
        ),
      ),
      child: child,
    );

    if (tooltip != null) {
      child = Tooltip(message: tooltip!, child: child);
    }
    return child;
  }
}

/// 分段式战术刻度能量/播放进度条（类似 EVA 内部电源倒计时与 .eva-mp-bar）。
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
    final progress = durationMs > 0
        ? (positionMs / durationMs).clamp(0.0, 1.0)
        : 0.0;

    final curStr = _formatMs(positionMs);
    final totalStr = _formatMs(durationMs);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 顶部时间标尺：T- 02:15 // /// INTERNAL POWER /// // TOTAL 04:08
        Row(
          children: [
            Text(
              'T- $curStr',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                fontFeatures: [FontFeature.tabularFigures()],
                letterSpacing: 1.2,
                color: MagiSkin.redPrimary,
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                '/// INTERNAL POWER ///',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: MagiSkin.hazardGold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'TOTAL $totalStr',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
                letterSpacing: 1.0,
                color: MagiSkin.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // 分段式进度刻度槽
        GestureDetector(
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
          child: Container(
            height: 16,
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: CustomPaint(painter: _MagiGaugePainter(progress: progress)),
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
    final trackHeight = size.height * 0.3;
    final top = (size.height - trackHeight) / 2;
    final radius = Radius.circular(trackHeight / 2);
    final track = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, top, size.width, trackHeight),
      radius,
    );

    // 底槽
    canvas.drawRRect(
      track,
      Paint()..color = MagiSkin.violetDeep.withValues(alpha: 0.55),
    );

    final activeWidth = size.width * progress.clamp(0.0, 1.0);
    if (activeWidth <= 0) return;

    final active = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, top, activeWidth, trackHeight),
      radius,
    );
    final shader = MagiSkin.redGradient.createShader(
      Rect.fromLTWH(0, top, size.width, trackHeight),
    );

    // 辉光 + 实线
    canvas.drawRRect(
      active,
      Paint()
        ..shader = shader
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawRRect(active, Paint()..shader = shader);

    // 播放头：霓虹圆点
    final knobCenter = Offset(activeWidth, size.height / 2);
    canvas.drawCircle(
      knobCenter,
      5,
      Paint()
        ..color = MagiSkin.redPrimary.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(knobCenter, 3, Paint()..color = MagiSkin.textPrimary);
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
      height: 38,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isFm)
            MagiTagButton(
              tooltip: '不喜欢，换下一首',
              label: 'DISLIKE',
              onPressed: () =>
                  ref.read(fmControllerProvider.notifier).dislike(),
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
              onPressed: controller.cycleMode,
            ),
          MagiTagButton(
            tooltip: live.canStepBack ? '上一首' : '第一首',
            icon: Icons.skip_previous_rounded,
            onPressed: live.canStepBack ? controller.previous : null,
          ),
          MagiTagButton(
            tooltip: live.isPlaying ? '暂停' : '播放',
            label: live.isLoading
                ? 'STANDBY'
                : (live.isPlaying ? 'HOLD' : 'EXEC'),
            emphasized: true,
            onPressed: controller.togglePlay,
          ),
          MagiTagButton(
            tooltip: '下一首',
            icon: Icons.skip_next_rounded,
            onPressed: controller.next,
          ),
          MagiTagButton(
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

/// 呼吸式同步灯：播放页用动画，外壳请传 `animated: false`（常驻动画会让
/// `pumpAndSettle` 永远等不到静止）。
class MagiStatusLed extends StatefulWidget {
  const MagiStatusLed({super.key, this.size = 6, this.animated = true});

  final double size;
  final bool animated;

  @override
  State<MagiStatusLed> createState() => _MagiStatusLedState();
}

class _MagiStatusLedState extends State<MagiStatusLed>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  late final Animation<double> _opacity = Tween<double>(
    begin: 0.35,
    end: 1,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    if (widget.animated) _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: widget.size,
      height: widget.size,
      decoration: const BoxDecoration(
        color: MagiSkin.violetLight,
        shape: BoxShape.circle,
        boxShadow: MagiSkin.glowViolet,
      ),
    );
    if (!widget.animated) return dot;
    return FadeTransition(opacity: _opacity, child: dot);
  }
}
