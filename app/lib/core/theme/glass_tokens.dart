import 'package:flutter/material.dart';

import 'overtone_tokens.dart';

/// 玻璃层级。层级差异同时体现在「折射带宽 / 模糊强度 / 染色浓度 /
/// 边缘高光 / 投影」五个维度上，而不只是透明度——这是液态玻璃与普通
/// 半透明的分界。
///
/// - [thin]：贴着内容的小面积面板（入口卡、搜索面、统计卡）；
/// - [regular]：功能性的悬浮 chrome（迷你播放条、Dock）；
/// - [thick]：大块、需要压住底层内容的面（底部 sheet、全播放器控制面）。
enum GlassTier { thin, regular, thick }

/// 玻璃效果的运行档位（降级开关）。
///
/// 对应 [docs/liquid-glass-v2/FLUTTER-PLAN.md] 的 A / B / C 三档：
///
/// - [full]：A 档。`ImageFilter.shader` 采样背板 → SDF 高度场折射 + 三通
///   道色散。只有 `ImageFilter.isShaderFilterSupported`（Impeller）且没人
///   手动关掉时才生效；
/// - [noDispersion]：A 档关色散（R/B 不再相对 G 偏移，少两次全区域采样）；
/// - [blur]：B 档（**默认**）。不做折射，改用 `blur` + 双色描边 + 高光跟随 +
///   按压 + 融合。对照稿在没有 `backdrop-filter: url(#svg)` 的浏览器上就是
///   这条路径；
/// - [off]：C 档。连背板采样都不做，只剩底色 + 描边（低端机排查用）。
///
/// 默认 [full]：2026-11-04 在 MuMu 15.0（Android 15 / x86_64，Impeller
/// **Vulkan**，dpr 4.0）上用 `ui_demo/glass_probe_page.dart` 实测通过——
/// 采样坐标平移 8px 后玻璃内的条纹确实错位，说明第一个 sampler 拿到的
/// 就是背板快照；整体染红后玻璃内仍保留条纹与文字结构（不是纯色块），
/// 且文字方向正常（Vulkan 无需翻 y）。证据图见
/// `docs/liquid-glass-v2/shots/probe/`。
///
/// 回退：改成 [blur] 就回到对照稿的降级路径（不做折射/色散），
/// 不需要动组件代码。
enum GlassQuality {
  /// A 档：折射 + 色散。
  full,

  /// A 档关色散。
  noDispersion,

  /// B 档：不做折射，只做模糊 + 高光 + 内阴影 + 融合 + 按压。
  blur,

  /// C 档：连背板采样都不做。
  off;

  /// 默认 [full]（A 档）。只有在 shader 不可用 / 用户关掉玻璃效果 /
  /// 嵌套玻璃时才自动退回 B 档。
  ///
  /// 需要临时做 B 档观感对照时，不用改代码，直接
  /// `flutter build apk --debug --dart-define=OVERTONE_GLASS_BLUR=true`。
  static GlassQuality level = const bool.fromEnvironment('OVERTONE_GLASS_BLUR')
      ? GlassQuality.blur
      : GlassQuality.full;

  /// 是否允许折射（A 档）。[blur] / [off] 都不允许。
  static bool get refractionAllowed =>
      level == GlassQuality.full || level == GlassQuality.noDispersion;

  /// 是否开色散（只有 [full] 开）。
  static bool get dispersionAllowed => level == GlassQuality.full;

  /// 是否允许任何背板采样。[off] 关闭。
  static bool get backdropAllowed => level != GlassQuality.off;
}

