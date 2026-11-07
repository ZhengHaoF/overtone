import 'package:flutter/material.dart';

import '../../core/theme/archive_skin.dart';
import '../../core/theme/glass_tokens.dart';
import '../../core/theme/overtone_theme.dart';
import '../../core/theme/overtone_tokens.dart';

/// 液态玻璃材质原语（生产皮肤 B 档，v2 扁平通透配方）。
///
/// 组成：形状裁剪 → 有界背板模糊 → 竖向染色渐变（上薄下重）→ rim 描边
/// → 顶部发丝高光 → 两段式外投影 → 按压缩放。
///
/// 观感对齐 docs/liquid-glass-v2 对照稿的 `.lg` 基类：染色不透明度低、
/// 模糊轻，背景大面积透出——「薄透明层」而不是「厚玻璃片」。旧版
/// 「拟物浮光」的高不透明度染色 + 对角渐变 + 18px 内阴影带已废弃。
///
/// **不接 Shader 折射**：`glass_refract.frag` 只在 `/liquid-glass-demo` 示范页
/// 挂载，这里永远走 [ui.ImageFilterConfig.blur]。
///
/// **只透正下方**：滤镜用 `bounded: true`，采样被限制在玻璃自身矩形内；
/// 同时外层 [ClipRRect] 把滤镜输出裁在玻璃形状内。二者缺一不可——
/// 无界模糊会采到相邻/上方内容，形成「上方内容的镜像复本」并溢出到框外，
/// 这正是上一轮实测到的 bug（见 docs 里的 A/B/C 对照）。
class LiquidGlass extends StatefulWidget {
  const LiquidGlass({
    super.key,
    required this.child,
    this.tier = GlassTier.regular,
    this.radius = OvertoneRadius.card,
    this.borderRadius,
    this.padding = EdgeInsets.zero,
    this.onTap,
    this.blurred = true,
    this.boxShadow,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final GlassTier tier;
  final double radius;

  /// 非对称圆角（如 sheet 顶部圆角）。给值时覆盖 [radius]。
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// false 时只保留染色/描边/高光（用于背后没有可透内容的表面，避免白付一次模糊）。
  final bool blurred;
  final List<BoxShadow>? boxShadow;
  final Clip clipBehavior;

  @override
  State<LiquidGlass> createState() => _LiquidGlassState();
}

class _LiquidGlassState extends State<LiquidGlass> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    final t = GlassTokens.resolve(theme, widget.tier);
    final radius = widget.borderRadius ?? BorderRadius.circular(widget.radius);
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 90);

    final tinted = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          // 竖向（对照稿 180deg）：上薄下重，只做收边层次，不做对角「打光」。
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            t.tint.withValues(alpha: t.scrimTop),
            t.tintAlt.withValues(alpha: t.scrimBottom),
          ],
        ),
        border: Border.all(color: t.rim, width: 1),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          // 外圈暗描边：把玻璃从同色背景里切出来（画在 rim 内侧 1px）。
          border: Border.all(color: t.rimOuter, width: 1),
        ),
        child: Stack(
          children: [
            Padding(padding: widget.padding, child: widget.child),
            // 顶部高光发丝线：玻璃的「上沿」。
            Positioned(
              top: 0,
              left: radius.topLeft.x * 0.8,
              right: radius.topRight.x * 0.8,
              child: IgnorePointer(
                child: Container(height: 1, color: t.highlight),
              ),
            ),
          ],
        ),
      ),
    );

    Widget surface = ClipRRect(
      borderRadius: radius,
      clipBehavior: widget.clipBehavior,
      child: widget.blurred
          ? BackdropFilter(
              filter: null,
              // bounded: true = 模糊采样被钳在玻璃矩形内，不会把框外内容拉进来。
              filterConfig: ImageFilterConfig.blur(
                sigmaX: t.blurSigma,
                sigmaY: t.blurSigma,
                bounded: true,
              ),
              child: tinted,
            )
          : tinted,
    );

    final interactive = widget.onTap != null;
    if (interactive) {
      surface = Semantics(
        button: true,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            onTapDown: reduceMotion ? null : (_) => _setPressed(true),
            onTapUp: reduceMotion ? null : (_) => _setPressed(false),
            onTapCancel: reduceMotion ? null : () => _setPressed(false),
            child: surface,
          ),
        ),
      );
    }

    return AnimatedScale(
      scale: _pressed && !reduceMotion ? 0.985 : 1,
      duration: duration,
      curve: Curves.easeOut,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          // 默认投影来自令牌（两段式，随档位/深浅分级）；调用方显式传入才覆盖。
          boxShadow: widget.boxShadow ?? t.shadow,
        ),
        child: surface,
      ),
    );
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }
}

