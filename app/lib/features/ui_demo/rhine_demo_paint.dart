import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme/overtone_tokens.dart';

/// Rhine 风格的固定配色：这套语言自己的白底墨色，刻意不走 OvertonePalette。
abstract final class RhineInk {
  static const paper = Color(0xFFF4F5F3);
  static const card = Color(0xFFFFFFFF);
  static const ink = Color(0xFF14171A);
  static const inkSoft = Color(0xFF5A6266);
  static const hair = Color(0x1A14171A);
  static const hairStrong = Color(0x3D14171A);
  static const accent = Color(0xFFE8620F);
  static const teal = Color(0xFF029C94);
}

/// 字号仍收在他的五档阶梯内（10/12/15/18/22），HUD 最小只能用 micro=10。
abstract final class RhineType {
  static const micro = TextStyle(
    fontFamily: 'MiSans',
    fontSize: OvertoneFontSize.micro,
    letterSpacing: 0.8,
    color: RhineInk.inkSoft,
  );
  static const caption = TextStyle(
    fontFamily: 'MiSans',
    fontSize: OvertoneFontSize.caption,
    color: RhineInk.ink,
  );
  static const body = TextStyle(
    fontFamily: 'MiSans',
    fontSize: OvertoneFontSize.body,
    color: RhineInk.ink,
  );
  static const section = TextStyle(
    fontFamily: 'MiSans',
    fontSize: OvertoneFontSize.section,
    color: RhineInk.ink,
  );
  static const title = TextStyle(
    fontFamily: 'MiSans',
    fontSize: OvertoneFontSize.title,
    color: RhineInk.ink,
  );
}

/// 发丝网格 + 边缘刻度尺 + 四角括号，整页背景。
class GridPainter extends CustomPainter {
  GridPainter({required this.size});

  final Size size;

  @override
  void paint(Canvas canvas, Size s) {
    final hair = Paint()
      ..color = RhineInk.hair
      ..strokeWidth = 1;
    final ruler = Paint()
      ..color = RhineInk.hairStrong
      ..strokeWidth = 1;

    const step = 56.0;
    for (double x = step; x < s.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, s.height), hair);
    }
    for (double y = step; y < s.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(s.width, y), hair);
    }

    for (double x = 0; x < s.width; x += 14) {
      final tall = (x / 14).round() % 5 == 0;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, tall ? 11 : 5),
        tall ? ruler : hair,
      );
    }
    for (double y = 0; y < s.height; y += 14) {
      final tall = (y / 14).round() % 5 == 0;
      canvas.drawLine(
        Offset(0, y),
        Offset(tall ? 11 : 5, y),
        tall ? ruler : hair,
      );
    }

    final bracket = Paint()
      ..color = RhineInk.hairStrong
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const pad = 18.0;
    for (final corner in _corners(s, pad)) {
      canvas.drawPath(corner, bracket);
    }
    canvas.drawCircle(
      const Offset(pad + 16, pad),
      1.6,
      Paint()..color = RhineInk.accent,
    );
  }

  static List<Path> _corners(Size s, double pad) {
    final right = s.width - pad, bottom = s.height - pad;
    const len = 16.0;
    return [
      Path()
        ..moveTo(pad, pad + len)
        ..lineTo(pad, pad)
        ..lineTo(pad + len, pad),
      Path()
        ..moveTo(right - len, pad)
        ..lineTo(right, pad)
        ..lineTo(right, pad + len),
      Path()
        ..moveTo(right, bottom - len)
        ..lineTo(right, bottom)
        ..lineTo(right - len, bottom),
      Path()
        ..moveTo(pad + len, bottom)
        ..lineTo(pad, bottom)
        ..lineTo(pad, bottom - len),
    ];
  }

  @override
  bool shouldRepaint(GridPainter old) => old.size != size;
}

/// 成片层：颗粒 + 暗角 + 扫描带 + 边缘色散，走 `rhine_finish.frag`。
///
/// 拿不到 runtime shader 的平台退回 Skia 径向渐变暗角（颗粒与扫描带放弃），
/// demo 在任何机器上都能出图。
class FinishPainter extends CustomPainter {
  FinishPainter({
    required this.program,
    required this.time,
    required this.size,
    required this.dpr,
  });

