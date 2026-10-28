import 'package:flutter/material.dart';

import 'overtone_theme.dart';
import 'overtone_tokens.dart';

/// 「MAGI / EVA-02」皮肤：纯黑底 + 白结构线 + 朱红强调的福音战士海报风。
///
/// 视觉基准（对齐设计稿：黑/白/红三色 + 巨号衬线）：
/// - 背景：近纯黑 #070709，叠加 48px 朱红网格
/// - 结构：白色硬边线（2–4px）承担分区，不再用渐变面板/紫光晕
/// - 主色：朱红 #E60012，只用于状态、编号、进度与选中强调
/// - 文字：纯白 #FFFFFF / 灰阶次级
/// - 形状：全直角，无胶囊、无外发光
/// - 氛围：NERV 标志、巨号幽灵字、日文引句、ALERT 角标
abstract final class MagiSkin {
  // 展示型字号：只服务于 MAGI 播放页的主标题与读数，不进入全站字号阶梯。
  static const double heroSize = 44;
  static const double homeHeroSize = 64;
  // 窄屏（手机 / 窄窗口）页头：巨号字会让 360px 溢出，这里收到一档。
  static const double homeHeroSizeNarrow = 34;
  static const double homeHeroDateSize = 50;
  static const double entryTitleSize = 28;
  static const double readoutSize = 40;

  // ── 海报字号阶梯（刻意不并入全站的 10/12/15/18/22）──
  // EVA 的排版靠字号对比吃饭：品牌字要压过正文，微标签要小到不抢文案。
  // 这些值只给 MAGI 自己用；标准/瑞士皮肤仍受 design_tokens_policy_test 约束。
  static const double brandSize = 44;
  static const double brandSubSize = 10;
  static const double groupSize = 11;
  static const double navSize = 18;
  static const double navNumeralSize = 16;
  static const double navEnSize = 9;
  static const double numeralSize = 20;
  static const double gaugeLabelSize = 10;
  static const double tagSize = 12;
  static const double buttonSize = 16;

  // 中性结构线：白色硬边是 MAGI 的分区语言，红线只落在强调元素上。
  static const lineSoft = Color(0x1FFFFFFF); // 0.12 white
  static const lineMid = Color(0x66FFFFFF); // 0.40 white
  static const lineStrong = Color(0xE6FFFFFF); // 0.90 white

  // ── 纯黑底 ────────────────────────────────────────────────
  static const bgBase = Color(0xFF070709);
  static const bgLayer1 = Color(0xFF0C0C10);
  static const bgLayer2 = Color(0xFF131318);
  static const bgLayer3 = Color(0xFF1B1B21);
  static const bgOverlay = Color(0xFF0A0A0D);

  // ── 朱红 ──────────────────────────────────────────────────
  static const redPrimary = Color(0xFFE60012);
  static const redHover = Color(0xFFFF2A3C);
  static const redDeep = Color(0xFFA3000D);
  static const redHairline = Color(0x59E60012); // 0.35 alpha
  static const redBorderLight = Color(0x33E60012); // 0.20
  static const redBorderStrong = Color(0x99E60012); // 0.60

  // ── 中性副色（旧紫色位已收敛为白/灰，保留命名避免大范围改动）──
  static const violet = Color(0xFF8A8A93);
  static const violetLight = Color(0xFFFFFFFF);
  static const violetDeep = Color(0xFF26262C);
  static const magenta = Color(0xFFFF5A5F);

  // 兼容旧命名：同步灯、频谱高段、次级参数统一改用白色。
  static const pilotGreen = violetLight;
  static const hazardGold = violetLight;
  static const alertPink = Color(0xFFFF7A90);

  // ── 文字 ──────────────────────────────────────────────────
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB9B9C0);
  static const textTertiary = Color(0xFF808089);
  static const textDimmed = Color(0xFF4E4E56);
  static const textCaption = Color(0xFF9A9AA3);
  static const textOnAccent = Color(0xFF070709);

  // ── 纯色底（保留旧 API，避免皮肤分支继续引入渐变与光晕）──
  static const shellGradient = LinearGradient(
    colors: [bgBase, bgBase],
  );

  static const dockGradient = LinearGradient(
    colors: [bgBase, bgBase],
  );

  static const sidebarGradient = LinearGradient(
    colors: [bgBase, bgBase],
  );

  static const redGradient = LinearGradient(
    colors: [redPrimary, redPrimary],
  );

  static const violetGradient = LinearGradient(
    colors: [bgLayer1, bgLayer1],
  );

  static const glowRed = <BoxShadow>[];
  static const glowRedSoft = <BoxShadow>[];
  static const glowViolet = <BoxShadow>[];
  static const glowVioletSoft = <BoxShadow>[];

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
    divider: lineSoft,
    overlay: Color(0x99000000),
  );

  static ThemeData theme(OvertoneAccent accent) {
    final base = buildOvertoneTheme(
      Brightness.dark,
      accent: accent,
      palette: palette,
    );

    const radius = BorderRadius.zero;
    final line = lineSoft;

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
          side: BorderSide(color: lineMid),
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
          side: BorderSide(color: lineSoft),
        ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: bgLayer1.withValues(alpha: 0.72),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: lineMid),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: redPrimary, width: 1.4),
        ),
      ),
    );
  }
}
