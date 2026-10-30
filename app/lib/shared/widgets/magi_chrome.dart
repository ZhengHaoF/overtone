import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/playback_source.dart';
import '../../core/models/track.dart';
import '../../core/theme/eva_palette.dart';
import '../../core/theme/magi_skin.dart';
import '../../core/theme/overtone_theme.dart';
import '../../features/fm/fm_controller.dart';
import '../../features/likes/likes_controller.dart';
import '../../features/player/player_controller.dart';
import 'archive_skin_scope.dart';
import 'package:overtone/l10n/l10n.dart';

/// EVA 标题卡式展示文字：极太明朝、负字距与可控横向压缩。
///
/// [matisse] 只用于已经确认字符完整覆盖的固定文案；普通中文标题保持默认的
/// Noto Serif SC 900。压缩只影响绘制，不改变文本布局与命中区域，因此放在
/// Row 中时应给外层 Flexible/Expanded，而不是依赖压缩来挤出布局空间。
class MagiDisplayText extends StatelessWidget {
  const MagiDisplayText(
    this.text, {
    super.key,
    this.style,
    this.compression = 0.84,
    this.matisse = false,
    this.outlined = false,
    this.outlineWidth = 1.4,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign = TextAlign.start,
  });

  final String text;
  final TextStyle? style;
  final double compression;
  final bool matisse;
  final bool outlined;
  final double outlineWidth;
  final int? maxLines;
  final TextOverflow overflow;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final ev = context.eva;
    var effective = DefaultTextStyle.of(context).style.merge(style).copyWith(
      fontFamily: matisse ? magiMatisseFamily : overtoneSerifFamily,
      fontFamilyFallback: matisse
          ? magiMatisseFallback
          : overtoneSerifFallback,
      fontWeight:
          style?.fontWeight ??
          (matisse ? FontWeight.w800 : FontWeight.w900),
      height: style?.height ?? 0.95,
      letterSpacing: style?.letterSpacing ?? -0.6,
    );
    if (outlined) {
      final color = effective.color ?? ev.textPrimary;
      effective = effective.copyWith(
        color: null,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = outlineWidth
          ..strokeJoin = StrokeJoin.round
          ..color = color,
      );
    }

    final child = Text(
      text,
      style: effective,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
    if (compression == 1) return child;
    final alignment = switch (textAlign) {
      TextAlign.center => Alignment.center,
      TextAlign.right || TextAlign.end => Alignment.centerRight,
      _ => Alignment.centerLeft,
    };
    return Transform.scale(
      scaleX: compression.clamp(0.5, 1.0),
      scaleY: 1,
      alignment: alignment,
      child: child,
    );
  }
}

/// 逐字 upright 竖排：保留中文字形方向，不再把整行横字旋转 90°。
class MagiVerticalText extends StatelessWidget {
  const MagiVerticalText(
    this.text, {
    super.key,
    this.style,
    this.matisse = false,
    this.gap = 1,
  });

  final String text;
  final TextStyle? style;
  final bool matisse;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final effective = DefaultTextStyle.of(context).style.merge(style).copyWith(
      fontFamily: matisse ? magiMatisseFamily : overtoneSerifFamily,
      fontFamilyFallback: matisse
          ? magiMatisseFallback
          : overtoneSerifFallback,
      fontWeight:
          style?.fontWeight ??
          (matisse ? FontWeight.w800 : FontWeight.w900),
      height: style?.height ?? 1.0,
    );
    final characters = text.runes.map(String.fromCharCode).toList();
    return Semantics(
      label: text,
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < characters.length; i++) ...[
            Text(characters[i], style: effective),
            if (i != characters.length - 1) SizedBox(height: gap),
          ],
        ],
      ),
    );
  }
}

/// EVA 皮肤的氛围底板：黑底/瓷白底 + 低对比网格 + 可选 NERV 水印。
///
/// 蓝版（零号机）额外叠一层角色线稿与「00」环阵，版式与红版保持一致。
/// 只画氛围，不参与命中测试；内容直接叠在上层，滚动时水印保持静止。
class MagiBackdrop extends StatelessWidget {
  const MagiBackdrop({
    super.key,
    required this.child,
    this.emblem = true,
    this.pilot = true,
  });

