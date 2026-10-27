/// 「档案终端」播放页皮肤的接线验证。
///
/// 关键口径：皮肤包层必须让**页面自己**的 `OvertoneTheme.of(context)` 拿到新调色板，
/// 而不只是子组件拿到 —— 包层写在页面 build 内部就会踩这个坑。所以断言打在真实
/// 页面的 Scaffold 背景色上，而不是打在一个测试用的 Builder 上。
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:overtone/core/models/track.dart';
import 'package:overtone/core/source/registry.dart';
import 'package:overtone/core/theme/archive_skin.dart';
import 'package:overtone/core/theme/overtone_theme.dart';
import 'package:overtone/core/theme/overtone_tokens.dart';
import 'package:overtone/features/player/archive_player_chrome.dart';
import 'package:overtone/shared/widgets/archive_controls.dart';
import 'package:overtone/features/player/full_player_page.dart';
import 'package:overtone/features/player/player_controller.dart';
import 'package:overtone/shared/widgets/archive_skin_scope.dart';
import 'package:overtone/features/settings/settings_controller.dart';
import 'package:overtone/shared/widgets/cover_box.dart';
import 'package:overtone/shared/widgets/smooth_scroll.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_audio_player.dart';
import 'fakes/fake_music_source.dart';

Track _mockTrack(String id) => Track(
  id: id,
  name: '测试歌曲',
  artist: '测试歌手',
  album: '测试专辑',
  coverUrl: 'mock://$id',
  durationMs: 210000,
);

Future<ProviderContainer> _rig({
  required bool archiveSkin,
  List<Track>? queue,
}) async {
  SharedPreferences.setMockInitialValues({
    'kugo_device_dfid_registered': true,
    'kugo_device_dfid': 'test-dfid',
    'kugo_device_guid': 'test-guid',
    'settings.archiveSkin': archiveSkin,
  });
  musicSourceRegistry = MusicSourceRegistry([ScriptedFmSource()]);
  final container = ProviderContainer(
    overrides: [
      playerControllerProvider.overrideWith(
        () => PlayerController(engine: FakeAudioPlayer()),
      ),
    ],
  );
  addTearDown(container.dispose);
  await container.read(settingsControllerProvider.notifier).ensureRestored();
  await container
      .read(playerControllerProvider.notifier)
      .playQueue(queue ?? [_mockTrack('t1')]);
  // demo 曲目会起周期定时器，同 full_player_cover_zoom_test 一并停掉。
  container.read(playerControllerProvider.notifier).togglePlay();
  return container;
}

/// 把真实播放页泵起来，返回页面自己那一层读到的调色板与 Scaffold 背景色。
///
/// 断言打在**页面的 BuildContext** 上：皮肤包层必须在页面之上，页面内的
/// `OvertoneTheme.of(context)` 才会拿到新调色板（写在页面 build 里就失效）。
Future<({OvertoneTheme theme, Color? scaffoldBg})> _playerAmbience(
  WidgetTester tester, {
  required bool archiveSkin,
  required Brightness brightness,
  Size view = const Size(1600, 1000),
}) async {
  final container = await _rig(archiveSkin: archiveSkin);
  tester.view.physicalSize = view;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: buildOvertoneTheme(Brightness.light),
        darkTheme: buildOvertoneTheme(Brightness.dark),
        themeMode: brightness == Brightness.light
            ? ThemeMode.light
            : ThemeMode.dark,
        home: ArchiveSkinScope(child: const FullPlayerPage()),
      ),
    ),
  );
  await tester.pump();
  final pageContext = tester.element(find.byType(FullPlayerPage));
  return (
    theme: OvertoneTheme.of(pageContext),
    scaffoldBg: tester
        .widget<Scaffold>(find.byType(Scaffold).first)
        .backgroundColor,
  );
}

/// 与 design_tokens_policy_test 同一套 WCAG 算法。
double _lum(Color c) {
  double lin(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);
}

