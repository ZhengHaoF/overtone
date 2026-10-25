/// 档案皮肤下歌词的「涂黑条逐字退开」验证。
///
/// 标准皮肤那套（已唱 = 主色加粗）由 lyrics_view_test 守着，这里只验分叉：
/// 未唱部分必须变成同宽的底色块，切分点跟着逐字时间轴走，且条色是皮肤墨色。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overtone/core/models/track.dart';
import 'package:overtone/core/theme/archive_skin.dart';
import 'package:overtone/core/theme/overtone_theme.dart';
import 'package:overtone/shared/widgets/lyrics_view.dart';

/// 7 字 × 500ms 的逐字轴。`sungCharCount` 把 `startMs <= 游标` 的字算作已唱，
/// 所以游标 1500 时前 4 字（夜空中最）已经露出来。
const _lines = [
  LyricLine(
    timeMs: 0,
    endMs: 4000,
    text: '夜空中最亮的星',
    chars: [
      LyricChar(text: '夜', startMs: 0, endMs: 500),
      LyricChar(text: '空', startMs: 500, endMs: 1000),
      LyricChar(text: '中', startMs: 1000, endMs: 1500),
      LyricChar(text: '最', startMs: 1500, endMs: 2000),
      LyricChar(text: '亮', startMs: 2000, endMs: 2500),
      LyricChar(text: '的', startMs: 2500, endMs: 3000),
      LyricChar(text: '星', startMs: 3000, endMs: 3500),
    ],
  ),
];

Widget _harness({required bool archive, required int positionMs}) {
  // 必须显式装上主题：没有 OvertoneTheme extension 时它会回落到 dark 调色板，
  // 黑条会被画成白色 —— 第一次跑就踩在这上面，断言看着过其实整条是隐形的。
  final theme = archive
      ? buildOvertoneTheme(Brightness.light, palette: ArchiveSkin.palette)
      : buildOvertoneTheme(Brightness.light);
  return ProviderScope(
    child: MaterialApp(
      theme: theme,
      home: Scaffold(
        body: SizedBox(
          width: 600,
          height: 400,
          child: ArchiveSkinActive(
            active: archive,
            child: LyricsView(
              lines: _lines,
              positionMs: positionMs,
              status: LyricsStatus.ready,
              isPlaying: false,
            ),
          ),
        ),
      ),
    ),
  );
}

/// 递归找出所有「透明字 + 底色块」的 span。活动行的 span 套了两层，
/// 只看 `children` 第一层会一个都找不到。
List<({String text, Color bar})> _redactions(WidgetTester tester) {
  final found = <({String text, Color bar})>[];
  void walk(InlineSpan span) {
    if (span is! TextSpan) return;
    final style = span.style;
    if (style != null &&
        style.color == Colors.transparent &&
        style.backgroundColor != null) {
      found.add((text: span.text ?? '', bar: style.backgroundColor!));
    }
    for (final child in span.children ?? const <InlineSpan>[]) {
      walk(child);
    }
  }

  for (final rich in tester.widgetList<RichText>(find.byType(RichText))) {
    walk(rich.text);
  }
  return found;
}

void main() {
  testWidgets('档案皮肤：未唱部分是涂黑条，条色取皮肤墨色', (tester) async {
    await tester.pumpWidget(_harness(archive: true, positionMs: 1500));
    await tester.pump();

    final redactions = _redactions(tester);
    expect(redactions.map((r) => r.text), ['亮的星']);
    expect(redactions.first.bar, ArchiveSkin.palette.textPrimary);
  });

  testWidgets('档案皮肤：切分点跟着逐字轴走', (tester) async {
    await tester.pumpWidget(_harness(archive: true, positionMs: 2500));
    await tester.pump();
    expect(_redactions(tester).map((r) => r.text), ['星']);

    await tester.pumpWidget(_harness(archive: true, positionMs: 3500));
    await tester.pump();
    expect(_redactions(tester), isEmpty, reason: '走到行尾，黑条应全部退开');
  });

  testWidgets('标准皮肤不走涂黑条，仍是主色填充', (tester) async {
    await tester.pumpWidget(_harness(archive: false, positionMs: 1500));
    await tester.pump();

    expect(_redactions(tester), isEmpty);

    var playedFound = false;
    void walk(InlineSpan span) {
      if (span is! TextSpan) return;
      if (span.text == '夜空中最' &&
          span.style?.fontWeight == FontWeight.w700 &&
          span.style?.color != Colors.transparent) {
        playedFound = true;
      }
      for (final c in span.children ?? const <InlineSpan>[]) {
        walk(c);
      }
    }

    for (final rich in tester.widgetList<RichText>(find.byType(RichText))) {
      walk(rich.text);
    }
    expect(playedFound, isTrue, reason: '老路径的已唱段样式不该被动过');
  });
}
