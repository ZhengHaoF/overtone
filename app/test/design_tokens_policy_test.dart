import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overtone/core/theme/overtone_theme.dart';
import 'package:overtone/core/theme/overtone_tokens.dart';

/// 设计 token 的防回归护栏。
///
/// 这一轮把「蓝紫双主色 + 胶囊 + 装饰渐变」收敛成单主色体系后，靠测试守住：
/// 谁再往 UI 里写死品牌色或把圆角调回大圆角，`flutter test` 会直接红。
void main() {
  final themeDir = 'lib/core/theme/';
  final uiSources = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.replaceAll(r'\', '/').contains(themeDir))
      .map((f) => (path: f.path, text: f.readAsStringSync()))
      .toList();

  test('UI 不再写死危险色 / 旧强调色', () {
    const banned = ['Colors.redAccent', 'Colors.orangeAccent'];
    for (final source in uiSources) {
      for (final token in banned) {
        expect(
          source.text.contains(token),
          isFalse,
          reason: '${source.path} 用了 $token，请改用 OvertoneTheme.danger',
        );
      }
    }
  });

  test('单主色体系：不再有第二个强调色入口', () {
    for (final source in uiSources) {
      expect(
        source.text.contains('theme.secondary'),
        isFalse,
        reason: '${source.path} 读取了已移除的 secondary，请用 primary / 中性色',
      );
      expect(
        source.text.contains('palette.secondary'),
        isFalse,
        reason: '${source.path} 读取了已移除的 palette.secondary',
      );
    }
  });

  test('圆角 token 保持在收紧后的档位', () {
    expect(OvertoneRadius.chip, 999);
    expect(OvertoneRadius.card, lessThanOrEqualTo(12));
    expect(OvertoneRadius.tile, lessThanOrEqualTo(10));
    expect(OvertoneRadius.button, lessThanOrEqualTo(10));
    expect(OvertoneRadius.tag, lessThanOrEqualTo(8));
    expect(OvertoneRadius.cover, lessThanOrEqualTo(12));
  });

  test('danger / favorite / primary 是三个互不相同的语义色', () {
    for (final palette in [OvertonePalette.dark, OvertonePalette.light]) {
      expect(palette.danger, isNot(palette.favorite));
      expect(palette.danger, isNot(palette.primary));
      expect(palette.favorite, isNot(palette.primary));
    }
  });

  test('ColorScheme.error 接到 danger token', () {
    for (final brightness in Brightness.values) {
      final theme = buildOvertoneTheme(brightness);
      expect(theme.colorScheme.error, overtonePaletteFor(brightness).danger);
    }
  });

  test('装饰性双色渐变 helper 不再回归', () {
    final tokens = File(
      '${themeDir}overtone_tokens.dart',
    ).readAsStringSync();
    expect(tokens.contains('accentGradient'), isFalse);
    expect(tokens.contains('playerGradient'), isFalse);
  });

  test('Hero tag 字面量只允许出现在 OvertoneHeroTags', () {
    const namespaces = [
      "'player-cover-",
      "'rank-cover-",
      "'album-cover-",
      "'artist-avatar-",
      "'song-cover-",
    ];
    for (final source in uiSources) {
      for (final namespace in namespaces) {
        expect(
          source.text.contains(namespace),
          isFalse,
          reason: '${source.path} 手写了 Hero tag $namespace，请改用 OvertoneHeroTags',
        );
      }
    }
  });

  test('字号阶梯只有五档（ad-hoc fontSize 必须是 10/12/15/18/22）', () {
    expect(
      [
        OvertoneFontSize.micro,
        OvertoneFontSize.caption,
        OvertoneFontSize.body,
        OvertoneFontSize.section,
        OvertoneFontSize.title,
      ],
      [10, 12, 15, 18, 22],
    );

    const allowed = {'10', '12', '15', '18', '22'};
    final literal = RegExp(r'fontSize: (\d+)');
    for (final source in uiSources) {
      for (final match in literal.allMatches(source.text)) {
        expect(
          allowed.contains(match.group(1)),
          isTrue,
          reason:
              '${source.path} 用了阶梯外字号 ${match.group(1)}，'
              '请就近归到 10/12/15/18/22',
        );
      }
    }
  });

  test('圆角字面量只允许描边级细节（≤4）', () {
    final literal =
        RegExp(r'BorderRadius\.circular\((\d+(?:\.\d+)?)\)');
    for (final source in uiSources) {
      if (source.path
          .replaceAll(r'\', '/')
          .contains('desktop_lyric/spike/')) {
        continue;
      }
      for (final match in literal.allMatches(source.text)) {
        final value = double.parse(match.group(1)!);
        expect(
          value <= 4,
          isTrue,
          reason:
              '${source.path} 用了 ${match.group(1)} 圆角，'
              '请改用 OvertoneRadius（button/card/tile/tag/small）',
        );
      }
    }
  });

  test('调色板满足 WCAG 对比度底线', () {
    double lin(double c) =>
        c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
    double lum(Color c) =>
        0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);
    double contrast(Color a, Color b) {
      final la = lum(a), lb = lum(b);
      final hi = math.max(la, lb), lo = math.min(la, lb);
      return (hi + 0.05) / (lo + 0.05);
    }

    for (final p in [OvertonePalette.dark, OvertonePalette.light]) {
      final label = p.isLight ? 'light' : 'dark';
      for (final bg in [p.bg, p.surface]) {
        for (final fg in [p.textPrimary, p.textSecondary, p.primary, p.danger, p.favorite]) {
          expect(
            contrast(fg, bg),
            greaterThanOrEqualTo(4.5),
            reason: '$label: 前景/背景对比度不足 4.5:1',
          );
        }
        // 三级文字用于提示 / 禁用态，按 UI 组件级别 3:1 要求。
        expect(
          contrast(p.textTertiary, bg),
          greaterThanOrEqualTo(3.0),
          reason: '$label: textTertiary 对比度不足 3:1',
        );
      }
      // 强调色填充上的白字（按钮 / 徽标），按 UI 组件级别 3:1。
      for (final fill in [p.primary, p.favorite, p.danger]) {
        expect(
          contrast(Colors.white, fill),
          greaterThanOrEqualTo(3.0),
          reason: '$label: 强调色上的白字对比度不足 3:1',
        );
      }
    }
  });

  test('图标尺寸只在六档阶梯内（14/16/20/24/32/48）', () {
    const ladder = {14, 16, 20, 24, 32, 48};
    final sizePattern = RegExp(r'size:\s*(\d+)');

    for (final source in uiSources) {
      if (source.path
          .replaceAll(r'', '/')
          .contains('desktop_lyric/spike/')) {
        continue;
      }
      final text = source.text;
      var cursor = 0;
      while (true) {
        final start = text.indexOf('Icon(', cursor);
        if (start < 0) break;
        // 括号配平，拿到整段 Icon(...) 调用（参数里有嵌套括号也能覆盖）。
        var depth = 0;
        var end = start + 4;
        while (end < text.length) {
          final ch = text[end];
          if (ch == '(') {
            depth++;
          } else if (ch == ')') {
            depth--;
            if (depth == 0) break;
          }
          end++;
        }
        final call = text.substring(start, end);
        for (final match in sizePattern.allMatches(call)) {
          final value = int.parse(match.group(1)!);
          expect(
            ladder.contains(value),
            isTrue,
            reason: '${source.path} 的 Icon size $value 不在 14/16/20/24/32/48 内',
          );
        }
        cursor = end;
      }
    }
  });

  test('每个主题色 × 浅/深都满足对比度与语义色可区分度', () {
    double lin(double c) =>
        c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
    double lum(Color c) =>
        0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);
    double contrast(Color a, Color b) {
      final la = lum(a), lb = lum(b);
      final hi = math.max(la, lb), lo = math.min(la, lb);
      return (hi + 0.05) / (lo + 0.05);
    }

    // sRGB → CIELAB（D65），只用来算 ΔE76 判断「和语义色像不像」。
    List<double> labOf(Color c) {
      final r = lin(c.r), g = lin(c.g), b = lin(c.b);
      final x = r * 0.4124 + g * 0.3576 + b * 0.1805;
      final y = r * 0.2126 + g * 0.7152 + b * 0.0722;
      final z = r * 0.0193 + g * 0.1192 + b * 0.9505;
      double f(double t) =>
          t > 0.008856 ? math.pow(t, 1 / 3).toDouble() : 7.787 * t + 16 / 116;
      final fx = f(x / 0.95047), fy = f(y / 1.0), fz = f(z / 1.08883);
      return [116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz)];
    }

    double deltaE(Color a, Color b) {
      final la = labOf(a), lb = labOf(b);
      return math.sqrt(
        math.pow(la[0] - lb[0], 2) +
            math.pow(la[1] - lb[1], 2) +
            math.pow(la[2] - lb[2], 2),
      );
    }

    expect(OvertoneAccent.values.first, OvertoneAccent.teal,
        reason: '默认主题色必须是 logo 青绿');

    for (final accent in OvertoneAccent.values) {
      for (final brightness in Brightness.values) {
        final p = overtonePaletteFor(brightness, accent: accent);
        final tag = '${accent.name}/${brightness.name}';
        for (final bg in [p.bg, p.surface]) {
          expect(
            contrast(p.primary, bg),
            greaterThanOrEqualTo(4.5),
            reason: '$tag: 主色在底色/卡面上对比度不足 4.5:1',
          );
        }
        expect(
          contrast(Colors.white, p.primary),
          greaterThanOrEqualTo(3.0),
          reason: '$tag: 主色填充上的白字对比度不足 3:1',
        );
        // 换主题色不能让人把「强调」误读成「危险 / 喜欢 / 会员」。
        for (final entry in {
          'danger': p.danger,
          'favorite': p.favorite,
          'tvip': OvertoneBrandColor.tvip,
          'svip': OvertoneBrandColor.svip,
        }.entries) {
          expect(
            deltaE(p.primary, entry.value),
            greaterThanOrEqualTo(20),
            reason: '$tag: 主色与 ${entry.key} 的 ΔE 太小，语义会混淆',
          );
        }
      }
    }
  });
}
