import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 四语词典的一致性护栏。
///
/// 逐页断言英文/日文不现实，所以在词典层保证：
/// 1. 四种语言的键集完全一致（gen-l10n 的 untranslated.json 也必须为空）；
/// 2. 同一条消息的占位符集合一致（否则运行时参数错位）;
/// 3. 英/日/韩没有漏翻的中文（品牌词与 MAGI 数字白名单除外）。
void main() {
  final dir = Directory('lib/l10n');
  Map<String, dynamic> load(String locale) {
    final file = File('${dir.path}/app_$locale.arb');
    final raw = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    return {
      for (final e in raw.entries)
        if (!e.key.startsWith('@')) e.key: e.value as String,
    };
  }

  final zh = load('zh');
  final locales = {for (final l in ['en', 'ja', 'ko']) l: load(l)};

  test('四种语言键集一致，且没有待翻译项', () {
    expect(zh, isNotEmpty);
    for (final entry in locales.entries) {
      expect(
        entry.value.keys.toSet(),
        zh.keys.toSet(),
        reason: '${entry.key} 的键集与中文模板不一致',
      );
    }
    final untranslated =
        File('${dir.path}/untranslated.json').readAsStringSync().trim();
    expect(untranslated, '{}', reason: '还有未翻译的键');
  });

  test('占位符集合一致', () {
    final placeholder = RegExp(r'\{(\w+)\}');
    Set<String> names(String message) =>
        placeholder.allMatches(message).map((m) => m.group(1)!).toSet();
    for (final entry in locales.entries) {
      for (final key in zh.keys) {
        expect(
          names(entry.value[key]!),
          names(zh[key]!),
          reason: '${entry.key}.$key 的占位符与中文模板不一致',
        );
      }
    }
  });

  test('英/韩不残留未翻译中文（日文允许汉字）', () {
    // 品牌名（泛音）、MAGI 的日式数字与章节符号属于设计标识，保留原文。
    const allowed = {
      '泛音',
      '壱',
      '弐',
      '参',
      '肆',
      '伍',
      '陆',
      '柒',
      '捌',
      '玖',
      '零',
      '拾',
    };
    final cjk = RegExp(r'[\u3400-\u9fff]');
    // 日文正常使用汉字，不能按 CJK 判漏翻；ja 由键集 + 占位符 + 人工复核保证。
    for (final entry in locales.entries.where((e) => e.key != 'ja')) {
      for (final message in entry.value.entries) {
        final text = allowed.contains(message.value)
            ? ''
            : message.value.replaceAll(RegExp(allowed.join('|')), '');
        expect(
          cjk.hasMatch(text),
          isFalse,
          reason: '${entry.key}.${message.key} 仍是中文：${message.value}',
        );
      }
    }
  });
}