  final Widget child;
  final bool emblem;
  final bool pilot;

  @override
  Widget build(BuildContext context) {
    final ev = context.eva;
    final art = pilot ? ev.pilotArt : null;
    return LayoutBuilder(
      builder: (context, constraints) {
        // 窄屏不放标志/线稿：96px 的水印与半身像会压到抬起的内容上。
        final wide = constraints.maxWidth > 640;
        return Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: ev.bgBase),
            IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(painter: _MagiAuraPainter(ev)),
              ),
            ),
            if (wide && art != null)
              Positioned(
                right: 0,
                bottom: 0,
                height: constraints.maxHeight * 0.78,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: ev.pilotArtOpacity,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        ev.pilotArtTint,
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        art,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomRight,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                ),
              ),
            if (wide && emblem)
              Positioned(
                top: 44,
                right: 48,
                width: 96,
                height: 96,
                child: _MagiEmblem(tint: ev.emblemTint),
              ),
            child,
          ],
        );
      },
    );
  }
}

/// 右上角的 NERV 标志水印（品牌图，替代原先手绘的圆形印章）。
///
/// 蓝版用 `srcIn` 把实心红整块染成冰蓝：原图是「不透明图形 + 透明底」，
/// 换色不会带出边缘残色。
class _MagiEmblem extends StatelessWidget {
  const _MagiEmblem({this.tint});

  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/magi_emblem.png',
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
    return Opacity(
      opacity: 0.28,
      child: Transform.rotate(
        angle: -0.16,
        child: tint == null
            ? image
            : ColorFiltered(
                colorFilter: ColorFilter.mode(tint!, BlendMode.srcIn),
                child: image,
              ),
      ),
    );
  }
}

class _MagiAuraPainter extends CustomPainter {
  const _MagiAuraPainter(this.palette);

  final EvaPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = palette.bgBase);

    final gridPaint = Paint()
      ..color = palette.grid
      ..strokeWidth = 1;
    const gridStep = 48.0;
    for (var x = 0.0; x <= size.width; x += gridStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 0.0; y <= size.height; y += gridStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (palette.isLight) _paintUnitMotif(canvas, size);
  }

  /// 零号机专属：右侧环阵 + 幽灵机体编号 + 边缘刻度尺。
  void _paintUnitMotif(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.74, size.height * 0.44);
    final base = math.min(size.width, size.height) * 0.22;
    final ring = Paint()
      ..color = palette.accent.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final factor in const [1.0, 1.5, 2.05]) {
      canvas.drawCircle(center, base * factor, ring);
    }
    canvas.drawLine(
      Offset(center.dx - base * 2.05, center.dy),
      Offset(center.dx + base * 2.05, center.dy),
      ring,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - base * 2.05),
      Offset(center.dx, center.dy + base * 2.05),
      ring,
    );

    final ghost = TextPainter(
      text: TextSpan(
        text: palette.unitCode,
        style: TextStyle(
          fontFamily: overtoneSerifFamily,
          fontFamilyFallback: overtoneSerifFallback,
          fontSize: base * 1.9,
          fontWeight: FontWeight.w900,
          height: 0.9,
          letterSpacing: -base * 0.06,
          color: palette.accent.withValues(alpha: 0.06),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    ghost.paint(canvas, center - Offset(ghost.width / 2, ghost.height / 2));

    final tick = Paint()..color = palette.accent.withValues(alpha: 0.22);
    const step = 32.0;
    for (var y = 0.0; y <= size.height; y += step) {
      canvas.drawRect(Rect.fromLTWH(size.width - 10, y, 10, 1), tick);
      canvas.drawRect(Rect.fromLTWH(0, y, 6, 1), tick);
    }
  }

  @override
  bool shouldRepaint(covariant _MagiAuraPainter oldDelegate) =>
      oldDelegate.palette != palette;
}

/// 战术终端四角定位标尺与左上/右下状态块（参照 .eva-frame 与 .eva-corner）。
class MagiFrameCorners extends StatelessWidget {
  const MagiFrameCorners({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MagiFramePainter(context.eva),
      size: Size.infinite,
    );
  }
}

class _MagiFramePainter extends CustomPainter {
  const _MagiFramePainter(this.palette);

  final EvaPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final cornerPaint = Paint()
      ..color = palette.accent.withValues(alpha: 0.5)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    const inset = 10.0;
    const len = 22.0;

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
  }

  @override
  bool shouldRepaint(covariant _MagiFramePainter oldDelegate) =>
      oldDelegate.palette != palette;
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
        painter: _HazardPainter(context.eva),
      ),
    );
  }
}

