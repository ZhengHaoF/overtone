import 'package:flutter/material.dart';

import 'experimental_ui_skin.dart';
import 'overtone_theme.dart';
import 'overtone_tokens.dart';

/// EVA 皮肤家族的双套调色板：贰号机（红黑海报）与零号机（瓷白冰蓝）。
///
/// 版式、字号、组件与文案由 [MagiSkin] 与 `magi_chrome.dart` 共用，这里只切
/// 「颜色 + 角色元素」。两套都来自同一份 EVA 参考设计：
/// - `unit02` 沿用 NERV 战术终端的黑底白线朱红，只用于状态与强调。
/// - `unit00` 对齐参考项目 `dsh-plugin-eva-theme` 的绫波丽亮色令牌
///   （`docs/theme-tokens.md`）：瓷白底、冰蓝主色、少量酒红作危险标记。
final class EvaPalette {
  const EvaPalette({
    required this.brightness,
    required this.bgBase,
    required this.bgLayer1,
    required this.bgLayer2,
    required this.bgLayer3,
    required this.bgOverlay,
    required this.lineSoft,
    required this.lineMid,
    required this.lineStrong,
    required this.accent,
    required this.accentHover,
    required this.accentDeep,
    required this.accentWash,
    required this.accentBorder,
    required this.accentBorderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDimmed,
    required this.textCaption,
    required this.textOnAccent,
    required this.favorite,
    required this.danger,
    required this.success,
    required this.warn,
    required this.grid,
    required this.tagBg,
    required this.tagText,
    required this.tagAccentText,
    required this.unitCode,
    required this.emblemTint,
    required this.pilotArt,
    required this.shellGradient,
    required this.dockGradient,
    required this.sidebarGradient,
    required this.accentGradient,
    required this.glow,
    required this.glowSoft,
    required this.palette,
  });

  final Brightness brightness;
  final Color bgBase;
  final Color bgLayer1;
  final Color bgLayer2;
  final Color bgLayer3;
  final Color bgOverlay;

  /// 结构线：白/蓝硬边是两套皮肤共同的分区语言。
  final Color lineSoft;
  final Color lineMid;
  final Color lineStrong;

  /// 强调色（朱红 / 冰蓝）只落在状态、编号、进度与选中。
  final Color accent;
  final Color accentHover;
  final Color accentDeep;
  final Color accentWash;
  final Color accentBorder;
  final Color accentBorderStrong;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDimmed;
  final Color textCaption;
  final Color textOnAccent;

  final Color favorite;
  final Color danger;
  final Color success;
  final Color warn;

  /// 48px 网格线（已含透明度），两种底色上都不抢内容。
  final Color grid;

  /// 叠在封面上的角标：黑底 + 灰/红字；蓝版反过来用深海军蓝表头 + 白字。
  final Color tagBg;
  final Color tagText;
  final Color tagAccentText;

  /// 机体编号，用于幽灵巨字号与皮肤自述（'02' / '00'）。
  final String unitCode;

  /// NERV 徽记着色；null 表示保留原图红色。
  final Color? emblemTint;

  /// 角色线稿水印（透明 PNG，用 [emblemTint] 同色染色）；null 表示不放。
  final String? pilotArt;

  final LinearGradient shellGradient;
  final LinearGradient dockGradient;
  final LinearGradient sidebarGradient;
  final LinearGradient accentGradient;

  final List<BoxShadow> glow;
  final List<BoxShadow> glowSoft;

  final OvertonePalette palette;

  bool get isLight => brightness == Brightness.light;

  static EvaPalette forSkin(ExperimentalUiSkin skin) =>
      skin == ExperimentalUiSkin.evaBlue ? unit00 : unit02;

