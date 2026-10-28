import 'package:flutter/material.dart';

import 'overtone_theme.dart';
import 'overtone_tokens.dart';

/// 「MAGI 战术终端」皮肤（EVA 战术超算界面风格）。
///
/// 视觉基准严格参照 `dsh-plugin-eva-theme` 暗色 · 明日香（Unit-02 / Red）主题：
/// - 纯黑/深灰碳素底色：#0D0F13 / #14171C / #1C2028 / #272C35
/// - 核心警戒朱红高光：#FF354D（EVA 弐号机 Crimson Red / 品牌主色）
/// - 悬浮与按钮高亮：#FF5967（Brand text / button hover）
/// - 警示琥珀金：#E5A24F（Secondary / Hazard warning）
/// - 同步/判定绿：#8DC358（EVA Pilot sync mark / success）
/// - 错误/警报粉红：#FF8494（Danger / error）
/// - 暖象牙白主文字：#FFF1E7（Warm cream white text）
/// - 次级与技术文字：#C6B7AC / #B3A294 / #8E8178 / #63646A
/// - 朱红发丝线描边：#F33A51（带透明度，四级递进）
/// - 纯硬边：0 圆角，切角与直角
abstract final class MagiSkin {
  // 展示型字号：只服务于 MAGI 播放页的主标题与读数，不进入全站字号阶梯。
  static const double heroSize = 38;
  static const double readoutSize = 24;

  // 中性结构线：朱红发丝线只留给强调，分隔线退回中性色，避免整屏暗红发闷。
  static const lineSoft = Color(0x1AFFF1E7);

  // 色板核心定义（来自 dsh-plugin-eva-theme 暗色·明日香）
  static const bgBase = Color(0xFF0D0F13); // --dsw-alias-bg-base
  static const bgLayer1 = Color(0xFF14171C); // --dsw-alias-bg-layer-1
  static const bgLayer2 = Color(0xFF1C2028); // --dsw-alias-bg-layer-2
  static const bgLayer3 = Color(0xFF272C35); // --dsw-alias-bg-layer-3
  static const bgOverlay = Color(0xFF20252D); // --dsw-alias-bg-overlay

  // 品牌朱红系列
  static const redPrimary = Color(0xFFFF354D); // --dsw-alias-brand-primary
  static const redHover = Color(0xFFFF5967); // --dsw-alias-brand-text / hover
  static const redHairline = Color(0x57F33A51); // --dsw-alias-border-l3 (0.34 alpha)
  static const redBorderLight = Color(0x3DF33A51); // --dsw-alias-border-l2 (0.24 alpha)
  static const redBorderStrong = Color(0x7AF33A51); // --dsw-alias-border-l4 (0.48 alpha)

  // 状态与辅助语义
  static const hazardGold = Color(0xFFE5A24F); // --dsw-alias-state-warn-primary / --eva-secondary
  static const pilotGreen = Color(0xFF8DC358); // --dsw-alias-state-success-primary / --eva-mark
  static const alertPink = Color(0xFFFF8494); // --dsw-alias-state-error-primary

  // 暖调文字阶梯
  static const textPrimary = Color(0xFFFFF1E7); // --dsw-alias-label-primary
  static const textSecondary = Color(0xFFC6B7AC); // --dsw-alias-label-secondary
  static const textTertiary = Color(0xFFB3A294); // --dsw-alias-label-tertiary
  static const textDimmed = Color(0xFF63646A); // --dsw-alias-label-dimmed
  static const textCaption = Color(0xFF8E8178); // --dsw-alias-label-caption
  static const textOnAccent = Color(0xFF101116); // --dsw-alias-label-primary-inverted

  static const palette = OvertonePalette(
    brightness: Brightness.dark,
    bg: bgBase,
    surface: bgLayer1,
    surfaceElevated: bgLayer2,
    primary: redPrimary,
    favorite: redHover,
    danger: alertPink,
    textPrimary: textPrimary,
    textSecondary: textSecondary,
    textTertiary: textTertiary,
    divider: redHairline,
    overlay: Color(0x8A000000),
  );

  static ThemeData theme(OvertoneAccent accent) {
    final base = buildOvertoneTheme(
      Brightness.dark,
      accent: accent,
      palette: palette,
    );

    const radius = BorderRadius.all(Radius.circular(0));
    final line = palette.divider;

    return base.copyWith(
      scaffoldBackgroundColor: bgBase,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: bgBase,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 52,
        shape: Border(bottom: BorderSide(color: line)),
      ),
      cardTheme: base.cardTheme.copyWith(
        color: bgLayer1,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: line),
        ),
      ),
      dividerTheme: base.dividerTheme.copyWith(
        color: line,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: base.listTileTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: line.withValues(alpha: 0.15)),
        ),
      ),
    );
  }
}