  final ui.FragmentProgram? program;
  final double time;
  final Size size;
  final double dpr;

  @override
  void paint(Canvas canvas, Size s) {
    final rect = Offset.zero & s;
    final prog = program;
    if (prog != null) {
      final shader = prog.fragmentShader()
        // loc0 = vec4 u_params：time / grain / vignette / scan
        ..setFloat(0, time)
        ..setFloat(1, 0.045)
        ..setFloat(2, 0.17)
        ..setFloat(3, 0.05)
        // vec2 u_size。FlutterFragCoord 给的是设备像素，单位要跟上一致。
        ..setFloat(4, s.width * dpr)
        ..setFloat(5, s.height * dpr)
        // vec4 u_tint：品牌青绿 + 强度。
        // 索引按**声明顺序紧凑排布**（vec4=4 个 float），`layout(location=)` 只是
        // 名字、不做 16 字节对齐，所以这里从 6 起而不是 8。
        ..setFloat(6, 0x02 / 255)
        ..setFloat(7, 0x9C / 255)
        ..setFloat(8, 0x94 / 255)
        ..setFloat(9, 0.055);
      canvas.drawRect(rect, Paint()..shader = shader);
      return;
    }
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x0014171A), Color(0x2614171A)],
          stops: [0.42, 1.0],
          radius: 0.78,
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(FinishPainter old) =>
      old.time != time || old.size != size;
}

/// 解密期间在卡面上走过的对角扫描线，两条随 progress 合拢。
class DecryptLinePainter extends CustomPainter {
  DecryptLinePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size s) {
    if (progress <= 0 || progress >= 1) return;
    final p = Paint()
      ..color = RhineInk.accent
      ..strokeWidth = 1.2;
    final w = s.width, h = s.height;
    final t = Curves.easeInOut.transform(progress);
    final inset = 1.0 - t;
    canvas.drawLine(
      Offset(-w * inset, -h * inset),
      Offset(w * (0.5 + t * 0.5), h * (0.5 + t * 0.5)),
      p,
    );
    canvas.drawLine(
      Offset(w * (1 + inset), -h * inset),
      Offset(w * (0.5 - t * 0.5), h * (0.5 + t * 0.5)),
      p,
    );
  }

  @override
  bool shouldRepaint(DecryptLinePainter old) => old.progress != progress;
}

/// 标志笔画：外环绕行 + 内部连续笔画按 progress 描出。
class LogoPainter extends CustomPainter {
  LogoPainter({required this.progress, this.color = RhineInk.ink});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final w = s.width, h = s.height;
    final cx = w / 2, cy = h / 2;
    final r = math.min(w, h) / 2 - 2;

    final sweep = math.pi * 1.62 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2,
      sweep,
      false,
      p,
    );

    final second = ((progress - 0.25) / 0.6).clamp(0.0, 1.0);
    if (second > 0) {
      final path = Path()
        ..moveTo(cx - r * 0.34, cy + r * 0.42)
        ..lineTo(cx - r * 0.34, cy - r * 0.44)
        ..lineTo(cx + r * 0.40, cy + r * 0.10)
        ..lineTo(cx + r * 0.40, cy - r * 0.44);
      for (final metric in path.computeMetrics()) {
        canvas.drawPath(metric.extractPath(0, metric.length * second), p);
      }
    }

    if (progress > 0.02) {
      final ang = -math.pi / 2 + sweep;
      canvas.drawCircle(
        Offset(cx + r * math.cos(ang), cy + r * math.sin(ang)),
        2.2,
        Paint()..color = RhineInk.accent,
      );
    }
  }

  @override
  bool shouldRepaint(LogoPainter old) =>
      old.progress != progress || old.color != color;
}

