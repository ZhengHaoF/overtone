/// 档案终端外壳 / 发现页组件的接线验证。
///
/// 关键口径：皮肤只包在外壳件与 `/explore` 上，标准皮肤路径必须零变化。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overtone/core/models/fm_mode.dart';
import 'package:overtone/core/models/track.dart';
import 'package:overtone/core/source/registry.dart';
import 'package:overtone/core/theme/archive_skin.dart';
import 'package:overtone/core/theme/overtone_theme.dart';
import 'package:overtone/core/theme/overtone_tokens.dart';
import 'package:overtone/features/explore/explore_page.dart';
import 'package:overtone/features/explore/quick_entries.dart';
import 'package:overtone/features/fm/fm_radio_card.dart';
import 'package:overtone/features/player/player_controller.dart';
import 'package:overtone/features/settings/settings_controller.dart';
import 'package:overtone/shared/shell/desktop_sidebar.dart';
import 'package:overtone/shared/widgets/archive_chrome.dart';
import 'package:overtone/shared/widgets/archive_controls.dart';
import 'package:overtone/shared/widgets/archive_skin_scope.dart';
import 'package:overtone/shared/widgets/common.dart';
import 'package:overtone/shared/widgets/cover_box.dart';
import 'package:overtone/shared/widgets/desktop_player_bar.dart';
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

Future<ProviderContainer> _rig({bool archive = true}) async {
  SharedPreferences.setMockInitialValues({
    'kugo_device_dfid_registered': true,
    'kugo_device_dfid': 'test-dfid',
    'kugo_device_guid': 'test-guid',
    if (archive) 'settings.archiveSkin': true,
  });
  final container = ProviderContainer(
    overrides: [
      playerControllerProvider.overrideWith(
        () => PlayerController(engine: FakeAudioPlayer()),
      ),
    ],
  );
  addTearDown(container.dispose);
  await container.read(settingsControllerProvider.notifier).ensureRestored();
  return container;
}

Widget _host(ProviderContainer container, Widget child) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: buildOvertoneTheme(Brightness.light),
      home: ArchiveSkinScope(child: Scaffold(body: child)),
    ),
  );
}

