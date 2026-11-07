import 'package:flutter/material.dart';

import 'overtone_theme.dart';

/// 液态玻璃的三档厚度。
///
/// 档位只描述「一层玻璃有多厚」，不绑定具体控件：胶囊、卡片、弹层、播放控制面
/// 各自挑一档，取值集中在 [GlassTokens.resolve]，避免每页复制一套色值。
enum GlassTier {
  /// 薄：紧贴内容的小面（搜索胶囊、行容器、迷你条）。
  thin,

  /// 常规：卡片、入口卡、控制台。
  regular,

  /// 厚：弹层、sheet、确认框。
  thick,
}

// 液态玻璃皮肤（[ExperimentalUiSkin.glass]）的材质令牌。
//
// 观感对齐 docs/liquid-glass-v2 对照稿的 v2 基类（`.lg`）：**扁平通透**。
// 染色不透明度刻意压低（深色 0.10–0.30，浅色 0.30–0.48），让背景大面积透出，
// 玻璃读作「薄薄一层半透明面板」而不是「厚玻璃片」；rim/高光只做收边
// 提示，不做体积；「浮起」交给两段式外投影（主影 + 近地接触影）。
// 拟物化的「厚玻璃」v1 配方（scrim 0.5–0.74 + 强高光）已废弃。
//
// 只给玻璃皮肤用；默认 / MAGI / 档案皮肤的所有取值都不从这里读。
// 深浅两套各自给值，保证玻璃上的文字对比度不依赖「背景恰好很暗」。
@immutable
class GlassTokens {
  const GlassTokens({
    required this.blurSigma,
    required this.scrimTop,
    required this.scrimBottom,
    required this.tint,
    required this.tintAlt,
    required this.rim,
    required this.rimOuter,
    required this.highlight,
    required this.shadow,
    required this.onGlass,
    required this.onGlassSecondary,
    required this.onGlassTertiary,
  });

  /// 背板模糊半径。生产皮肤只走这一档（不接 Shader 折射）。
  final double blurSigma;

  /// 染色顶/底不透明度。对齐对照稿 v2：顶部薄、底部按 `tintA × 1.3` 加重，
  /// 渐变只负责收边层次，不负责「做出一张实心卡」。
  final double scrimTop;
  final double scrimBottom;

  final Color tint;
  final Color tintAlt;

  /// 内侧高光描边（rim）与外圈暗描边（把玻璃从背景里切出来）。
  final Color rim;
  final Color rimOuter;

  /// 顶部 1px 高光。
  final Color highlight;

  /// 两段式外投影（主影 + 近地接触影），对齐对照稿 v2 的 box-shadow 拆解。
  /// 按档位放大；浅色底浅、alpha 压低一档，深色用对照稿原值附近（.38 / .24）。
  final List<BoxShadow> shadow;

  /// 玻璃上的文字三阶；浅色下不从半透明次要色读，保证对比度。
  final Color onGlass;
  final Color onGlassSecondary;
  final Color onGlassTertiary;

  static GlassTokens resolve(OvertoneTheme theme, GlassTier tier) {
    final light = theme.isLight;
    final blur = switch (tier) {
      GlassTier.thin => 10.0,
      GlassTier.regular => 14.0,
      GlassTier.thick => 20.0,
    };
    // 浅色用白玻璃；深色用偏冷的墨蓝玻璃（不纯黑，避免变灰板）。
    final base = light ? Colors.white : theme.surfaceElevated;
    final baseAlt = light ? const Color(0xFFF4F8FC) : theme.surface;

    // v2 扁平通透档：背景透出约 50%–90%，玻璃是「薄透明层」。
    // 深色对齐对照稿 tintA（.10/.20/.30）；浅色略抬一档保文字对比度，
    // 薄档再抬一档——搜索胶囊这类小型交互元素在浅色氛围底上必须有
    // 足够体量，否则右半截（提示文字之外全是空玻璃）会读成「空白条」。
    final scrim = light
        ? switch (tier) {
            GlassTier.thin => 0.38,
            GlassTier.regular => 0.38,
            GlassTier.thick => 0.48,
          }
        : switch (tier) {
            GlassTier.thin => 0.10,
            GlassTier.regular => 0.20,
            GlassTier.thick => 0.30,
          };

    // 两段式外投影：主影 + 近地接触影。取值刻意收紧（低 alpha、小 blur、
    // 小 dy）：玻璃卡同宽紧密堆叠时（如设置页分组卡），大而重的投影会在
    // 卡片两侧连成两条竖向灰带，读作「隔断」。阴影只负责把单张卡从背板
    // 上托起一点高度，不负责圈出内容列的轮廓。
    final (mainAlpha, contactAlpha) = light ? (0.12, 0.06) : (0.30, 0.18);
    final (mainBlur, mainDy, contactBlur, contactDy) = switch (tier) {
      GlassTier.thin => (8.0, 2.0, 3.0, 1.0),
      GlassTier.regular => (18.0, 6.0, 5.0, 1.0),
      GlassTier.thick => (24.0, 9.0, 6.0, 2.0),
    };
    final shadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: mainAlpha),
        blurRadius: mainBlur,
        offset: Offset(0, mainDy),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: contactAlpha),
        blurRadius: contactBlur,
        offset: Offset(0, contactDy),
      ),
    ];

    return GlassTokens(
      blurSigma: blur,
      scrimTop: scrim,
      scrimBottom: (scrim * 1.3).clamp(0.0, 1.0),
      tint: base,
      tintAlt: baseAlt,
      rim: light
          ? Colors.white.withValues(alpha: 0.45)
          : Colors.white.withValues(alpha: 0.16),
      // 浅色底上白 rim 完全隐形，外圈暗描边是玻璃唯一的「边缘定义」：
      // 0.05 在浅色氛围底上读不出，玻璃会退化成看不出边的一块白
      //（搜索胶囊右半截、入口卡都因此像随机贴片）。0.10 是刻意的。
      rimOuter: light
          ? Colors.black.withValues(alpha: 0.10)
          : Colors.black.withValues(alpha: 0.38),
      highlight: light
          ? Colors.white.withValues(alpha: 0.65)
          : Colors.white.withValues(alpha: 0.38),
      shadow: shadow,
      onGlass: theme.textPrimary,
      onGlassSecondary: light
          ? const Color(0xFF454E5C)
          : theme.textSecondary,
      onGlassTertiary: light ? const Color(0xFF5B6472) : theme.textTertiary,
    );
  }

  static GlassTokens of(BuildContext context, GlassTier tier) =>
      resolve(OvertoneTheme.of(context), tier);

  /// 氛围底（渐变 + 柔光色块）的顶部/底部色，负责给玻璃「东西可透」。
  static Color ambientTop(OvertoneTheme theme) => theme.bg;

  static Color ambientBottom(OvertoneTheme theme) =>
      Color.alphaBlend(theme.primary.withValues(alpha: 0.16), theme.bg);
}