/// 一级玻璃的完整参数集（深浅色各一套）。
///
/// 光源统一假设为**左上入射**，所以所有面都遵守同一条明暗规律：
/// 顶边最亮 → 左边次亮 → 右边发丝 → 底边最暗；左上角另叠一层柔光。
/// 内阴影同样按这个方向：顶部内侧受光（白），底部内侧收暗（黑），
/// 相当于玻璃自身的厚度。
///
/// 数值来源：`D:/work/Overtone/docs/liquid-glass-v2/index.html`
/// （TIER / PEAK_RATIO / DISPERSION / `.lg` 与 `.lg__spec` 的 CSS）。
@immutable
class GlassSpec {
  const GlassSpec({
    required this.tier,
    required this.band,
    required this.blurSigma,
    required this.scrollingSigma,
    required this.saturation,
    required this.contrast,
    required this.dispersion,
    required this.scrim,
    required this.sheenTop,
    required this.tintStrength,
    required this.adaptiveStrength,
    required this.rimTop,
    required this.rimSide,
    required this.rimBottom,
    required this.glint,
    required this.pressGlint,
    required this.innerTop,
    required this.innerBottom,
    required this.innerDepth,
    required this.pressInner,
    required this.shadow,
    required this.padding,
  });

  final GlassTier tier;

  /// 折射带宽（逻辑 px）。对照稿 `TIER[].band`：thin 8 / regular 14 / thick 22。
  /// 影响半径 = 距离边缘多少像素内开始折弯。
  final double band;

  /// 静止时的模糊半径（σ，逻辑 px）。对照稿 `TIER[].blur`：2.5 / 3.5 / 5。
  /// 和 v1 的 12/16/26 完全不同——v1 是「怕背景透过」，v2 是「背景本来就
  /// 该透，只是被折弯」。
  final double blurSigma;

  /// 滚动中降级后的模糊半径。滚动是最容易掉帧的时段，宁可糊一点也不卡。
  final double scrollingSigma;

  /// 背板饱和度提升系数（Rec.709 矩阵）。暗色 1.62（对照稿实测值）。
  final double saturation;

  /// 背板对比度。对照稿 1.06。
  final double contrast;

  /// 色散比例：R/B 相对 G 的位移比例。对照稿 `DISPERSION = 0.045`，
  /// 在 regular 档约等于 ±0.25px。
  final double dispersion;

  /// 玻璃底色（含 alpha）。对照稿用 `--tintA`：thin .10 / regular .20 /
  /// thick .30，色值 `rgba(9,13,20,α × 1.35)`。深色按此取值；
  /// 浅色沿用 v1 的「实而不灰」（对照稿只有深色一套）。
  final Color scrim;

  /// 顶部白色高光涂层（对照稿 `.lg` 的第一层 gradient 的 16% 白）。
  /// 它是「玻璃表面」而不是「玻璃厚度」，所以和 [scrim] 分开画。
  final Color sheenTop;

  /// 封面主色染进底色的强度。
  final double tintStrength;

  /// 内容自适应染色强度（仅 A 档）。shader 采样背板平均亮度后，把透出来
  /// 的画面向 [scrim] 靠拢的幅度：
  /// - `> 0`：深色玻璃，背景偏亮时自动加深（保住文字对比度）；
  /// - `< 0`：浅色玻璃，背景偏暗时自动提白；
  /// - `0`：关。B 档拿不到背板亮度，不走这条路，仍用固定 scrim。
  ///
  /// 这是 HIG「blurs and adjusts the luminosity」的可移植近似：材料会
  /// 「看」底下的内容，而不是一套固定参数印死。
  final double adaptiveStrength;

  /// 顶边受光（specular rim）。对照稿 `::after` 顶边 `rgba(255,255,255,.86)`。
  final Color rimTop;

  /// 侧边发丝线。
  final Color rimSide;

  /// 底边收暗。
  final Color rimBottom;

  /// 左上角柔光（radial）。对照稿 `.lg__spec`：中心在 (26%, -6%)，
  /// 0.26 白 → 38% 处 0.05 → 68% 透明；按压时抬到 0.36。
  final Color glint;

  /// 按压时的柔光（对照稿 `.lg:active .lg__spec` 的第一档）。
  final Color pressGlint;

  /// 顶部内侧受光。
  final Color innerTop;

  /// 底部内侧收暗。
  final Color innerBottom;

  /// 内阴影高度（px），越大越像厚板。
  final double innerDepth;

