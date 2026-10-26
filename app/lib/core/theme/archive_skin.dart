import 'experimental_ui_skin.dart';
import 'package:flutter/material.dart';

import 'overtone_theme.dart';
import 'overtone_tokens.dart';
import 'responsive.dart';

/// 「档案终端」播放页皮肤（实验性，默认关闭）。
///
/// 视觉语言取自 Rhine 那套白底单色终端：纸白底、墨色字、发丝分隔线。
///
/// 实现只换一个 [OvertonePalette]：`OvertoneTheme` 是 ThemeExtension，在页面根部
/// 盖一层带新 extension 的 [Theme]，页内所有读取点（含 CoverBox / TrackTile 等
/// 共享组件）整片跟着走，shared 组件本身一行不改，其他页面零影响。
abstract final class ArchiveSkin {
  /// 纸白底 + 墨色字。
  ///
  /// primary / favorite / danger 直接复用浅色档的三个值：它们已经按浅色底过
  /// [design_tokens_policy_test] 的 WCAG 校验，另取值等于把那条结论作废。
  /// 新给的四项实测对比度（对 bg / surface）：
  /// textPrimary 16.9 / 17.9，textSecondary 5.70 / 6.23，
  /// textTertiary 3.57 / 3.91（三级文字按 3:1 要求），divider 是描边不参与对比度。
  static const palette = OvertonePalette(
    brightness: Brightness.light,
    bg: Color(0xFFF4F5F3),
    surface: Colors.white,
    surfaceElevated: Colors.white,
    primary: Color(0xFF01756F),
    favorite: Color(0xFFCE2F63),
    danger: Color(0xFFC42E36),
    textPrimary: Color(0xFF14171A),
    textSecondary: Color(0xFF5A6266),
    textTertiary: Color(0xFF7A8288),
    divider: Color(0x3314171A),
    overlay: Color(0x22000000),
  );

