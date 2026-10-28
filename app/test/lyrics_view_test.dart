import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overtone/core/models/track.dart';
import 'package:overtone/features/settings/settings_controller.dart';
import 'package:overtone/shared/widgets/lyrics_view.dart';

List<LyricLine> _sample() => const [
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
        translated: 'The brightest star in the night sky',
        romanized: 'ye kong zhong zui liang de xing',
      ),
    ];

/// 无逐字时间轴的普通歌词：便于直接断言 Text.style（卡拉 OK 行的样式在 span 上）。
List<LyricLine> _plainLines() => const [
      LyricLine(timeMs: 0, endMs: 1000, text: '第一行'),
      LyricLine(timeMs: 1000, endMs: 2000, text: '第二行'),
    ];

Widget _harness({
  required bool translation,
  required bool romanization,
  required int positionMs,
  List<LyricLine>? lines,
  double fontScale = 1,
  double spacingScale = 1,
  bool isPlaying = false,
}) {
  return ProviderScope(
    overrides: [
      settingsControllerProvider.overrideWith(
        () => _FixedSettings(
          AppSettings(
            lyricTranslation: translation,
            lyricRomanization: romanization,
            lyricFontScale: fontScale,
            lyricSpacingScale: spacingScale,
          ),
        ),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: LyricsView(
          lines: lines ?? _sample(),
          positionMs: positionMs,
          isPlaying: isPlaying,
        ),
      ),
    ),
  );
}

/// 行盒高度 = 本曲文字实际高度 × 行距倍率（见 `lyrics_view._minExtent`）。
///
/// 换行后行高不再固定（ListView 无 `itemExtent`），改为读行级
/// `ConstrainedBox` 的 `minHeight`——即单行行盒的兜底高度。
double _rowExtent(WidgetTester tester, [String text = '第一行']) {
  final box = tester.widget<ConstrainedBox>(
    find
        .ancestor(
          of: find.text(text),
          matching: find.byType(ConstrainedBox),
        )
        .first,
  );
  return box.constraints.minHeight;
}