  /// 按压态内阴影（对照稿 `.lg:active`：`inset 0 3px 16px rgba(0,0,0,.38)`）。
  final Color pressInner;

  /// 外层投影。
  final List<BoxShadow> shadow;

  /// 内容内边距。
  final EdgeInsets padding;

  /// 位移峰值（px）= 带宽 × 0.40（对照稿 `PEAK_RATIO`）。
  double get peak => band * GlassMotion.peakRatio;

  /// 取某一层级在指定明暗下的参数。
  static GlassSpec resolve(GlassTier tier, {required bool isLight}) =>
      switch (tier) {
        GlassTier.thin => isLight ? thinLight : thinDark,
        GlassTier.regular => isLight ? regularLight : regularDark,
        GlassTier.thick => isLight ? thickLight : thickDark,
      };

  /// 深色 thin：band 8 / blur 2.5 / tintA .10。
  static const thinDark = GlassSpec(
    tier: GlassTier.thin,
    band: 8,
    blurSigma: 2.5,
    scrollingSigma: 1.6,
    saturation: 1.62,
    contrast: 1.06,
    dispersion: 0.045,
    scrim: Color(0x2B090D14),
    sheenTop: Color(0x26FFFFFF),
    tintStrength: 0.06,
    adaptiveStrength: 0.30,
    rimTop: Color(0xDBFFFFFF),
    rimSide: Color(0x33FFFFFF),
    rimBottom: Color(0x6B000000),
    glint: Color(0x42FFFFFF),
    pressGlint: Color(0x5CFFFFFF),
    innerTop: Color(0x1AFFFFFF),
    innerBottom: Color(0x24000000),
    innerDepth: 8,
    pressInner: Color(0x61000000),
    shadow: OvertoneElevation.raisedDark,
    padding: EdgeInsets.zero,
  );

  /// 深色 regular：band 14 / blur 3.5 / tintA .20。
  static const regularDark = GlassSpec(
    tier: GlassTier.regular,
    band: 14,
    blurSigma: 3.5,
    scrollingSigma: 2.2,
    saturation: 1.62,
    contrast: 1.06,
    dispersion: 0.045,
    scrim: Color(0x43090D14),
    sheenTop: Color(0x29FFFFFF),
    tintStrength: 0.08,
    adaptiveStrength: 0.38,
    rimTop: Color(0xDBFFFFFF),
    rimSide: Color(0x33FFFFFF),
    rimBottom: Color(0x6B000000),
    glint: Color(0x42FFFFFF),
    pressGlint: Color(0x5CFFFFFF),
    innerTop: Color(0x1AFFFFFF),
    innerBottom: Color(0x1F000000),
    innerDepth: 10,
    pressInner: Color(0x61000000),
    shadow: OvertoneElevation.raisedDark,
    padding: EdgeInsets.zero,
  );

  /// 深色 thick：band 22 / blur 5 / tintA .30。
  static const thickDark = GlassSpec(
    tier: GlassTier.thick,
    band: 22,
    blurSigma: 5,
    scrollingSigma: 3.2,
    saturation: 1.62,
    contrast: 1.06,
    dispersion: 0.045,
    scrim: Color(0x63090D14),
    sheenTop: Color(0x29FFFFFF),
    tintStrength: 0.09,
    adaptiveStrength: 0.46,
    rimTop: Color(0xDBFFFFFF),
    rimSide: Color(0x3DFFFFFF),
    rimBottom: Color(0x8A000000),
    glint: Color(0x45FFFFFF),
    pressGlint: Color(0x61FFFFFF),
    innerTop: Color(0x1AFFFFFF),
    innerBottom: Color(0x2A000000),
    innerDepth: 16,
    pressInner: Color(0x66000000),
    shadow: OvertoneElevation.floatingDark,
    padding: EdgeInsets.all(OvertoneSpacing.md),
  );

