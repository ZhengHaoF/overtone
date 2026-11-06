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

/// 液态玻璃皮肤（[ExperimentalUiSkin.glass]）的材质令牌。
///
/// 只给玻璃皮肤用；默认 / MAGI / 档案皮肤的所有取值都不从这里读。
/// 深浅两套各自给值，保证玻璃上的文字对比度不依赖「背景恰好很暗」。
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
    required this.innerShadow,
    required this.onGlass,
    required this.onGlassSecondary,
    required this.onGlassTertiary,
  });

  /// 背板模糊半径。生产皮肤只走这一档（不接 Shader 折射）。
  final double blurSigma;

  /// 染色顶/底透明度（渐变给出层次，避免平铺成一张白卡）。
  final double scrimTop;
  final double scrimBottom;

  final Color tint;
  final Color tintAlt;

  /// 内侧高光描边（rim）与外圈暗描边（把玻璃从背景里切出来）。
  final Color rim;
  final Color rimOuter;

  /// 顶部 1px 高光。
  final Color highlight;

  /// 底部内阴影颜色（B 档「内阴影」）。
  final Color innerShadow;

  /// 玻璃上的文字三阶；浅色下不从半透明次要色读，保证对比度。
  final Color onGlass;
  final Color onGlassSecondary;
  final Color onGlassTertiary;

  static GlassTokens resolve(OvertoneTheme theme, GlassTier tier) {
    final light = theme.isLight;
    final blur = switch (tier) {
      GlassTier.thin => 12.0,
      GlassTier.regular => 18.0,
      GlassTier.thick => 26.0,
    };
    // 浅色用白玻璃；深色用偏冷的墨蓝玻璃（不纯黑，避免变灰板）。
    final base = light ? Colors.white : theme.surfaceElevated;
    final baseAlt = light ? const Color(0xFFF4F8FC) : theme.surface;

    final scrim = light
        ? switch (tier) {
            GlassTier.thin => 0.58,
            GlassTier.regular => 0.66,
            GlassTier.thick => 0.74,
          }
        : switch (tier) {
            GlassTier.thin => 0.50,
            GlassTier.regular => 0.60,
            GlassTier.thick => 0.70,
          };

    return GlassTokens(
      blurSigma: blur,
      scrimTop: scrim,
      scrimBottom: (scrim - 0.06).clamp(0.0, 1.0),
      tint: base,
      tintAlt: baseAlt,
      rim: light
          ? Colors.white.withValues(alpha: 0.72)
          : Colors.white.withValues(alpha: 0.16),
      rimOuter: light
          ? Colors.black.withValues(alpha: 0.07)
          : Colors.black.withValues(alpha: 0.38),
      highlight: light
          ? Colors.white.withValues(alpha: 0.92)
          : Colors.white.withValues(alpha: 0.38),
      innerShadow: light
          ? Colors.black.withValues(alpha: 0.09)
          : Colors.black.withValues(alpha: 0.42),
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

  static Color ambientBottom(OvertoneTheme theme) => theme.isLight
      ? Color.alphaBlend(theme.primary.withValues(alpha: 0.10), theme.bg)
      : Color.alphaBlend(theme.primary.withValues(alpha: 0.16), theme.bg);
}