/// 窄屏（宽 < 800 即 `isDesktopView` 为假），主行字号基准为 18/15 而非 22/16。
/// 测试默认画布 800×600 会被判成桌面，故字号断言前先切到手机尺寸。
void _usePhoneView(WidgetTester tester) {
  tester.view.physicalSize = const Size(420, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

class _FixedSettings extends SettingsController {
  _FixedSettings(this._initial);
  final AppSettings _initial;

  @override
  AppSettings build() => _initial;
}

/// 活动行 Text.rich 的三段 span：[已唱完, 正在唱, 未唱]。
List<TextSpan> _karaokeSpans(WidgetTester tester) {
  final rich = tester
      .widgetList<Text>(find.byType(Text))
      .firstWhere((t) => t.textSpan != null);
  return (rich.textSpan! as TextSpan).children!.cast<TextSpan>().toList();
}

void main() {
  testWidgets('shows translation and romanization when both enabled',
      (tester) async {
    await tester.pumpWidget(
      _harness(translation: true, romanization: true, positionMs: 0),
    );
    expect(find.text('夜空中最亮的星'), findsOneWidget);
    expect(find.text('The brightest star in the night sky'), findsOneWidget);
    expect(find.text('ye kong zhong zui liang de xing'), findsOneWidget);
  });

  testWidgets('hides secondary lines when toggles are off', (tester) async {
    await tester.pumpWidget(
      _harness(translation: false, romanization: false, positionMs: 0),
    );
    expect(find.text('夜空中最亮的星'), findsOneWidget);
    expect(find.text('The brightest star in the night sky'), findsNothing);
    expect(find.text('ye kong zhong zui liang de xing'), findsNothing);
  });

  testWidgets('shows only translation when romanization is off',
      (tester) async {
    await tester.pumpWidget(
      _harness(translation: true, romanization: false, positionMs: 0),
    );
    expect(find.text('The brightest star in the night sky'), findsOneWidget);
    expect(find.text('ye kong zhong zui liang de xing'), findsNothing);
  });

  testWidgets('translation stays about three quarters of the active line',
      (tester) async {
    // 桌面默认画布 800 宽 → 主行 22 / 译文 16；手机 18 / 14。
    await tester.pumpWidget(
      _harness(translation: true, romanization: false, positionMs: 0),
    );
    expect(
      tester
          .widget<Text>(find.text('The brightest star in the night sky'))
          .style
          ?.fontSize,
      closeTo(16, 0.001),
    );

    _usePhoneView(tester);
    await tester.pumpWidget(
      _harness(translation: true, romanization: false, positionMs: 0),
    );
    expect(
      tester
          .widget<Text>(find.text('The brightest star in the night sky'))
          .style
          ?.fontSize,
      closeTo(14, 0.001),
    );
  });

  testWidgets('karaoke interpolates inside the current character',
      (tester) async {
    await tester.pumpWidget(
      // 中(1000–1500) 唱到 1200 → 字内 40%。
      _harness(translation: false, romanization: false, positionMs: 1200),
    );
    final spans = _karaokeSpans(tester);
    expect(spans.map((s) => s.text).join(), '夜空中最亮的星');
    expect(spans[0].text, '夜空'); // 已唱完
    expect(spans[1].text, '中'); // 正在唱
    expect(spans[2].text, '最亮的星'); // 未唱

    final played = spans[0].style!.color!;
    final base = spans[2].style!.color!;
    final mid = spans[1].style!.color!;
    // 当前字不是整字跳色：它是两端颜色的字内插值。
    expect(mid, isNot(played));
    expect(mid, isNot(base));
    expect(mid, Color.lerp(base, played, 0.4));
  });

  testWidgets('active line ticker survives play/pause/play without build errors',
      (tester) async {
    // 回归：SingleTickerProviderStateMixin 下 dispose 后再 createTicker 会断言失败，
    // 使活动行 build 抛错 —— 歌词区随之无法重建/滚动（表现为「滚动不了」）。
    Future<void> pump(bool playing) async {
      await tester.pumpWidget(
        _harness(
          translation: false,
          romanization: false,
          positionMs: 1200,
          isPlaying: playing,
        ),
      );
      await tester.pump();
    }

    await pump(true); // 首次 createTicker
    await pump(false); // 暂停
    await pump(true); // 再次播放：旧实现会第二次 createTicker → 断言
    await pump(false); // 收尾：停掉 ticker，避免测试结束时仍有活跃 ticker

    expect(tester.takeException(), isNull);
  });

  testWidgets('sweep does not count the pause gap when resuming',
      (tester) async {
    // 回归：锚点必须基于 Ticker 帧计时。用墙上时钟时，暂停期间流逝的时间会被
    // 算进扫光，恢复播放瞬间扫光直接冲到整行（表现为「逐字滚动失效/跳到某句」）。
    Future<void> pump({required bool playing}) async {
      await tester.pumpWidget(
        _harness(
          translation: false,
          romanization: false,
          positionMs: 1000, // 中(1000) 刚开始唱
          isPlaying: playing,
        ),
      );
    }

    await pump(playing: true);
    await tester.pump(const Duration(milliseconds: 100));
    expect(_karaokeSpans(tester)[0].text, '夜空');
    // 播放中：当前字正在字内插值。
    expect(
      _karaokeSpans(tester)[1].style!.color,
      isNot(_karaokeSpans(tester)[2].style!.color),
    );

    // 暂停 30 秒：扫光退回离散快照，且停在原位不动。
    await pump(playing: false);
    await tester.pump(const Duration(seconds: 30));
    expect(_karaokeSpans(tester)[0].text, '夜空');
    expect(
      _karaokeSpans(tester)[1].style!.color,
      _karaokeSpans(tester)[2].style!.color,
    );

    // 恢复播放，位置仍是 1000（引擎尚未发新样本）：不得把暂停的 30s 算进去，
    // 前缀仍停在「夜空」而不是冲到行尾。
    await pump(playing: true);
    await tester.pump(const Duration(milliseconds: 50));
    expect(_karaokeSpans(tester)[0].text, '夜空');
    expect(_karaokeSpans(tester)[2].text, '最亮的星');
    expect(
      _karaokeSpans(tester)[1].style!.color,
      isNot(_karaokeSpans(tester)[2].style!.color),
    );

    // 收尾：停 ticker，避免测试结束时仍有活跃 ticker。
    await pump(playing: false);
    await tester.pump();
  });

  testWidgets('at 100% spacing the row box hugs the text height',
      (tester) async {
    _usePhoneView(tester);
    await tester.pumpWidget(
      _harness(
        translation: false,
        romanization: false,
        positionMs: 0,
        lines: _plainLines(),
      ),
    );
    expect(
      tester.widget<Text>(find.text('第一行')).style?.fontSize,
      closeTo(18, 0.001),
    );
    // 单行 18 × 1.35 = 24.3；100% 不再有 56 的空基准。
    expect(_rowExtent(tester), closeTo(24.3, 0.001));
  });

  testWidgets('font scale enlarges lyric font size', (tester) async {
    _usePhoneView(tester);
    await tester.pumpWidget(
      _harness(
        translation: false,
        romanization: false,
        positionMs: 0,
        lines: _plainLines(),
        fontScale: 1.5,
      ),
    );
    // 活动行 18 → 27；非活动行 15 → 22.5。
    expect(
      tester.widget<Text>(find.text('第一行')).style?.fontSize,
      closeTo(27, 0.001),
    );
    expect(
      tester.widget<Text>(find.text('第二行')).style?.fontSize,
      closeTo(22.5, 0.001),
    );
  });

  testWidgets('font scale grows the row extent so text is not clipped',
      (tester) async {
    _usePhoneView(tester);
    await tester.pumpWidget(
      _harness(
        translation: false,
        romanization: false,
        positionMs: 0,
        lines: _plainLines(),
        fontScale: 1.5,
      ),
    );
    expect(_rowExtent(tester), closeTo(24.3 * 1.5, 0.001));
  });

  testWidgets('line spacing scale grows the row extent', (tester) async {
    _usePhoneView(tester);
    await tester.pumpWidget(
      _harness(
        translation: false,
        romanization: false,
        positionMs: 0,
        lines: _plainLines(),
        spacingScale: kLyricSpacingScaleMax,
      ),
    );
    expect(_rowExtent(tester), closeTo(24.3 * kLyricSpacingScaleMax, 0.001));
  });

  testWidgets('secondary height is reserved only when the song has one',
      (tester) async {
    _usePhoneView(tester);
    // 「显示翻译」开着，但这首歌没有译文：不得凭空多出副行高度。
    await tester.pumpWidget(
      _harness(
        translation: true,
        romanization: false,
        positionMs: 0,
        lines: _plainLines(),
      ),
    );
    expect(_rowExtent(tester), closeTo(24.3, 0.001));

    // 本曲确有译文 → 18×1.35 + 14×1.25 = 41.8。
    await tester.pumpWidget(
      _harness(
        translation: true,
        romanization: false,
        positionMs: 0,
        lines: _sample(),
      ),
    );
    expect(_rowExtent(tester, '夜空中最亮的星'), closeTo(41.8, 0.001));
  });

  testWidgets('long lines wrap instead of showing an ellipsis', (tester) async {
    _usePhoneView(tester);
    // 420px 宽的屏幕放不下一行的长度（约 26 × 18px），必须换行而非截断。
    const longText = '这是一句特别特别特别特别特别特别特别特别特别长的歌词';
    const longTr = 'a very very very very very very very long translation';
    final lines = [
      const LyricLine(timeMs: 0, endMs: 1000, text: longText, translated: longTr),
      const LyricLine(timeMs: 1000, endMs: 2000, text: '短行'),
    ];
    await tester.pumpWidget(
      _harness(
        translation: true,
        romanization: false,
        positionMs: 0,
        lines: lines,
      ),
    );

    // 活动行主歌词：不设 maxLines，且渲染高度超过单行（18 × 1.35 = 24.3）。
    final primary = tester.widget<Text>(find.text(longText));
    expect(primary.maxLines, isNull);
    expect(primary.overflow, isNot(TextOverflow.ellipsis));
    expect(tester.getSize(find.text(longText)).height, greaterThan(24.3));

    // 副行译文：同样换行。
    final tr = tester.widget<Text>(find.text(longTr));
    expect(tr.maxLines, isNull);
    expect(tr.overflow, isNot(TextOverflow.ellipsis));
  });

  testWidgets('char-timed long lines still wrap at phone width',
      (tester) async {
    _usePhoneView(tester);
    // 逐字渲染是「按字符切三段」而不是整行布局，长句必须照旧换行。
    const longText = '这是一句特别特别特别特别特别特别特别特别特别长的歌词';
    final lines = [
      LyricLine(
        timeMs: 0,
        endMs: longText.length * 200,
        text: longText,
        chars: [
          for (var i = 0; i < longText.length; i++)
            LyricChar(
              text: longText[i],
              startMs: i * 200,
              endMs: (i + 1) * 200,
            ),
        ],
      ),
      const LyricLine(timeMs: 99999, endMs: 100000, text: '短行'),
    ];
    await tester.pumpWidget(
      _harness(
        translation: false,
        romanization: false,
        positionMs: 1000,
        lines: lines,
      ),
    );

    final spans = _karaokeSpans(tester);
    expect(spans.map((s) => s.text).join(), longText);
    expect(spans[0].text, longText.substring(0, 5)); // 1000ms 已唱完 5 字
    expect(tester.getSize(find.text(longText)).height, greaterThan(24.3));
  });

  testWidgets('active line is vertically centered after auto-scroll',
      (tester) async {
    // 回归：换行后行高不再固定，居中不能再按 index × 行高 推算；
    // 800×600 桌面画布下视口高 600，活动行（第二行）应居中于 y = 300。
    await tester.pumpWidget(
      _harness(
        translation: false,
        romanization: false,
        positionMs: 1500,
        lines: _plainLines(),
      ),
    );
    // jumpTo 发生在首帧的 post-frame 回调里，补一帧让滚动位置绘制出来。
    await tester.pump();
    expect(tester.getCenter(find.text('第二行')).dy, closeTo(300, 1.0));
  });
}