class _HazardPainter extends CustomPainter {
  const _HazardPainter(this.palette);

  final EvaPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    // 海报式硬边：整条结构线 + 左端一段强调块。
    // 蓝版沿用参考稿的「酒红危险胶带」：白底上用红色小面积做警示，冰蓝留给状态。
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = palette.lineStrong,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, 56, size.height),
      Paint()..color = palette.isLight ? palette.danger : palette.accent,
    );
  }

  @override
  bool shouldRepaint(covariant _HazardPainter oldDelegate) =>
      oldDelegate.palette != palette;
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
    final ev = context.eva;
    return Container(
      decoration: const BoxDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.zero,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 窄封面（手机小屏）上角标会盖住画面，直接省略。
            final showTags = constraints.maxWidth >= 180;
            return Stack(
              children: [
                child,
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ev.lineMid,
                          width: 1.2,
                        ),
                      ),
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
      ),
    );
  }
}

/// 叠在封面上的小角标：红版是半透明碳黑底，蓝版换成深海军蓝表头 + 白字。
class _TargetTag extends StatelessWidget {
  const _TargetTag({required this.label, this.accent = false});

  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final ev = context.eva;
    return Container(
      decoration: BoxDecoration(
        color: ev.tagBg,
        border: Border.all(color: ev.lineMid),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: accent ? ev.tagAccentText : ev.tagText,
          fontFamilyFallback: const ['Consolas', 'Courier New', 'monospace'],
        ),
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
    final ev = context.eva;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: ev.bgBase,
        border: Border.fromBorderSide(BorderSide(color: ev.lineMid)),
      ),
      child: Row(
        children: [
          Text(
            'SPECTRUM',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: ev.accent,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isPlaying ? 'PLAY' : 'HOLD',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isPlaying ? ev.textPrimary : ev.accent,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 72,
            height: 14,
            child: CustomPaint(
              painter: _EqualizerPainter(isPlaying: isPlaying, palette: ev),
            ),
          ),
        ],
      ),
    );
  }
}

class _EqualizerPainter extends CustomPainter {
  const _EqualizerPainter({required this.isPlaying, required this.palette});

  final bool isPlaying;
  final EvaPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 10;
    const barWidth = 4.5;
    const gap = 2.5;

    final activePaint = Paint()..color = palette.accent;
    final highPaint = Paint()..color = palette.textPrimary;
    final dimPaint = Paint()..color = palette.bgLayer3.withValues(alpha: 0.6);

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
        final blockPaint = (y < size.height * 0.35) ? highPaint : activePaint;
        canvas.drawRect(Rect.fromLTWH(x, y - 2, barWidth, 2), blockPaint);
        y -= 3.5;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _EqualizerPainter oldDelegate) =>
      oldDelegate.isPlaying != isPlaying || oldDelegate.palette != palette;
}

/// MAGI 三贤者战术判定共识条：MELCHIOR-1 / BALTHASAR-2 / CASPAR-3。
///
/// 单行状态带，不再为每台单元加卡框。
class MagiConsensusBar extends StatelessWidget {
  const MagiConsensusBar({super.key});

  static const _units = ['MELCHIOR-1', 'BALTHASAR-2', 'CASPAR-3'];