  /// 贰号机 / 明日香 · 暗色红黑（原 MAGI 皮肤，视觉保持不变）。
  static const unit02 = EvaPalette(
    brightness: Brightness.dark,
    bgBase: Color(0xFF070709),
    bgLayer1: Color(0xFF0C0C10),
    bgLayer2: Color(0xFF131318),
    bgLayer3: Color(0xFF1B1B21),
    bgOverlay: Color(0xFF0A0A0D),
    lineSoft: Color(0x1FFFFFFF),
    lineMid: Color(0x66FFFFFF),
    lineStrong: Color(0xE6FFFFFF),
    accent: Color(0xFFE60012),
    accentHover: Color(0xFFFF2A3C),
    accentDeep: Color(0xFFA3000D),
    accentWash: Color(0x59E60012),
    accentBorder: Color(0x33E60012),
    accentBorderStrong: Color(0x99E60012),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB9B9C0),
    textTertiary: Color(0xFF808089),
    textDimmed: Color(0xFF4E4E56),
    textCaption: Color(0xFF9A9AA3),
    textOnAccent: Color(0xFFFFFFFF),
    favorite: Color(0xFFFF5A5F),
    danger: Color(0xFFFF7A90),
    success: Color(0xFFFFFFFF),
    warn: Color(0xFFFFFFFF),
    grid: Color(0x1FE60012),
    tagBg: Color(0xE0070709),
    tagText: Color(0xFF808089),
    tagAccentText: Color(0xFFE60012),
    unitCode: '02',
    emblemTint: null,
    pilotArt: null,
    shellGradient: LinearGradient(
      colors: [Color(0xFF070709), Color(0xFF070709)],
    ),
    dockGradient: LinearGradient(
      colors: [Color(0xFF070709), Color(0xFF070709)],
    ),
    sidebarGradient: LinearGradient(
      colors: [Color(0xFF070709), Color(0xFF070709)],
    ),
    accentGradient: LinearGradient(
      colors: [Color(0xFFE60012), Color(0xFFE60012)],
    ),
    glow: <BoxShadow>[],
    glowSoft: <BoxShadow>[],
    palette: OvertonePalette(
      brightness: Brightness.dark,
      bg: Color(0xFF070709),
      surface: Color(0xFF0C0C10),
      surfaceElevated: Color(0xFF131318),
      primary: Color(0xFFE60012),
      favorite: Color(0xFFFF5A5F),
      danger: Color(0xFFFF7A90),
      textPrimary: Color(0xFFFFFFFF),
      textSecondary: Color(0xFFB9B9C0),
      textTertiary: Color(0xFF808089),
      divider: Color(0x1FFFFFFF),
      overlay: Color(0x99000000),
    ),
  );

  /// 零号机 / 绫波丽 · 亮色瓷白冰蓝。
  ///
  /// 色值取自参考项目 `dsh-plugin-eva-theme/docs/theme-tokens.md` 的
  /// 「亮色 · 绫波丽」列；酒红 [danger] 对应参考里的 error / 危险胶带。
  static const unit00 = EvaPalette(
    brightness: Brightness.light,
    bgBase: Color(0xFFEFF6FA),
    bgLayer1: Color(0xFFF7FBFD),
    bgLayer2: Color(0xFFFFFFFF),
    bgLayer3: Color(0xFFE4EEF5),
    bgOverlay: Color(0xFFFFFFFF),
    lineSoft: Color(0x1728698A),
    lineMid: Color(0x2928698A),
    lineStrong: Color(0x5928698A),
    accent: Color(0xFF176B91),
    accentHover: Color(0xFF115777),
    accentDeep: Color(0xFF0E4A66),
    accentWash: Color(0x2428698A),
    accentBorder: Color(0x4028698A),
    accentBorderStrong: Color(0x5928698A),
    textPrimary: Color(0xFF203849),
    textSecondary: Color(0xFF476173),
    textTertiary: Color(0xFF526C7C),
    textDimmed: Color(0xFFB6CAD7),
    textCaption: Color(0xFF718998),
    textOnAccent: Color(0xFFFFFFFF),
    favorite: Color(0xFFC2415C),
    danger: Color(0xFFAD3D57),
    success: Color(0xFF267263),
    warn: Color(0xFF926008),
    grid: Color(0x1A28698A),
    tagBg: Color(0xF2203B4C),
    tagText: Color(0xFFB6CAD7),
    tagAccentText: Color(0xFFFFFFFF),
    unitCode: '00',
    emblemTint: Color(0xFF176B91),
    pilotArt: 'assets/eva/rei_portrait.png',
    shellGradient: LinearGradient(
      colors: [Color(0xFFEFF6FA), Color(0xFFEFF6FA)],
    ),
    dockGradient: LinearGradient(
      colors: [Color(0xFFEFF6FA), Color(0xFFEFF6FA)],
    ),
    sidebarGradient: LinearGradient(
      colors: [Color(0xFFEFF6FA), Color(0xFFEFF6FA)],
    ),
    accentGradient: LinearGradient(
      colors: [Color(0xFF176B91), Color(0xFF176B91)],
    ),
    glow: <BoxShadow>[],
    glowSoft: <BoxShadow>[],
    palette: OvertonePalette(
      brightness: Brightness.light,
      bg: Color(0xFFEFF6FA),
      surface: Color(0xFFF7FBFD),
      surfaceElevated: Color(0xFFFFFFFF),
      primary: Color(0xFF176B91),
      favorite: Color(0xFFC2415C),
      danger: Color(0xFFAD3D57),
      textPrimary: Color(0xFF203849),
      textSecondary: Color(0xFF476173),
      textTertiary: Color(0xFF526C7C),
      divider: Color(0x1728698A),
      overlay: Color(0x99000000),
    ),
  );

  ThemeData theme(OvertoneAccent accentChoice) {
    final base = buildOvertoneTheme(
      brightness,
      accent: accentChoice,
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
          borderSide: BorderSide(color: accent, width: 1.4),
        ),
      ),
    );
  }
}
