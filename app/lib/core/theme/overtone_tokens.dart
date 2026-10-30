import 'package:flutter/material.dart';
import 'package:overtone/l10n/l10n.dart';

/// Resolved color tokens for the active theme (dark / light).
///
/// Read through [OvertoneTheme.of] — never from a global, so widgets that use
/// these colors always rebuild when the theme flips.
class OvertonePalette {
  const OvertonePalette({
    required this.brightness,
    required this.bg,
    required this.surface,
    required this.surfaceElevated,
    required this.primary,
    required this.favorite,
    required this.danger,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.divider,
    required this.overlay,
  });

  final Brightness brightness;
  final Color bg;
  final Color surface;
  final Color surfaceElevated;
  final Color primary;

  /// 红心 /「我喜欢」专用色（玫粉，与珊瑚主色拉开色相）。
  final Color favorite;

  /// 危险操作（退出登录、清空、删除）。深浅色分别给值，保证在各自底色上可读。
  final Color danger;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color divider;
  final Color overlay;

  bool get isLight => brightness == Brightness.light;

  /// 换一个强调色，其余 token 不变。强调色只有 primary 会变，
  /// danger/favorite/品牌色保持固定——换肤不该改变语义。
  OvertonePalette withAccent(OvertoneAccent accent) {
    final next = accent.primaryFor(brightness);
    if (next == primary) return this;
    return OvertonePalette(
      brightness: brightness,
      bg: bg,
      surface: surface,
      surfaceElevated: surfaceElevated,
      primary: next,
      favorite: favorite,
      danger: danger,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      textTertiary: textTertiary,
      divider: divider,
      overlay: overlay,
    );
  }

  static const dark = OvertonePalette(
    brightness: Brightness.dark,
    bg: Color(0xFF0B0E14),
    surface: Color(0xFF151A24),
    surfaceElevated: Color(0xFF1C2230),
    primary: Color(0xFF029C94),
    favorite: Color(0xFFFF4D88),
    danger: Color(0xFFFF5C63),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF9AA3B2),
    textTertiary: Color(0xFF7E8898),
    divider: Color(0x14FFFFFF),
    overlay: Color(0x66000000),
  );

  static const light = OvertonePalette(
    brightness: Brightness.light,
    bg: Color(0xFFF2F4F8),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFFFFFFF),
    primary: Color(0xFF01756F),
    favorite: Color(0xFFCE2F63),
    danger: Color(0xFFC42E36),
    textPrimary: Color(0xFF12141A),
    textSecondary: Color(0xFF5B6472),
    textTertiary: Color(0xFF66707F),
    divider: Color(0x1A000000),
    overlay: Color(0x22000000),
  );
}

abstract final class OvertoneRadius {
  /// 筛选 chip：全站唯一保留胶囊的形状。
  static const chip = 999.0;

  /// 按钮 / 输入框 / 搜索框。
  static const button = 10.0;

  static const card = 12.0;
  static const tile = 10.0;

  /// 角标 / 小标签（画质、地区、状态）。
  static const tag = 8.0;

  /// 小容器 / 图标底：再小一档的内嵌面。
  static const small = 6.0;

  static const cover = 10.0;
}

/// 品牌固定色：会员档位与榜单名次。这些颜色表达「身份 / 名次」，
/// 不随主题翻转，也不参与主色体系。
abstract final class OvertoneBrandColor {
  /// 畅听会员 / 音乐包（绿）。
  static const tvip = Color(0xFF07C160);

  /// 概念会员 / 黑胶 VIP（琥珀）。
  static const svip = Color(0xFFF59E0B);

  static const rankGold = Color(0xFFFFB300);
  static const rankSilver = Color(0xFF9E9E9E);
  static const rankBronze = Color(0xFFB87333);
}

/// 字号阶梯：全站只允许这五档（外加 `display` 用于页头问候语）。
///
/// 收敛前有 16 档散落字号（9–30），层级靠「差 1px」堆出来；现在 ad-hoc 字号
/// 一律就近归到这五档，`design_tokens_policy_test` 会拦住新的野值。
abstract final class OvertoneFontSize {
  /// 徽标 / 时间 / 角标。
  static const micro = 10.0;

  /// 说明文字（theme.caption）。
  static const caption = 12.0;

  /// 正文（theme.body）。
  static const body = 15.0;

  /// 小标题 / 区块标题（theme.section）。
  static const section = 18.0;

  /// 页面标题 / 曲名（theme.title）。
  static const title = 22.0;

  /// 页头问候语等展示型文字，不进正文层级。
  static const display = 28.0;
}

abstract final class OvertoneSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

/// 可选主题色。每个色只有两档值（浅色 / 深色各一），都必须满足
/// `design_tokens_policy_test` 里的对比度与语义色可区分度要求。
enum OvertoneAccent {
  /// 默认色：取自应用图标。
  teal(Color(0xFF01756F), Color(0xFF029C94)),
  coral(Color(0xFFBF4A12), Color(0xFFEC5F2A)),
  indigo(Color(0xFF2448B8), Color(0xFF5183F0)),
  violet(Color(0xFF6D28D9), Color(0xFF9A73F9));

  const OvertoneAccent(this.light, this.dark);

  String get label => switch (this) {
        teal => l10n.qingLv,
        coral => l10n.shanHu,
        indigo => l10n.dianLan,
        violet => l10n.ziLuoLan,
      };
  final Color light;
  final Color dark;

  Color primaryFor(Brightness brightness) =>
      brightness == Brightness.light ? light : dark;
}