  @override
  Widget build(BuildContext context) {
    final ev = context.eva;
    return Row(
      children: [
        for (var i = 0; i < _units.length; i++)
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: ev.textPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _units[i],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: ev.textTertiary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(width: 8),
        Text(
          'AGREE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: ev.textPrimary,
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
    final ev = context.eva;
    final enabled = onPressed != null;
    // 主操作反色：白底黑字。红色只留给状态/警示，避免和情绪色抢层级。
    final fg = emphasized
        ? ev.bgBase
        : (enabled
              ? ev.textPrimary
              : ev.textPrimary.withValues(alpha: 0.35));

    Widget child = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        hoverColor: emphasized
            ? const Color(0x14000000)
            : ev.accent.withValues(alpha: 0.13),
        child: Padding(
          padding: contentPadding,
          child: icon != null
              ? Icon(icon, size: 16, color: fg)
              : Text(
                  '[ ${label ?? ''} ]',
                  style: TextStyle(
                    fontSize: emphasized
                        ? MagiSkin.buttonSize
                        : MagiSkin.tagSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: fg,
                    fontFamilyFallback: const ['Consolas', 'Courier New', 'monospace'],
                  ),
                ),
        ),
      ),
    );

    child = Container(
      decoration: BoxDecoration(
        // 硬边直角 + 纯色：MAGI 皮肤不参与全站圆角/渐变体系。
        color: emphasized ? ev.textPrimary : null,
      ),
      // 边框用前景绘制，避免 border 参与布局把手机窄屏挤溢出。
      foregroundDecoration: BoxDecoration(
        border: Border.all(
          color: emphasized
              ? ev.textPrimary
              : (enabled ? ev.lineMid : ev.lineSoft),
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

/// 1–99 → 日式汉字数字（壱弐参肆伍陆柒捌玖拾）。
///
/// 只用于 MAGI 的章节/曲目编号；超过两位直接回十进制，避免拗口。
String magiNumeral(int n) {
  final digits = [l10n.ling, l10n.yi, l10n.er, l10n.can, l10n.si, l10n.wu_2, l10n.lu, l10n.qi, l10n.ba, l10n.jiu];
  if (n <= 0) return digits[0];
  if (n < 10) return digits[n];
  if (n < 100) {
    final tens = n ~/ 10;
    final ones = n % 10;
    return l10n.shi(digits[tens], ones == 0 ? '' : digits[ones]);
  }
  return '$n';
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
    final ev = context.eva;
    final clamped = positionMs.clamp(0, durationMs);
    final remainingMs = math.max(0, durationMs - clamped);
    final progress = durationMs > 0 ? clamped / durationMs : 0.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 竖排「内部电源剩余」：高度与读数行 + 标尺齐平，不额外撑高。
        Container(
          padding: const EdgeInsets.only(right: 5),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: ev.accent, width: 2),
            ),
          ),
          child: MagiVerticalText(
            context.l10n.neiBuDianYuanShengYu,
            gap: 0,
            style: TextStyle(
              fontSize: MagiSkin.gaugeLabelSize,
              fontWeight: FontWeight.w800,
              height: 1.0,
              color: ev.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 3),
                    child: Text(
                      'T-',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: ev.textTertiary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // 大号读数在窄列/无字体回退时会自动缩，避免顶破行。
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: MagiDisplayText(
                        _formatMs(remainingMs),
                        matisse: true,
                        compression: 0.9,
                        style: TextStyle(
                          fontSize: MagiSkin.readoutSize,
                          fontWeight: FontWeight.w800,
                          fontFeatures: [FontFeature.tabularFigures()],
                          letterSpacing: 0.6,
                          height: 1.0,
                          color: ev.accent,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      'TOTAL ${_formatMs(durationMs)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [FontFeature.tabularFigures()],
                        letterSpacing: 0.5,
                        color: ev.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 标尺式进度槽；▼ 游标提示这里可以拖动。
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: (details) {
                    final box = context.findRenderObject() as RenderBox?;
                    if (box == null) return;
                    final dx =
                        details.localPosition.dx.clamp(0.0, box.size.width);
                    onSeek((dx / box.size.width) * durationMs);
                  },
                  onTapDown: (details) {
                    final box = context.findRenderObject() as RenderBox?;
                    if (box == null) return;
                    final dx =
                        details.localPosition.dx.clamp(0.0, box.size.width);
                    onSeek((dx / box.size.width) * durationMs);
                  },
                  child: SizedBox(
                    height: 22,
                    child: CustomPaint(
                      painter: _MagiGaugePainter(progress: progress, palette: ev),
                    ),
                  ),
                ),
              ),
            ],
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
  const _MagiGaugePainter({required this.progress, required this.palette});

  final double progress;
  final EvaPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = progress.clamp(0.0, 1.0);

    // 上下两道硬边：顶部红线、底部半透明白线（像仪表刻度尺）。
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, 1.5),
      Paint()..color = palette.accent.withValues(alpha: 0.55),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h - 1, w, 1),
      Paint()..color = palette.textPrimary.withValues(alpha: 0.26),
    );

    // 刻度：每 14px 一根；已播段亮红，未播段压暗。
    const step = 14.0;
    final played = Paint()..color = palette.accent;
    final unplayed = Paint()
      ..color = palette.accent.withValues(alpha: 0.22);
    for (var x = 0.0; x <= w; x += step) {
      canvas.drawRect(
        Rect.fromLTWH(x, 1.5, 1, 7),
        w > 0 && x / w <= p ? played : unplayed,
      );
    }

    // 已播段：底部 2px 红条，给出连续读数。
    if (p > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, h - 3, w * p, 2),
        Paint()..color = palette.accent,
      );
    }