/// 逐字符纵向滚动的文字（Rolling Number 的那手感）。
///
/// 旧字符上移离场、新字符从下方滚入，`ClipRect` 裁掉溢出；越靠右起步越晚，
/// 形成连续滚动而不是整块跳字。
class RollingText extends StatelessWidget {
  const RollingText({
    super.key,
    required this.text,
    required this.style,
    this.stagger = 0.05,
    this.color,
  });

  final String text;
  final TextStyle style;

  /// 相邻字符的起步间隔，占单个补间时长的比例。
  final double stagger;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chars = text.split('');
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < chars.length; i++)
          _RollingChar(
            key: ValueKey('slot$i'),
            char: chars[i],
            index: i,
            style: style,
            stagger: stagger,
            color: color,
          ),
      ],
    );
  }
}

class _RollingChar extends StatefulWidget {
  const _RollingChar({
    super.key,
    required this.char,
    required this.index,
    required this.style,
    required this.stagger,
    required this.color,
  });

  final String char;
  final int index;
  final TextStyle style;
  final double stagger;
  final Color? color;

  @override
  State<_RollingChar> createState() => _RollingCharState();
}

class _RollingCharState extends State<_RollingChar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
    value: 1,
  );
  String _prev = '';
  double _delay = 0;

  @override
  void didUpdateWidget(_RollingChar old) {
    super.didUpdateWidget(old);
    if (old.char == widget.char) return;
    _prev = old.char;
    _delay = math.min(0.6, widget.index * widget.stagger);
    _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Size _measure(String ch) {
    final tp = TextPainter(
      text: TextSpan(text: ch.isEmpty ? ' ' : ch, style: widget.style),
      textDirection: TextDirection.ltr,
    )..layout();
    return Size(tp.width, tp.height);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final raw = Curves.easeOutCubic.transform(
          ((_c.value - _delay) / math.max(0.001, 1 - _delay)).clamp(0.0, 1.0),
        );
        final p = _prev.isEmpty ? 1.0 : raw;
        final box = _measure(widget.char);
        return ClipRect(
          child: SizedBox(
            width: box.width,
            height: box.height,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                if (_prev.isNotEmpty)
                  Positioned(
                    left: 0,
                    top: -box.height * p,
                    child: _glyph(_prev),
                  ),
                Positioned(
                  left: 0,
                  top: box.height * (1 - p),
                  child: _glyph(widget.char),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _glyph(String ch) => Text(
    ch.isEmpty ? ' ' : ch,
    style: widget.style.copyWith(color: widget.color),
  );
}

/// 盖板解密揭示：磨砂层自上而下被擦掉，走 `rhine_reveal.frag`。
///
/// shader 不可用时退回线性渐变遮罩（边缘不羽化、无噪声抖动）。
class RevealMask extends StatelessWidget {
  const RevealMask({
    super.key,
    required this.program,
    required this.progress,
    required this.dpr,
    required this.child,
    this.feather = 26,
    this.flipY = 0,
  });

  final ui.FragmentProgram? program;
  final double progress;
  final double dpr;
  final double feather;

  /// `FlutterFragCoord` 的 y 方向在两个后端上不保证一致，这里留一个翻转位，
  /// 按实测传 0 或 1。
  final double flipY;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final prog = program;
    if (prog == null) {
      return ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) {
          final edge = progress.clamp(0.0, 1.0);
          // 前沿之上已揭开（透明），之下仍是磨砂（不透明）
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [Color(0x00000000), Color(0xFF000000)],
            stops: [math.max(0.0, edge - 0.05), edge],
          ).createShader(rect);
        },
        child: child,
      );
    }
    return LayoutBuilder(
      builder: (context, box) => ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) {
          final shader = prog.fragmentShader()
            // loc0 = vec4 u_reveal：progress / feather(px) / noise / flipY
            ..setFloat(0, progress)
            ..setFloat(1, feather * dpr)
            ..setFloat(2, 0.7)
            ..setFloat(3, flipY)
            // loc1 = vec2 u_size（设备像素）
            ..setFloat(4, box.maxWidth * dpr)
            ..setFloat(5, box.maxHeight * dpr);
          return shader;
        },
        child: child,
      ),
    );
  }
}
