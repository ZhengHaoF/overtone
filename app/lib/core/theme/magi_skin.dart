import 'package:flutter/material.dart';

import 'overtone_theme.dart';
import 'overtone_tokens.dart';

/// 「MAGI / EVA-02」皮肤：深紫黑底 + 霓虹朱红 + 紫色光晕的福音战士海报风。
///
/// 视觉基准：
/// - 背景：深紫黑渐变（#09040F → #1B0B2B），顶部偏紫、底部回落近黑
/// - 主色：霓虹朱红 #FF2743（同步率 / 警戒 / 选中态）
/// - 副色：霓虹紫 #8B5CF6（光晕、次级参数、日文注释）
/// - 文字：暖白 #F6EEF9 / 淡紫灰 #C9B6D6 / 暗紫 #9683A6
/// - 形状：12px 圆角卡片 + 发丝朱红描边 + 外发光，胶囊按钮
/// - 氛围：NERV 圆形水印章、巨号 NERV 幽灵字、日文引句、ALERT 角标
abstract final class MagiSkin {
  // 展示型字号：只服务于 MAGI 播放页的主标题与读数，不进入全站字号阶梯。
  static const double heroSize = 38;
  static const double readoutSize = 24;

  // 中性结构线：朱红发丝线只留给强调，分隔线退回中性色，避免整屏暗红发闷。
  static const lineSoft = Color(0x1AF6EEF9);

  // ── 深紫黑底 ──────────────────────────────────────────────
  static const bgBase = Color(0xFF09040F);
  static const bgLayer1 = Color(0xFF140B1E);
  static const bgLayer2 = Color(0xFF1D1029);
  static const bgLayer3 = Color(0xFF2A1738);
  static const bgOverlay = Color(0xFF241233);

  // ── 霓虹朱红 ──────────────────────────────────────────────
  static const redPrimary = Color(0xFFFF2743);
  static const redHover = Color(0xFFFF5C72);
  static const redDeep = Color(0xFFB00E24);
  static const redHairline = Color(0x59FF2743); // 0.35 alpha
  static const redBorderLight = Color(0x33FF2743); // 0.20
  static const redBorderStrong = Color(0x80FF2743); // 0.50

  // ── 霓虹紫 / 品红 ─────────────────────────────────────────
  static const violet = Color(0xFF8B5CF6);
  static const violetLight = Color(0xFFC084FC);
  static const violetDeep = Color(0xFF3B1E5A);
  static const magenta = Color(0xFFD946EF);

  // 兼容旧命名：同步灯、频谱高段、次级参数统一改用霓虹紫。
  static const pilotGreen = violetLight;
  static const hazardGold = violetLight;
  static const alertPink = Color(0xFFFF7A90);

  // ── 文字 ──────────────────────────────────────────────────
  static const textPrimary = Color(0xFFF6EEF9);
  static const textSecondary = Color(0xFFC9B6D6);
  static const textTertiary = Color(0xFF9683A6);
  static const textDimmed = Color(0xFF5F4B70);
  static const textCaption = Color(0xFFA995B8);
  static const textOnAccent = Color(0xFF09040F);

  // ── 渐变与光晕 ────────────────────────────────────────────
  static const shellGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF09040F), Color(0xFF1B0B2B), Color(0xFF0A0510)],
    stops: [0.0, 0.55, 1.0],
  );

  static const dockGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF190D25), Color(0xFF0B0612)],
  );

  static const sidebarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF180C25), Color(0xFF0A0510)],
  );

  static const redGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [redDeep, redPrimary, Color(0xFFFF627A)],
  );

  static const violetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2A1240), Color(0xFF170B24)],
  );

  static const glowRed = [
    BoxShadow(color: Color(0x4DFF2743), blurRadius: 18, spreadRadius: 1),
  ];

  static const glowRedSoft = [
    BoxShadow(color: Color(0x33FF2743), blurRadius: 26),
  ];

  static const glowViolet = [
    BoxShadow(color: Color(0x408B5CF6), blurRadius: 26, spreadRadius: 1),
  ];

  static const glowVioletSoft = [
    BoxShadow(color: Color(0x268B5CF6), blurRadius: 18),
  ];

  static const palette = OvertonePalette(
    brightness: Brightness.dark,
    bg: bgBase,
    surface: bgLayer1,
    surfaceElevated: bgLayer2,
    primary: redPrimary,
    favorite: magenta,
    danger: alertPink,
    textPrimary: textPrimary,
    textSecondary: textSecondary,
    textTertiary: textTertiary,
    divider: redBorderLight,
    overlay: Color(0x99000000),
  );

  static ThemeData theme(OvertoneAccent accent) {
    final base = buildOvertoneTheme(
      Brightness.dark,
      accent: accent,
      palette: palette,
    );

    const radius = BorderRadius.all(Radius.circular(OvertoneRadius.card));
    final line = redBorderLight;

    return base.copyWith(
      scaffoldBackgroundColor: bgBase,
      canvasColor: bgBase,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
          letterSpacing: 0.6,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        shape: Border(bottom: BorderSide(color: line)),
      ),
      cardTheme: base.cardTheme.copyWith(
        color: bgLayer1,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: redHairline),
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
          side: BorderSide(color: line.withValues(alpha: 0.35)),
        ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: bgLayer1.withValues(alpha: 0.72),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: redBorderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: redPrimary, width: 1.4),
        ),
      ),
    );
  }
}