/// 只在液态玻璃皮肤下把 [child] 包进一层玻璃；其它皮肤原样返回。
///
/// 用来包裹「本来就有自己布局」的现成区块，避免在每个调用点重复写
/// `isGlassSkin ? LiquidGlass(...) : child`。
class GlassIf extends StatelessWidget {
  const GlassIf({
    super.key,
    required this.child,
    this.tier = GlassTier.regular,
    this.radius = OvertoneRadius.card,
    this.padding = EdgeInsets.zero,
    this.blurred = true,
  });

  final Widget child;
  final GlassTier tier;
  final double radius;
  final EdgeInsetsGeometry padding;
  final bool blurred;

  @override
  Widget build(BuildContext context) {
    if (!context.isGlassSkin) return child;
    return LiquidGlass(
      tier: tier,
      radius: radius,
      padding: padding,
      blurred: blurred,
      child: child,
    );
  }
}

/// 皮肤级氛围底：一层克制的渐变 + 三块柔光色块。
///
/// 玻璃必须有东西可透，否则会退化成白卡/黑卡；这里只做背景，不参与信息层级，
/// 页面上所有文字/图标仍画在氛围底之上。只挂在玻璃皮肤下。
class GlassAmbientBackdrop extends StatelessWidget {
  const GlassAmbientBackdrop({
    super.key,
    required this.child,
    this.accentColor,
  });

  final Widget child;

  /// 可选的第三块光斑颜色（播放页取封面主色，让玻璃透出「这首歌」的颜色）。
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = OvertoneTheme.of(context);
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _AmbientPainter(
                theme: theme,
                accent: accentColor,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _AmbientPainter extends CustomPainter {
  const _AmbientPainter({required this.theme, this.accent});

  final OvertoneTheme theme;
  final Color? accent;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final light = theme.isLight;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.bg,
            Color.alphaBlend(
              // 底部整幅淡彩洗底：玻璃通透化后，背板要「有内容可透」。
              theme.primary.withValues(alpha: 0.16),
              theme.bg,
            ),
          ],
        ).createShader(rect),
    );

    void blob(Offset center, double radius, Color color, double alpha) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: alpha), color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
    }

    final short = size.shortestSide;
    // 玻璃压通透后，「背板有内容可透」全靠这层氛围。构图对齐示范页
    // （/liquid-glass-demo 的 _GlassBackdropPainter）：大圆贴角、被窗口
    // 边自然裁切——那是设计的一部分；此前误把它当「两侧隔断」而内收，
    // 真正的隔断是卡片投影被滚动视口硬裁（见各页 padding 留余量）。
    // 浅色 alpha 对齐示范页 0.20–0.30 档，文字对比度由玻璃染色层兜底。
    blob(
      Offset(size.width * 0.10, size.height * 0.14),
      short * 0.34,
      theme.primary,
      light ? 0.30 : 0.26,
    );
    blob(
      Offset(size.width * 0.90, size.height * 0.40),
      short * 0.36,
      theme.favorite,
      light ? 0.20 : 0.16,
    );
    blob(
      Offset(size.width * 0.20, size.height * 0.86),
      short * 0.38,
      theme.primary,
      light ? 0.24 : 0.20,
    );
    final accent = this.accent;
    if (accent != null) {
      blob(
        Offset(size.width * 0.72, size.height * 0.62),
        short * 0.40,
        accent,
        light ? 0.16 : 0.22,
      );
    }
    // 注意：示范页的细发丝斜线不搬进来——空背景上读作纸纹，压到
    // 有内容的页面（发现/设置）就成了一层层「条条」，只会像渲染瑕疵。
    // 参考页保留自己的画笔；全站氛围只保留渐变 + 圆斑。
  }

  @override
  bool shouldRepaint(_AmbientPainter oldDelegate) =>
      oldDelegate.theme != theme || oldDelegate.accent != accent;
}

/// 玻璃皮肤下的文字色（浅色不从半透明次要色读，避免糊在氛围底上）。
TextStyle glassText(
  BuildContext context,
  GlassTier tier, {
  TextStyle? base,
  bool secondary = false,
  bool tertiary = false,
}) {
  final t = GlassTokens.of(context, tier);
  final color = tertiary
      ? t.onGlassTertiary
      : secondary
      ? t.onGlassSecondary
      : t.onGlass;
  return (base ?? const TextStyle(fontSize: OvertoneFontSize.body)).copyWith(
    color: color,
  );
}