void _desktop(WidgetTester tester) {
  tester.view.physicalSize = const Size(1600, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('档案侧栏：分组标题降为 10px 字距标签，右缘发丝线', (tester) async {
    _desktop(tester);
    final container = await _rig();
    await tester.pumpWidget(
      _host(
        container,
        Row(
          children: [
            DesktopSidebar(location: '/explore', onNavigate: (_) {}),
            const Expanded(child: ColoredBox(color: Colors.black)),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final theme = OvertoneTheme.of(tester.element(find.byType(DesktopSidebar)));
    expect(theme.bg, ArchiveSkin.palette.bg);

    final group = tester.widget<Text>(find.text('在线音乐'));
    expect(group.style?.fontSize, 10);
    expect(group.style?.letterSpacing, 1.4);

    final outer = tester.widget<AnimatedContainer>(
      find
          .descendant(
            of: find.byType(DesktopSidebar),
            matching: find.byType(AnimatedContainer),
          )
          .first,
    );
    final border = (outer.decoration! as BoxDecoration).border! as Border;
    expect(border.right.color, ArchiveChrome.lineStrong(theme));
  });

  testWidgets('档案分区标题：竖条标签 + 字距 action', (tester) async {
    _desktop(tester);
    final container = await _rig();
    await tester.pumpWidget(
      _host(
        container,
        SectionHeader(title: '排行榜', actionLabel: '全部', onAction: () {}),
      ),
    );
    await tester.pump();

    expect(find.byType(ArchiveSectionLabel), findsOneWidget);
    expect(find.text('全部 →'), findsOneWidget);
  });

  testWidgets('档案歌曲行：方封面 + 三位序号；标准行保持圆角', (tester) async {
    _desktop(tester);
    final container = await _rig();
    await tester.pumpWidget(
      _host(container, TrackTile(track: _mockTrack('t1'), index: 3)),
    );
    await tester.pump();

    expect(find.text('003'), findsOneWidget);
    expect(tester.widget<CoverBox>(find.byType(CoverBox)).radius, 0);

    final standard = await _rig(archive: false);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: standard,
        child: MaterialApp(
          theme: buildOvertoneTheme(Brightness.light),
          home: Scaffold(body: TrackTile(track: _mockTrack('t1'), index: 3)),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('3'), findsOneWidget);
    expect(
      tester.widget<CoverBox>(find.byType(CoverBox)).radius,
      OvertoneRadius.cover,
    );
  });

  testWidgets('档案底栏：发丝进度条取代进度 Slider，封面去圆角、去阴影', (tester) async {
    _desktop(tester);
    final container = await _rig();
    await container.read(playerControllerProvider.notifier).playQueue([
      _mockTrack('t1'),
    ]);
    container.read(playerControllerProvider.notifier).togglePlay();

    await tester.pumpWidget(_host(container, const DesktopPlayerBar()));
    await tester.pump();

    expect(find.byType(ArchiveProgressRule), findsOneWidget);
    // 只剩音量 Slider，进度 Slider 已被发丝线替代。
    expect(find.byType(Slider), findsOneWidget);
    expect(tester.widget<CoverHero>(find.byType(CoverHero)).radius, 0);

    final outer = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(DesktopPlayerBar),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = outer.decoration! as BoxDecoration;
    expect(decoration.boxShadow, isNull);
  });

  testWidgets('档案入口卡与 FM 卡：直角细线、纸面卡身', (tester) async {
    _desktop(tester);
    final container = await _rig();

    await tester.pumpWidget(
      _host(
        container,
        Column(
          children: [
            DiscoveryEntryCard(onTap: () {}),
            RecommendHubEntryCard(onTap: () {}),
          ],
        ),
      ),
    );
    await tester.pump();

    expect(
      tester
          .widget<Material>(find.byKey(const ValueKey('discovery_entry_card')))
          .borderRadius,
      BorderRadius.zero,
    );
    expect(
      tester
          .widget<Material>(
            find.byKey(const ValueKey('recommend_hub_entry_card')),
          )
          .borderRadius,
      BorderRadius.zero,
    );

    final bars = AnimationController(vsync: const TestVSync());
    addTearDown(bars.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildOvertoneTheme(Brightness.light),
          home: ArchiveSkinScope(
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: Builder(
                    builder: (context) {
                      final theme = OvertoneTheme.of(context);
                      return FmRadioCard(
                        theme: theme,
                        accent: theme.primary,
                        mode: FmMode.heart,
                        pool: FmSongPool.taste,
                        onMode: (_) {},
                        onPlay: () {},
                        onDislike: () {},
                        onLike: () {},
                        isPlaying: false,
                        bars: bars,
                        trackName: '',
                        artist: '',
                        stationTitle: '私人 FM',
                        stationSubtitle: '猜你喜欢 · Alpha',
                        showModeAxis: false,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final card = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(FmRadioCard),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = card.decoration! as BoxDecoration;
    final theme = OvertoneTheme.of(tester.element(find.byType(FmRadioCard)));
    expect(decoration.color, theme.surface);
    expect(decoration.boxShadow, isNull);
    expect(
      (decoration.border! as Border).top.color,
      ArchiveChrome.lineStrong(theme),
    );
  });

  testWidgets('档案发现页：网格背景铺在内容下方', (tester) async {
    _desktop(tester);
    final container = await _rig();
    musicSourceRegistry = MusicSourceRegistry([ScriptedFmSource()]);
    addTearDown(() => musicSourceRegistry = null);

    await tester.pumpWidget(_host(container, const ExplorePage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(ArchiveGridBackdrop), findsOneWidget);
    expect(find.byType(ArchiveKicker), findsOneWidget);

    final paint = tester.widget<CustomPaint>(
      find
          .descendant(
            of: find.byType(ArchiveGridBackdrop),
            matching: find.byType(CustomPaint),
          )
          .first,
    );
    expect(paint.painter, isA<ArchiveGridPainter>());
  });
}
