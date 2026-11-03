import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme/overtone_theme.dart';
import '../../core/theme/overtone_tokens.dart';

/// 默认皮肤的毛玻璃面板。
///
/// 只对自身区域做局部模糊（不是整屏），模糊后再叠饱和度提升，然后盖一层
/// 半透明底 + 顶部受光渐变 + 「内亮外暗」描边：
///
/// 1. `ClipRRect` 把模糊限制在这块面板内；
/// 2. `BackdropFilter` 组合「高斯模糊 → 饱和度矩阵」，这是玻璃观感的核心，
///    只模糊不提饱和会显得灰、糊；
/// 3. 底色默认走 [OvertoneTheme.dockScrim]，渐变走
///    [OvertoneTheme.glassSheenWith]，顶边亮、侧边发丝线、底边暗，
///    模拟玻璃厚度与受光；
/// 4. 传入 [tint] 时按 [OvertoneTheme.glassTintStrength] 混进底色，
///    并用 300ms 隐式动画过渡（切歌只触发一次重建，不逐帧重算）。
///
/// **仅默认皮肤使用**：MAGI / archive 是不透明硬边语汇，各自走贴底分支，
/// 不要引用本组件，否则会把硬边底栏变成半透明浮层。
class FrostedGlass extends StatelessWidget {
  const FrostedGlass({
    super.key,
    required this.child,
    this.height,
    this.radius = OvertoneRadius.bar,
    this.padding = const EdgeInsets.symmetric(horizontal: OvertoneSpacing.sm),
    this.shadow,
    this.blurSigma,
    this.scrim,
    this.tint,
  });

  final Widget child;

  /// 固定高度；为 null 时由 [child] 撑开。
  final double? height;
  final double radius;
  final EdgeInsetsGeometry padding;

  /// 面板投影。玻璃的立体感主要靠边缘高光，投影保持轻。
  final List<BoxShadow>? shadow;

  /// 覆盖主题里的默认模糊半径。
  ///
  /// 不传时取 [OvertoneTheme.glassDockSigma]（Dock 的厚玻璃）；
  /// 迷你条显式传 [OvertoneTheme.glassThinSigma] 做「薄一档」。
  final double? blurSigma;

  /// 玻璃底色。默认取 [OvertoneTheme.dockScrim]；
  /// 迷你条传 [OvertoneTheme.miniBarScrim]（更实，90%+）。
  final Color? scrim;

  /// B1 自适应染色：当前播放封面的主色。
  ///
  /// 只按 [OvertoneTheme.glassTintStrength]（浅色 3% / 深色 6%）混进
  /// [scrim]，再交给 300ms 的隐式动画过渡。传 null（没有播放）时
  /// 直接退回纯主题底色，不残留上一首的染色。
  final Color? tint;

  /// 染色过渡时长：隐式动画自己跑，调用方不需要逐帧重建。
  static const Duration tintDuration = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final borderRadius = BorderRadius.circular(radius);
    final baseScrim = scrim ?? theme.dockScrim;
    final sigma = blurSigma ?? theme.glassDockSigma;
    final tintedScrim = tint == null
        ? baseScrim
        : Color.lerp(baseScrim, tint, theme.glassTintStrength)!;

    // 总开关关掉时退化成同色不透明面板：没有模糊/饱和度，但圆角、描边、
    // 投影全部保留，调用点无需改动。
    final panelScrim = OvertoneTheme.glassEffectsEnabled
        ? tintedScrim
        : tintedScrim.withValues(alpha: 1.0);

    // 描边不能塞进 BoxDecoration：`borderRadius` + 四边不同颜色的 `Border`
    // 会在 paint 阶段抛断言（`A borderRadius can only be given on borders
    // with uniform colors.`），装饰一旦中断 child 就不再绘制，整块面板变白。
    // 所以这里只留「圆角 + 渐变」交给 [AnimatedContainer] 插值，描边改由
    // 前景 [CustomPaint] 沿 RRect 分段描：整圈发丝线打底（四角圆弧由它承担），
    // 再把顶边受光、底边收暗压在同一条线上。描边颜色只跟主题走、不随 tint
    // 变化，因此不需要跟着 300ms 一起插值；主题切换时整块会重新构建。
    final panel = AnimatedContainer(
      duration: tintDuration,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: theme.glassSheenWith(panelScrim),
      ),
      child: CustomPaint(
        foregroundPainter: _GlassRimPainter(
          radius: radius,
          top: theme.glassRimTop,
          side: theme.glassRimSide,
          bottom: theme.glassRimBottom,
        ),
        child: Padding(padding: padding, child: child),
      ),
    );

    final blurred = OvertoneTheme.glassEffectsEnabled
        ? BackdropFilter(
            // inner 先执行：先模糊背板，再由 outer 的饱和度矩阵提色。
            filter: ui.ImageFilter.compose(
              inner: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              outer: ui.ColorFilter.matrix(
                _saturationMatrix(theme.glassSaturation),
              ),
            ),
            child: panel,
          )
        : panel;

    return Container(
      height: height,
      decoration: BoxDecoration(borderRadius: borderRadius, boxShadow: shadow),
      child: ClipRRect(borderRadius: borderRadius, child: blurred),
    );
  }
}

/// Rec.709 亮度权重的饱和度矩阵（20 个分量，行主序，平移列为 0）。
///
/// 用它叠在高斯模糊之后，把透出来的背板颜色「提鲜」，接近 iOS 玻璃的观感。
List<double> _saturationMatrix(double s) {
  const r = 0.2126;
  const g = 0.7152;
  const b = 0.0722;
  return [
    r + (1 - r) * s, g - g * s, b - b * s, 0, 0, //
    r - r * s, g + (1 - g) * s, b - b * s, 0, 0, //
    r - r * s, g - g * s, b + (1 - b) * s, 0, 0, //
    0, 0, 0, 1, 0, //
  ];
}

/// 玻璃的三段描边：顶亮、侧发丝、底暗。
///
/// 用 [PaintingStyle.stroke] 画一条 1px、半像素内缩的圆角路径，保证线条
/// 落在面板内缘且四角与直边自然衔接；颜色差异只能靠「分段叠画」实现
/// （[BoxDecoration] 的 `Border` 不支持圆角 + 非均匀色）。
class _GlassRimPainter extends CustomPainter {
  const _GlassRimPainter({
    required this.radius,
    required this.top,
    required this.side,
    required this.bottom,
  });

  final double radius;
  final Color top;
  final Color side;
  final Color bottom;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 1 || size.height <= 1) return;
    final r = math.min(radius, math.min(size.width, size.height) / 2);
    // 半像素内缩：1px 描边以线中心对齐，正好压住面板的内缘。
    final rect = Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1);
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(math.max(r - 0.5, 0)),
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = side;

    // 整圈打底：直边与四角圆弧都先按「侧发丝线」画，再分段覆盖。
    canvas.drawRRect(rrect, paint);
    // 顶边受光 / 底边收暗，覆盖掉直线段上的发丝线。
    canvas.drawLine(
      Offset(r, 0.5),
      Offset(size.width - r, 0.5),
      paint..color = top,
    );
    canvas.drawLine(
      Offset(r, size.height - 0.5),
      Offset(size.width - r, size.height - 0.5),
      paint..color = bottom,
    );
  }

  @override
  bool shouldRepaint(_GlassRimPainter oldDelegate) =>
      oldDelegate.radius != radius ||
      oldDelegate.top != top ||
      oldDelegate.side != side ||
      oldDelegate.bottom != bottom;
}