    // ▼ 游标：白三角压在顶线上。
    final cx = (w * p).clamp(0.0, w);
    canvas.drawPath(
      Path()
        ..moveTo(cx - 5, 0)
        ..lineTo(cx + 5, 0)
        ..lineTo(cx, 7)
        ..close(),
      Paint()..color = palette.textPrimary,
    );
  }

  @override
  bool shouldRepaint(covariant _MagiGaugePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.palette != palette;
}

/// 底栏用的标尺式进度条（稿子的 ruler-bar）：红刻度 + 白游标。
///
/// API 对齐 [ArchiveProgressRule]（value/onDrag/onEnd），可原地替换。
class MagiProgressRule extends StatelessWidget {
  const MagiProgressRule({
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
    final ev = context.eva;
    return LayoutBuilder(
      builder: (context, box) => GestureDetector(
        behavior: HitTestBehavior.opaque,
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
          height: 16,
          child: CustomPaint(
            painter: _MagiRulePainter(value: value.clamp(0.0, 1.0), palette: ev),
          ),
        ),
      ),
    );
  }
}

class _MagiRulePainter extends CustomPainter {
  const _MagiRulePainter({required this.value, required this.palette});

  final double value;
  final EvaPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final p = value;

    // 上下两道硬边：顶部红、底部白。
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, 1.5),
      Paint()..color = palette.accent,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 1, w, 1),
      Paint()..color = palette.textPrimary.withValues(alpha: 0.4),
    );
    // 稿子的 repeating 红刻度：每 14px 一根。
    final tick = Paint()..color = palette.accent;
    for (var x = 0.0; x <= w; x += 14) {
      canvas.drawRect(
        Rect.fromLTWH(x, 1.5, 1, 6),
        Paint()
          ..color = (w > 0 && x / w <= p)
              ? tick.color
              : tick.color.withValues(alpha: 0.22),
      );
    }
    // ▼ 游标。
    final cx = (w * p).clamp(0.0, w);
    canvas.drawPath(
      Path()
        ..moveTo(cx - 5, 0)
        ..lineTo(cx + 5, 0)
        ..lineTo(cx, 7)
        ..close(),
      Paint()..color = palette.textPrimary,
    );
  }

  @override
  bool shouldRepaint(covariant _MagiRulePainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.palette != palette;
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
              tooltip: context.l10n.buXiHuanHuanXiaYiShou,
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
            tooltip: live.canStepBack ? context.l10n.shangYiShou : context.l10n.diYiShou,
            icon: Icons.skip_previous_rounded,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            onPressed: live.canStepBack ? controller.previous : null,
          ),
          MagiTagButton(
            tooltip: live.isPlaying ? context.l10n.zanTing : context.l10n.boFang,
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
            tooltip: context.l10n.xiaYiShou,
            icon: Icons.skip_next_rounded,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            onPressed: controller.next,
          ),
          MagiTagButton(
            tooltip: liked ? context.l10n.quXiaoHongXin : context.l10n.woXiHuan,
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
    duration: Duration(milliseconds: 1400),
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
    final ev = context.eva;
    final dot = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: ev.textPrimary,
        shape: BoxShape.circle,
        boxShadow: ev.glow,
      ),
    );
    if (!widget.animated) return dot;
    return FadeTransition(opacity: _opacity, child: dot);
  }
}
