import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme/archive_skin.dart';
import '../../core/theme/overtone_theme.dart';
import 'archive_chrome.dart';

/// 档案皮肤的磨砂面板：背景模糊 + 半透明纸面 + 发丝边 + 顶部高光。
///
/// 只在 [ArchiveSkinActive] 为真时生效，标准皮肤原样返回 child。
class ArchiveFrostedPanel extends StatelessWidget {
  const ArchiveFrostedPanel({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.blurSigma = 22,
    this.tintOpacity = 0.66,
    this.borderRadius = 2,
  });

  final Widget child;
  final EdgeInsets padding;
  final double blurSigma;
  final double tintOpacity;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    if (!ArchiveSkinActive.of(context)) return child;
    return FrostedPanel(
      padding: padding,
      blurSigma: blurSigma,
      tintOpacity: tintOpacity,
      borderRadius: borderRadius,
      child: child,
    );
  }
}

/// 不依赖皮肤的磨砂面板（调用方自行决定是否启用）。
class FrostedPanel extends StatelessWidget {
  const FrostedPanel({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.blurSigma = 22,
    this.tintOpacity = 0.66,
    this.borderRadius = 2,
  });

  final Widget child;
  final EdgeInsets padding;
  final double blurSigma;
  final double tintOpacity;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final radius = BorderRadius.circular(borderRadius);
    final filter = ui.ImageFilter.blur(
      sigmaX: blurSigma,
      sigmaY: blurSigma,
      tileMode: ui.TileMode.clamp,
    );

    final panel = DecoratedBox(
      decoration: BoxDecoration(
        color: theme.surface.withValues(alpha: tintOpacity),
        borderRadius: radius,
        border: Border.all(color: ArchiveChrome.lineStrong(theme)),
      ),
      child: Stack(
        children: [
          // 顶部 1px 高光 + 向下淡出的亮部，模拟玻璃上沿的反射。
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 56,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(borderRadius),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.22),
                      Colors.white.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );

    final grouped = BackdropGroup.of(context) != null;
    return ClipRRect(
      borderRadius: radius,
      child: grouped
          ? BackdropFilter.grouped(filter: filter, child: panel)
          : BackdropFilter(filter: filter, child: panel),
    );
  }
}

/// 成片层：颗粒 + 暗角 + 轻扫描带（复用 Rhine 验证页的 finish shader）。
///
/// 作为覆盖层绘制，不采样子树，零拷贝。当前用静态时间戳（不做 12Hz 抖动），
/// 避免播放页在测试/低配环境里持续调度帧。
class ArchiveFinishOverlay extends StatefulWidget {
  const ArchiveFinishOverlay({
    super.key,
    this.grain = 0.035,
    this.vignette = 0.1,
    this.scan = 0,
  });

  final double grain;
  final double vignette;
  final double scan;

  @override
  State<ArchiveFinishOverlay> createState() => _ArchiveFinishOverlayState();
}

class _ArchiveFinishOverlayState extends State<ArchiveFinishOverlay> {
  static Future<ui.FragmentProgram?>? _programFuture;

  static Future<ui.FragmentProgram?> _loadProgram() async {
    try {
      return await ui.FragmentProgram.fromAsset('shaders/rhine_finish.frag');
    } catch (_) {
      return null;
    }
  }

  ui.FragmentProgram? _program;

  @override
  void initState() {
    super.initState();
    _programFuture ??= _loadProgram();
    unawaited(
      _programFuture!.then((program) {
        if (mounted) setState(() => _program = program);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _FinishPainter(
          program: _program,
          time: 0,
          grain: widget.grain,
          vignette: widget.vignette,
          scan: widget.scan,
          dpr: MediaQuery.devicePixelRatioOf(context),
        ),
      ),
    );
  }
}

class _FinishPainter extends CustomPainter {
  _FinishPainter({
    required this.program,
    required this.time,
    required this.grain,
    required this.vignette,
    required this.scan,
    required this.dpr,
  });

  final ui.FragmentProgram? program;
  final double time;
  final double grain;
  final double vignette;
  final double scan;
  final double dpr;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final program = this.program;
    if (program != null) {
      final shader = program.fragmentShader()
        // loc0 = vec4：time / grain / vignette / scan
        ..setFloat(0, time)
        ..setFloat(1, grain)
        ..setFloat(2, vignette)
        ..setFloat(3, scan)
        // u_size：FlutterFragCoord 是设备像素。
        ..setFloat(4, size.width * dpr)
        ..setFloat(5, size.height * dpr)
        // u_tint：档案皮肤不叠颜色，只保留中性灰。
        ..setFloat(6, 0.08)
        ..setFloat(7, 0.09)
        ..setFloat(8, 0.09)
        ..setFloat(9, 0.0);
      canvas.drawRect(rect, Paint()..shader = shader);
      return;
    }
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x0014171A), Color(0x1414171A)],
          stops: [0.55, 1.0],
          radius: 0.8,
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_FinishPainter old) =>
      old.time != time ||
      old.program != program ||
      old.grain != grain ||
      old.vignette != vignette ||
      old.scan != scan;
}
