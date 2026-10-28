import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overtone/core/models/track.dart';
import 'package:overtone/core/source/registry.dart';
import 'package:overtone/core/theme/magi_skin.dart';
import 'package:overtone/core/theme/overtone_theme.dart';
import 'package:overtone/features/player/full_player_page.dart';
import 'package:overtone/features/player/player_controller.dart';
import 'package:overtone/features/settings/settings_controller.dart';
import 'package:overtone/shared/widgets/archive_skin_scope.dart';
import 'package:overtone/shared/widgets/magi_chrome.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_audio_player.dart';
import 'fakes/fake_music_source.dart';

Track _mockTrack(String id) => Track(
  id: id,
  name: '残酷な天使のテーゼ',
  artist: '高桥洋子',
  album: 'NEON GENESIS EVANGELION',
  coverUrl: 'mock://$id',
  durationMs: 245000,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('MAGI 战术终端皮肤：全屏播放页渲染 EVA 超算战术界面', (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings.experimentalUi': 'magi',
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
        .playQueue([_mockTrack('eva-01')]);
    // 暂停 demo 轮询定时器
    container.read(playerControllerProvider.notifier).togglePlay();

    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildOvertoneTheme(Brightness.dark),
          home: const ArchiveSkinScope(child: FullPlayerPage()),
        ),
      ),
    );
    await tester.pump();

    // 1. 验证顶部导航战术组件
    expect(find.text('MAGI SYSTEM // 01'), findsOneWidget);
    expect(find.text('[ ESC ]'), findsOneWidget);
    expect(find.text('[ SPEC ]'), findsOneWidget);
    expect(find.text('[ QUEUE ]'), findsOneWidget);

    // 2. 验证目标锁定框
    expect(find.byType(MagiTargetFrame), findsOneWidget);
    expect(find.text('35.39°N / 139.44°E'), findsOneWidget);

    // 3. 验证战术曲目排版与 MAGI 三贤者
    expect(find.text('/// PRIORITY: LEVEL-AAA // SYNC: 100% ///'), findsOneWidget);
    expect(find.text('残酷な天使のテーゼ'), findsOneWidget);
    expect(find.text('ARTIST: [ 高桥洋子 ]'), findsOneWidget);
    expect(find.byType(MagiConsensusBar), findsOneWidget);
    expect(find.text('MELCHIOR-1'), findsOneWidget);
    expect(find.text('BALTHASAR-2'), findsOneWidget);
    expect(find.text('CASPAR-3'), findsOneWidget);

    // 4. 验证分段能量刻度进度条
    expect(find.byType(MagiProgressGauge), findsOneWidget);
    expect(find.text('/// INTERNAL POWER ///'), findsOneWidget);

    // 5. 验证战术控制台
    expect(find.byType(MagiControlBar), findsOneWidget);
    expect(find.text('[ EXEC ]'), findsOneWidget);

    // 6. 验证右侧通信日志标头
    expect(find.text('MAGI // TRANSCRIPT LOG'), findsOneWidget);
    expect(find.text('实时通信日志'), findsOneWidget);

    // 7. 验证斜纹警戒条与边框准星标尺
    expect(find.byType(MagiHazardBar), findsWidgets);
    expect(find.byType(MagiFrameCorners), findsOneWidget);
    expect(find.byType(MagiEqualizerBar), findsOneWidget);
    expect(find.text('SYNC: 100%'), findsOneWidget);

    // 8. 验证霓虹海报底板
    expect(find.byType(MagiBackdrop), findsOneWidget);
  });

  testWidgets('MAGI 战术终端皮肤：在标准笔记本分辨率（1280x720）下无溢出报错', (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings.experimentalUi': 'magi',
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
        .playQueue([_mockTrack('eva-02')]);
    container.read(playerControllerProvider.notifier).togglePlay();

    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildOvertoneTheme(Brightness.dark),
          home: const ArchiveSkinScope(child: FullPlayerPage()),
        ),
      ),
    );
    await tester.pump();

    // 验证核心组件在 720p 屏幕下正常渲染且无 RenderFlex 溢出
    expect(find.byType(MagiTargetFrame), findsOneWidget);
    expect(find.byType(MagiControlBar), findsOneWidget);
    expect(find.byType(MagiProgressGauge), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MAGI 战术终端皮肤：手机窄屏下同样生效', (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings.experimentalUi': 'magi',
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
        .playQueue([_mockTrack('eva-03')]);
    container.read(playerControllerProvider.notifier).togglePlay();

    tester.view.physicalSize = const Size(360, 740);
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

    final pageContext = tester.element(find.byType(FullPlayerPage));
    expect(OvertoneTheme.of(pageContext).bg, MagiSkin.palette.bg);
    expect(find.byType(MagiTargetFrame), findsOneWidget);
    expect(find.byType(MagiProgressGauge), findsOneWidget);
    expect(find.byType(MagiControlBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MAGI 战术终端皮肤：歌词页在手机窄屏下也生效', (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings.experimentalUi': 'magi',
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
        .playQueue([_mockTrack('eva-04')]);
    container.read(playerControllerProvider.notifier).togglePlay();

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

    expect(find.byType(MagiProgressGauge), findsOneWidget);
    expect(find.byType(MagiControlBar), findsOneWidget);
    expect(find.byType(Slider), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