  /// 浅色 thin。
  ///
  /// **偏离说明**：对照稿只有深色一套（`index.html` 里没有 light 变体），
  /// 但它的 `backdrop-filter: blur + saturate(140%)` 与极低 tint 说明
  /// 「玻璃要透」是两套主题的共同前提。本轮把浅色底从「实而不灰」的
  /// 88~94% 白降到 60~70% 白，并把饱和/对比抬到接近对照稿的量级，
  /// 让背景真正透上来；文字对比由模糊 + 更高的 scrim 下限兜底。
  /// 三档仍保留层级差：thin 60% < regular 66% < thick 70%。
  static const thinLight = GlassSpec(
    tier: GlassTier.thin,
    band: 8,
    blurSigma: 2.5,
    scrollingSigma: 1.6,
    saturation: 1.28,
    contrast: 1.04,
    dispersion: 0.045,
    scrim: Color(0x99FFFFFF),
    sheenTop: Color(0x1FFFFFFF),
    tintStrength: 0.03,
    adaptiveStrength: -0.22,
    rimTop: Color(0xB0FFFFFF),
    rimSide: Color(0x42000000),
    rimBottom: Color(0x52000000),
    glint: Color(0x1FFFFFFF),
    pressGlint: Color(0x2EFFFFFF),
    innerTop: Color(0x0DFFFFFF),
    innerBottom: Color(0x12000000),
    innerDepth: 8,
    pressInner: Color(0x26000000),
    shadow: OvertoneElevation.raisedLight,
    padding: EdgeInsets.zero,
  );

  static const regularLight = GlassSpec(
    tier: GlassTier.regular,
    band: 14,
    blurSigma: 3.5,
    scrollingSigma: 2.2,
    saturation: 1.30,
    contrast: 1.04,
    dispersion: 0.045,
    scrim: Color(0xA8FFFFFF),
    sheenTop: Color(0x24FFFFFF),
    tintStrength: 0.03,
    adaptiveStrength: -0.26,
    rimTop: Color(0xCCFFFFFF),
    rimSide: Color(0x47000000),
    rimBottom: Color(0x5C000000),
    glint: Color(0x26FFFFFF),
    pressGlint: Color(0x33FFFFFF),
    innerTop: Color(0x0AFFFFFF),
    innerBottom: Color(0x0F000000),
    innerDepth: 10,
    pressInner: Color(0x33000000),
    shadow: OvertoneElevation.raisedLight,
    padding: EdgeInsets.zero,
  );

  static const thickLight = GlassSpec(
    tier: GlassTier.thick,
    band: 22,
    blurSigma: 5,
    scrollingSigma: 3.2,
    saturation: 1.32,
    contrast: 1.05,
    dispersion: 0.045,
    scrim: Color(0xB3FFFFFF),
    sheenTop: Color(0x24FFFFFF),
    tintStrength: 0.04,
    adaptiveStrength: -0.30,
    rimTop: Color(0xDBFFFFFF),
    rimSide: Color(0x4D000000),
    rimBottom: Color(0x66000000),
    glint: Color(0x2EFFFFFF),
    pressGlint: Color(0x3DFFFFFF),
    innerTop: Color(0x0AFFFFFF),
    innerBottom: Color(0x14000000),
    innerDepth: 16,
    pressInner: Color(0x3D000000),
    shadow: OvertoneElevation.floatingLight,
    padding: EdgeInsets.all(OvertoneSpacing.md),
  );
}

/// 液态玻璃的动效参数（弹簧，可打断）。
///
/// 阻尼比按 Apple 的两参数模型换算：
/// ζ = damping / (2·√(mass · stiffness))
/// - [settle]：ζ ≈ 1.006 → 临界阻尼，不过冲。用于面板出现/颜色过渡；
/// - [bouncy]：ζ ≈ 0.72 → 轻微回弹。只给「有位移、有方向感」的元素
///   （选中指示点），不给纯淡入的东西，否则像炫技；
/// - [press]：ζ ≈ 0.86，按压下沉 / 抬手回弹都用它（对照稿是
///   `translate 1.5px` + `transition .22s var(--spring)`）。
abstract final class GlassMotion {
  static const SpringDescription settle = SpringDescription(
    mass: 1,
    stiffness: 320,
    damping: 36,
  );

