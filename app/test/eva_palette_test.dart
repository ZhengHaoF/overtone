import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overtone/core/theme/eva_palette.dart';
import 'package:overtone/core/theme/experimental_ui_skin.dart';
import 'package:overtone/core/theme/overtone_tokens.dart';

double _lin(double c) =>
    c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

double _lum(Color c) =>
    0.2126 * _lin(c.r) + 0.7152 * _lin(c.g) + 0.0722 * _lin(c.b);

double _contrast(Color a, Color b) {
  final la = _lum(a), lb = _lum(b);
  final hi = math.max(la, lb), lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('EVA 皮肤枚举：红/蓝同属一个版式家族，旧 wire 值保持兼容', () {
    expect(ExperimentalUiSkin.magi.isEva, isTrue);
    expect(ExperimentalUiSkin.evaBlue.isEva, isTrue);
    expect(ExperimentalUiSkin.swiss.isEva, isFalse);
    expect(ExperimentalUiSkin.off.isEva, isFalse);

    for (final skin in ExperimentalUiSkin.values) {
      expect(ExperimentalUiSkin.fromWire(skin.name), skin);
    }
    expect(ExperimentalUiSkin.fromWire('default'), ExperimentalUiSkin.off);
    expect(ExperimentalUiSkin.fromWire('nope'), ExperimentalUiSkin.off);
  });

  test('调色板按皮肤分派：magi → 贰号机，evaBlue → 零号机', () {
    expect(EvaPalette.forSkin(ExperimentalUiSkin.magi), EvaPalette.unit02);
    expect(EvaPalette.forSkin(ExperimentalUiSkin.evaBlue), EvaPalette.unit00);
    // 非 EVA 皮肤回落到红版，供 isEva 分支误用时仍可渲染。
    expect(EvaPalette.forSkin(ExperimentalUiSkin.off), EvaPalette.unit02);
  });

  test('两套皮肤的版面语言一致，只换底色与强调色', () {
    expect(EvaPalette.unit02.isLight, isFalse);
    expect(EvaPalette.unit00.isLight, isTrue);
    expect(EvaPalette.unit00.unitCode, '00');
    expect(EvaPalette.unit02.unitCode, '02');
    // 角色元素只出现在蓝版：红版保留原 NERV 红徽记，不加水印。
    expect(EvaPalette.unit02.pilotArt, isNull);
    expect(EvaPalette.unit02.emblemTint, isNull);
    expect(EvaPalette.unit00.pilotArt, isNotNull);
    expect(EvaPalette.unit00.emblemTint, isNotNull);
  });

  test('两套皮肤的主文字/强调色在各自底色上可读', () {
    for (final ev in [EvaPalette.unit02, EvaPalette.unit00]) {
      final tag = ev.isLight ? 'unit00' : 'unit02';
      expect(
        _contrast(ev.textPrimary, ev.bgBase),
        greaterThanOrEqualTo(4.5),
        reason: '$tag: 主文字对比度不足 4.5:1',
      );
      expect(
        _contrast(ev.textSecondary, ev.bgBase),
        greaterThanOrEqualTo(3.0),
        reason: '$tag: 次级文字对比度不足 3:1',
      );
      expect(
        _contrast(ev.accent, ev.bgBase),
        greaterThanOrEqualTo(3.0),
        reason: '$tag: 强调色对比度不足 3:1',
      );
      expect(
        _contrast(ev.textOnAccent, ev.accent),
        greaterThanOrEqualTo(3.0),
        reason: '$tag: 强调色填充上的文字对比度不足 3:1',
      );
    }
  });

  test('皮肤主题跟随调色板明暗，且主色即强调色', () {
    for (final ev in [EvaPalette.unit02, EvaPalette.unit00]) {
      final theme = ev.theme(OvertoneAccent.teal);
      expect(theme.brightness, ev.brightness);
      expect(theme.scaffoldBackgroundColor, ev.bgBase);
      expect(theme.colorScheme.primary, ev.accent);
      expect(theme.appBarTheme.shape, isNotNull);
    }
  });
}