double _contrast(Color a, Color b) {
  final la = _lum(a), lb = _lum(b);
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('archive 调色板过同一套 WCAG 底线（护栏只查 dark/light，这里补齐）', () {
    const p = ArchiveSkin.palette;
    for (final bg in [p.bg, p.surface]) {
      for (final fg in [
        p.textPrimary,
        p.textSecondary,
        p.primary,
        p.danger,
        p.favorite,
      ]) {
        expect(
          _contrast(fg, bg),
          greaterThanOrEqualTo(4.5),
          reason: '${fg.toARGB32()} on ${bg.toARGB32()} 不足 4.5:1',
        );
      }
      expect(
        _contrast(p.textTertiary, bg),
        greaterThanOrEqualTo(3.0),
        reason: 'textTertiary 对比度不足 3:1',
      );
    }
  });

  testWidgets('开关开 + 浅色 + 桌面宽屏：页面读到 archive 调色板', (tester) async {
    final r = await _playerAmbience(
      tester,
      archiveSkin: true,
      brightness: Brightness.light,
    );
    expect(r.theme.bg, ArchiveSkin.palette.bg);
    expect(r.theme.textPrimary, ArchiveSkin.palette.textPrimary);
    // 档案皮肤把 Scaffold 背景设成透明，让发丝网格透出来。
    expect(r.scaffoldBg, Colors.transparent);
  });

  testWidgets('开关关：保持标准浅色', (tester) async {
    final r = await _playerAmbience(
      tester,
      archiveSkin: false,
      brightness: Brightness.light,
    );
    expect(r.theme.bg, OvertonePalette.light.bg);
    expect(r.scaffoldBg, OvertonePalette.light.bg);
  });

  testWidgets('深色外观下仍然生效（swiss 强制浅色）', (tester) async {
    final r = await _playerAmbience(
      tester,
      archiveSkin: true,
      brightness: Brightness.dark,
    );
    expect(r.theme.bg, ArchiveSkin.palette.bg);
    expect(r.scaffoldBg, Colors.transparent);
  });

  testWidgets('手机窄屏下同样生效，并换上皮肤播放件', (tester) async {
    final r = await _playerAmbience(
      tester,
      archiveSkin: true,
      brightness: Brightness.light,
      view: const Size(360, 740),
    );
    expect(r.theme.bg, ArchiveSkin.palette.bg);
    expect(find.byType(ArchiveCardFrame), findsOneWidget);
    expect(find.byType(ArchiveProgressRule), findsOneWidget);
    expect(find.byType(ArchiveControlBar), findsOneWidget);
    expect(find.byType(Slider), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('歌词页在手机窄屏下也套上皮肤进度与控制栏', (tester) async {
    final container = await _rig(archiveSkin: true);
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildOvertoneTheme(Brightness.light),
          home: const ArchiveSkinScope(child: PlayerLyricsPage()),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(ArchiveProgressRule), findsOneWidget);
    expect(find.byType(ArchiveControlBar), findsOneWidget);
    expect(find.byType(Slider), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('档案皮肤换上卡框 / 发丝进度 / 描边控制栏', (tester) async {
    await _playerAmbience(
      tester,
      archiveSkin: true,
      brightness: Brightness.light,
    );
    expect(find.byType(ArchiveCardFrame), findsOneWidget);
    expect(find.byType(ArchiveProgressRule), findsOneWidget);
    expect(find.byType(ArchiveControlBar), findsOneWidget);
    // 进度换成自绘发丝线，Slider 不再出现（标准皮肤那三个仍在使用）
    expect(find.byType(Slider), findsNothing);
  });

  testWidgets('档案卡封面铺满卡片内容宽（默认窗口尺寸下不溢出）', (tester) async {
    await _playerAmbience(
      tester,
      archiveSkin: true,
      brightness: Brightness.light,
      view: const Size(1200, 820),
    );
    final card = tester.getSize(find.byType(ArchiveCardFrame));
    final cover = tester.getSize(find.byType(CoverBox));
    // 卡框左右各 12 padding + 1 边框。
    expect(cover.width, closeTo(card.width - 26, 0.5));
    expect(cover.height, closeTo(cover.width, 0.5));
  });

  testWidgets('收起在没有上一层时回到发现页（/player 冷启动）', (tester) async {
    final container = await _rig(archiveSkin: true);
    tester.view.physicalSize = const Size(1200, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: '/player',
      routes: [
        GoRoute(
          path: '/explore',
          builder: (_, _) => const Scaffold(body: Text('EXPLORE')),
        ),
        GoRoute(
          path: '/player',
          builder: (_, _) => const ArchiveSkinScope(child: FullPlayerPage()),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: buildOvertoneTheme(Brightness.light),
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byTooltip('收起播放页'));
    await tester.pumpAndSettle();
    expect(find.text('EXPLORE'), findsOneWidget);
  });

  testWidgets('长队列弹层填满桌面侧栏（回归：列表下方留白）', (tester) async {
    final container = await _rig(
      archiveSkin: true,
      queue: [for (var i = 0; i < 45; i++) _mockTrack('q$i')],
    );
    tester.view.physicalSize = const Size(1200, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildOvertoneTheme(Brightness.light),
          home: const ArchiveSkinScope(child: FullPlayerPage()),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byTooltip('播放队列'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('播放队列 · 45 首'), findsOneWidget);
    // 旧实现固定 508px（820 × 0.62）；新实现应铺满侧栏剩余高度。
    expect(
      tester.getSize(find.byType(SmoothListViewBuilder)).height,
      greaterThan(650),
    );
  });

  testWidgets('标准皮肤一个像素不受影响', (tester) async {
    await _playerAmbience(
      tester,
      archiveSkin: false,
      brightness: Brightness.light,
    );
    expect(find.byType(ArchiveCardFrame), findsNothing);
    expect(find.byType(ArchiveControlBar), findsNothing);
    expect(find.byType(Slider), findsOneWidget);
  });
}