  static ThemeData theme(OvertoneAccent accent) {
    final base = buildOvertoneTheme(
      Brightness.light,
      accent: accent,
      palette: palette.withAccent(accent),
    );
    final accentColor = palette.withAccent(accent).primary;
    const radius = BorderRadius.all(Radius.circular(2));
    final line = palette.textTertiary.withValues(alpha: 0.6);
    final buttonText = base.textTheme.labelLarge?.copyWith(
      fontSize: OvertoneFontSize.caption,
      letterSpacing: 1.1,
      fontWeight: FontWeight.w500,
    );

    return base.copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: palette.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 52,
        shape: Border(bottom: BorderSide(color: line)),
        titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
          fontSize: OvertoneFontSize.section,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
          color: palette.textPrimary,
        ),
      ),
      dividerTheme: DividerThemeData(color: line, thickness: 1, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.textPrimary,
          foregroundColor: palette.surface,
          shape: const RoundedRectangleBorder(borderRadius: radius),
          minimumSize: const Size(0, 42),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.textPrimary,
          side: BorderSide(color: line),
          shape: const RoundedRectangleBorder(borderRadius: radius),
          minimumSize: const Size(0, 42),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.textPrimary,
          textStyle: buttonText,
          shape: const RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: radius),
          ),
          overlayColor: WidgetStatePropertyAll(
            palette.textPrimary.withValues(alpha: 0.05),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        hintStyle: TextStyle(
          fontSize: OvertoneFontSize.caption,
          letterSpacing: 0.6,
          color: palette.textTertiary,
        ),
        labelStyle: TextStyle(
          fontSize: OvertoneFontSize.caption,
          color: palette.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: palette.textPrimary),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: Colors.transparent,
        selectedColor: palette.textPrimary,
        secondarySelectedColor: palette.textPrimary,
        disabledColor: Colors.transparent,
        side: BorderSide(color: line),
        shape: const RoundedRectangleBorder(borderRadius: radius),
        labelStyle: TextStyle(
          fontSize: OvertoneFontSize.caption,
          color: palette.textSecondary,
        ),
        secondaryLabelStyle: TextStyle(
          fontSize: OvertoneFontSize.caption,
          color: palette.surface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        showCheckmark: false,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: palette.textPrimary,
        unselectedLabelColor: palette.textTertiary,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: palette.textPrimary, width: 2),
          insets: EdgeInsets.zero,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: line,
        labelStyle: TextStyle(
          fontSize: OvertoneFontSize.caption,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: OvertoneFontSize.caption,
          letterSpacing: 1.1,
        ),
        overlayColor: WidgetStatePropertyAll(
          palette.textPrimary.withValues(alpha: 0.04),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: radius),
          ),
          side: WidgetStatePropertyAll(BorderSide(color: line)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? palette.textPrimary
                : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? palette.surface
                : palette.textSecondary,
          ),
          textStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: OvertoneFontSize.caption, letterSpacing: 0.8),
          ),
        ),
      ),
      listTileTheme: base.listTileTheme.copyWith(
        shape: const RoundedRectangleBorder(borderRadius: radius),
        selectedTileColor: Colors.transparent,
        selectedColor: palette.textPrimary,
        iconColor: palette.textSecondary,
        textColor: palette.textPrimary,
        subtitleTextStyle: TextStyle(
          fontSize: OvertoneFontSize.caption,
          color: palette.textTertiary,
        ),
      ),
      cardTheme: base.cardTheme.copyWith(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: line),
        ),
      ),
      dialogTheme: base.dialogTheme.copyWith(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: line),
        ),
      ),
      bottomSheetTheme: base.bottomSheetTheme.copyWith(
        backgroundColor: palette.surface,
        modalBackgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      popupMenuTheme: base.popupMenuTheme.copyWith(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: line),
        ),
        textStyle: TextStyle(
          fontSize: OvertoneFontSize.body,
          color: palette.textPrimary,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: palette.textPrimary,
          borderRadius: radius,
        ),
        textStyle: TextStyle(
          fontSize: OvertoneFontSize.caption,
          color: palette.surface,
        ),
      ),
      sliderTheme: base.sliderTheme.copyWith(
        activeTrackColor: palette.textPrimary,
        inactiveTrackColor: line,
        thumbColor: palette.textPrimary,
        overlayColor: accentColor.withValues(alpha: 0.1),
        trackHeight: 2,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accentColor,
        linearTrackColor: line,
        circularTrackColor: line,
      ),
    );
  }

  /// 生效条件三条，全收在这里，别散进各页的 build：
  /// 开关开 + 当前实际是浅色 + 桌面双栏形态（首期只改桌面）。
  /// 返回 null 表示不覆盖，页面沿用 App 当前主题。
  static ThemeData? resolve(
    BuildContext context, {
    required bool enabled,
    required OvertoneAccent accent,
  }) {
    if (!enabled) return null;
    if (!OvertoneTheme.of(context).isLight) return null;
    if (!isDesktopView(context)) return null;
    return theme(accent);
  }

  /// 把调用处的皮肤带进弹层 / 对话框。
  ///
  /// 弹层挂在 root navigator 上，它的 Theme 是 App 级那一份，页面级的皮肤包层在它
  /// 下面 —— 不带过去的话弹层里的 TrackTile / 文字会掉回标准调色板，半迁移观感。
  /// [showOvertoneBottomSheet] 是全站唯一漏斗，所以只在它里面调一次。
  ///
  /// [theme] 要在同步阶段抓一份传进来，别把调用处的 BuildContext 递进回调里再用。
  static Widget carry(
    Widget child, {
    required bool active,
    ExperimentalUiSkin skin = ExperimentalUiSkin.off,
    ThemeData? theme,
  }) {
    if (!active) return child;
    return ArchiveSkinActive(
      active: true,
      skin: skin,
      child: Theme(data: theme!, child: child),
    );
  }
}

/// 当前子树是否处在实验性皮肤（如瑞士国际排版、MAGI战术终端等）中。
class ArchiveSkinActive extends InheritedWidget {
  const ArchiveSkinActive({
    super.key,
    required this.active,
    this.skin = ExperimentalUiSkin.off,
    required super.child,
  });

  final bool active;
  final ExperimentalUiSkin skin;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ArchiveSkinActive>()?.active ??
      false;

  static ExperimentalUiSkin skinOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ArchiveSkinActive>()?.skin ??
      ExperimentalUiSkin.off;

  @override
  bool updateShouldNotify(ArchiveSkinActive old) =>
      old.active != active || old.skin != skin;
}