  static const SpringDescription bouncy = SpringDescription(
    mass: 1,
    stiffness: 380,
    damping: 28,
  );

  static const SpringDescription press = SpringDescription(
    mass: 1,
    stiffness: 420,
    damping: 35,
  );

  /// 折射峰值 / 带宽（对照稿 `PEAK_RATIO = 0.40`）。
  static const double peakRatio = 0.40;

  /// 按压位移（对照稿 `.lg:active{translate:0 1.5px}`）。
  static const double pressOffset = 1.5;

  /// 按压缩放。苹果的按压反馈是「材料收缩 + 从指尖发光」，只有下沉没有
  /// 收缩会读成「卡片被按进去」，而不是「玻璃被按了一下」。
  static const double pressScale = 0.975;

  /// 滚动中的折射收敛系数。折射 shader 的 `u_origin` 比背板快照慢一帧，
  /// 折射带越大，滚动时的「错帧游动」越明显；滚动时 band / peak 一起乘它
  /// 收敛（与 [GlassSpec.scrollingSigma] 降模糊同策略），停手恢复 1.0。
  static const double scrollRefractionScale = 0.35;

  /// 设备倾斜（[GlassAmbient]）驱动的高光漂移上限（±px）。移动端没有
  /// 指针，柔光不动玻璃就像印上去的；跟随姿态小幅游移才像「被光照着」。
  static const double ambientTravel = 4;

  /// 指针 / 触摸驱动的高光位移上限（±10px）。
  static const double specularTravel = 10;

  /// 边缘高光渐变角随指针倾斜的上限（度）。
  /// 对照稿两条边框层是 `linear-gradient(135 + mouseOffset.x*1.2deg)`；
  /// ±10px 的指针位移折算到这里取 ±12°，再多就开始像「晃动」。
  static const double rimTiltDegrees = 12;

  /// 悬停时顶部中心的第二层柔光（对照稿 hover overlay `opacity .4` 的
  /// `radial-gradient(circle at 50% 0%, #fff 0%, transparent 100%)`）。
  static const double hoverSheenAlpha = 0.22;

  /// 桌面指针悬停的弹性拉伸强度。对照稿 `elasticity*0.3`（默认 0.15 →
  /// 约 ±4.5%），这里取一半，避免 Windows 上整条播放栏跟着指针「扭」。
  static const double hoverStretch = 0.012;

  /// 悬停弹性的位移比例与上限（对照稿 `(mouse - center) * elasticity * 0.1`）。
  static const double hoverShift = 0.004;
  static const double hoverMaxShift = 1.6;

  /// 悬停进入 / 退出的过渡时长（对照稿 `transition: all .2s ease-out`）。
  static const Duration hover = Duration(milliseconds: 200);

  /// 玻璃「凝结」时的起始缩放（材料从略小的一层长到最终大小）。
  static const double materializeScale = 0.96;

  /// 融合的表面张力参数 k（smooth-union，对照稿 `MERGE.k1`）。
  /// 两块玻璃的表面间距小于 k 时开始长出颈部，间距归零时 k 拉满。
  /// v2.1 起改为**几何驱动**：k 由实时间距连续插值，不再用预计算帧 +
  /// easeOutBack 回放 —— 颈部逐帧跟随位置，任意时刻可反向，天然可打断。
  static const double mergeNeck = 30;

  /// （旧帧动画方案保留）融合曲线的过冲系数（对照稿 `easeOutBack` c = 1.18）。
  static const double mergeBackOvershoot = 1.18;

  static const Duration fadeIn = Duration(milliseconds: 180);
  static const Duration fadeOut = Duration(milliseconds: 140);

  /// 颜色 / 图标这类不可用弹簧插值的过渡。
  static const Duration color = Duration(milliseconds: 150);

  /// 对照稿 `easeOutBack`（c = 1.18）。融合帧与 sheet 都有用到。
  static double easeOutBack(double t) {
    const c = mergeBackOvershoot;
    final u = t - 1;
    return 1 + (c + 1) * u * u * u + c * u * u;
  }
}
